"""Startup locking regressions using real Linux locks and private processes.

Run with: python3 tests/test_start_lock.py (Linux/WSL).
No network requests or real SillyTavern/Gemini services are started.
"""
import fcntl
import os
from pathlib import Path
import signal
import subprocess
import time
import unittest

import test_safety


class StartLockTests(unittest.TestCase):
    def setUp(self):
        self.harness = test_safety.SafetyTests()
        self.harness.setUp()
        self.addCleanup(self.harness.doCleanups)
        self.home = self.harness.home
        self.tavern = self.harness.tavern
        self.lock = self.home / ".st_run.flock"
        self.legacy = self.home / ".st_run.lock"

    def assert_lock_available(self):
        with self.lock.open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)

    def background_process(self, arguments, cwd, ready_name=None):
        process = subprocess.Popen(arguments, cwd=cwd, start_new_session=True,
                                   stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        def cleanup():
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
            process.wait(timeout=3)
        self.addCleanup(cleanup)
        if ready_name is not None:
            for _ in range(200):
                if Path(f"/proc/{process.pid}/cmdline").read_bytes().split(b"\0")[0] == ready_name.encode():
                    break
                time.sleep(0.01)
            else:
                self.fail("Background fixture did not start")
        return process

    def test_empty_legacy_lock_is_removed_and_start_succeeds(self):
        self.legacy.mkdir()
        result = self.harness.run_bash("start_tavern")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("已自动清理旧版残留启动锁", result.stdout)
        self.assertFalse(self.legacy.exists())
        self.assertIn("npm start", (self.home / "calls").read_text())
        self.assert_lock_available()

    def test_menu_launched_from_tavern_is_not_mistaken_for_its_service(self):
        result = self.harness.run_bash(r'''
if [[ "${0##*/}" != 'Menu.sh' ]]; then
    cp "$0" "$TEST_ROOT/Menu.sh" || exit 10
    cd "$TEST_HOME/SillyTavern" || exit 11
    exec bash "$TEST_ROOT/Menu.sh"
fi
start_tavern
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("npm start", (self.home / "calls").read_text())
        self.assert_lock_available()

    def test_sigkill_owner_keeps_live_service_locked_then_releases_automatically(self):
        test_safety.put(self.tavern / "start.sh", r'''#!/bin/bash
echo "$BASHPID" > "$TEST_HOME/tavern.pid"
command sleep 30
''')
        result = self.harness.run_bash(r'''
trap() {
    if [[ "$1" == cleanup_session ]]; then echo "$BASHPID" > "$TEST_HOME/session.pid"; fi
    builtin trap "$@"
}
test_cleanup() {
    [[ "$test_service" =~ ^[0-9]+$ ]] && kill -KILL -- "-$test_service" 2>/dev/null || true
    [[ "$test_owner" =~ ^[0-9]+$ ]] && kill -KILL "$test_owner" 2>/dev/null || true
}
trap test_cleanup EXIT
start_tavern &
launcher=$!
for ((i=0; i<200; i++)); do
    [[ -f "$TEST_HOME/tavern.pid" && -f "$TEST_HOME/session.pid" ]] && break
    command sleep 0.01
done
test_owner=$(cat "$TEST_HOME/session.pid") || exit 10
test_service=$(cat "$TEST_HOME/tavern.pid") || exit 11
kill -KILL "$test_owner" || exit 12
wait "$launcher" 2>/dev/null || true
# The inherited descriptor keeps the lock while the service survives.
start_tavern && exit 13
kill -0 "$test_service" || exit 14
# Simulate Android killing the remaining session service and its descendants.
kill -KILL -- "-$test_service" || exit 15
for ((i=0; i<200; i++)); do
    if flock -n "$TEST_HOME/.st_run.flock" true; then break; fi
    command sleep 0.01
done
printf '#!/bin/bash\necho restarted > "$TEST_HOME/restarted"\n' > "$TEST_HOME/SillyTavern/start.sh"
start_tavern
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("已有启动会话或服务仍在运行", result.stdout)
        self.assertEqual((self.home / "restarted").read_text().strip(), "restarted")
        self.assertFalse(self.legacy.exists())
        self.assert_lock_available()

    def test_orphan_server_without_lock_is_detected_and_not_killed(self):
        process = self.background_process(
            ["bash", "-c", "exec -a node python3 -c 'import time; time.sleep(30)' server.js"], self.tavern, "node")
        self.legacy.mkdir()
        result = self.harness.run_bash("start_tavern")
        self.assertNotEqual(result.returncode, 0, result.stderr)
        self.assertIn("现有服务仍在运行", result.stdout)
        self.assertIsNone(process.poll())
        self.assertTrue(self.legacy.is_dir())
        self.assertFalse((self.home / "calls").exists())
        self.assert_lock_available()

    def test_unrelated_process_in_tavern_is_not_mistaken_for_service(self):
        process = self.background_process(
            ["bash", "-c", "exec -a node python3 -c 'import time; time.sleep(30)' unrelated.js"], self.tavern, "node")
        result = self.harness.run_bash("start_tavern")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIsNone(process.poll())
        self.assert_lock_available()

    def test_legacy_launcher_is_preserved_without_truncating_proxy_log(self):
        test_safety.put(self.tavern / "start.sh", "#!/bin/bash\nsleep 30\n")
        process = self.background_process(["bash", str(self.tavern / "start.sh")], self.tavern)
        self.legacy.mkdir()
        log = self.home / "setup.log"
        test_safety.put(log, b"x" * (5 * 1024 * 1024 + 1))
        result = self.harness.run_bash("start_tavern")
        self.assertNotEqual(result.returncode, 0, result.stderr)
        self.assertIsNone(process.poll())
        self.assertTrue(self.legacy.is_dir())
        self.assertEqual(log.stat().st_size, 5 * 1024 * 1024 + 1)

    def test_nonempty_legacy_lock_is_not_deleted(self):
        test_safety.put(self.legacy / "user.txt", "keep this")
        result = self.harness.run_bash("start_tavern")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.legacy / "user.txt").read_text(), "keep this")
        self.assertIn("旧版启动锁路径异常或目录非空", result.stdout)
        self.assert_lock_available()

    def test_symlink_lock_does_not_modify_its_target(self):
        target = self.home / "user-file"
        test_safety.put(target, "keep this")
        self.lock.symlink_to(target)
        result = self.harness.run_bash("start_tavern")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(target.read_text(), "keep this")
        self.assertIn("启动锁路径异常", result.stdout)

    def test_system_lock_error_is_reported_as_error_not_busy(self):
        result = self.harness.run_bash("flock() { return 69; }; start_tavern")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("\x1b[1;31m\x1b[1m>> 无法获取系统启动锁", result.stdout)
        self.assertNotIn("已有启动会话", result.stdout)
        self.assert_lock_available()

    def test_unwritable_home_is_reported_as_error_not_busy(self):
        self.home.chmod(0o500)
        try:
            result = self.harness.run_bash("start_tavern")
        finally:
            self.home.chmod(0o700)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("\x1b[1;31m\x1b[1m>> 无法打开启动锁文件", result.stdout)
        self.assertNotIn("已有启动会话", result.stdout)

    def test_parallel_start_attempts_launch_only_one_service(self):
        test_safety.put(self.tavern / "start.sh", r'''#!/bin/bash
echo started >> "$TEST_HOME/starts"
while [[ ! -e "$TEST_HOME/release-service" ]]; do command sleep 0.01; done
''')
        result = self.harness.run_bash(r'''
first=""
trap 'touch "$TEST_HOME/release-service"; [[ -n "$first" ]] && wait "$first" 2>/dev/null || true' EXIT
start_tavern &
first=$!
for ((i=0; i<200; i++)); do
    [[ -f "$TEST_HOME/starts" ]] && break
    command sleep 0.01
done
[[ -f "$TEST_HOME/starts" ]] || exit 10
attempts=()
for ((i=0; i<6; i++)); do
    start_tavern &
    attempts+=("$!")
done
for attempt in "${attempts[@]}"; do
    wait "$attempt" && exit 11
done
touch "$TEST_HOME/release-service"
wait "$first"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.home / "starts").read_text().splitlines(), ["started"])
        self.assertEqual(result.stdout.count("已有启动会话或服务仍在运行"), 6)
        self.assert_lock_available()

    def test_orphan_proxy_is_detected_in_linked_mode(self):
        test_safety.put(self.home / ".env", "START_MODE=2\n")
        proxy = self.home / "Gemini-CLI-Termux"
        test_safety.put(proxy / "run.py", "placeholder")
        process = self.background_process(
            ["bash", "-c", "exec -a python3 python3 -c 'import time; time.sleep(30)' run.py"], proxy, "python3")
        result = self.harness.run_bash("start_tavern")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("现有服务仍在运行", result.stdout)
        self.assertIsNone(process.poll())
        self.assert_lock_available()

    def test_sighup_stops_owned_service_and_releases_lock(self):
        test_safety.put(self.tavern / "start.sh", '#!/bin/bash\necho "$BASHPID" > "$TEST_HOME/tavern.pid"\nsleep 30\n')
        result = self.harness.run_bash(r'''
trap() {
    if [[ "$1" == cleanup_session ]]; then echo "$BASHPID" > "$TEST_HOME/session.pid"; fi
    builtin trap "$@"
}
(
    for ((i=0; i<200; i++)); do
        if [[ -f "$TEST_HOME/tavern.pid" && -f "$TEST_HOME/session.pid" ]]; then
            kill -HUP "$(cat "$TEST_HOME/session.pid")"
            exit 0
        fi
        command sleep 0.01
    done
    exit 1
) &
controller=$!
start_tavern
status=$?
wait "$controller" || exit 10
exit "$status"
''')
        self.assertEqual(result.returncode, 129, result.stderr)
        self.assertIn("unlock", (self.home / "calls").read_text())
        self.assert_lock_available()

    def test_dependency_repair_requests_util_linux_for_missing_flock(self):
        result = self.harness.run_bash(r'''
command() {
    if [[ "$1" == '-v' && "$2" == 'flock' ]]; then return 1; fi
    builtin command "$@"
}
pkg() {
    printf 'pkg %s\n' "$*" >> "$TEST_HOME/calls"
    [[ "$1" != 'install' ]]
}
fix_dependencies
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("pkg install -y util-linux", (self.home / "calls").read_text())


if __name__ == "__main__":
    unittest.main(verbosity=2)
