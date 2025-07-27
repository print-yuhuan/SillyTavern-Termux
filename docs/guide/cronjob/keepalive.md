# Render免费服务保活方案（Cron-Job.org）

> 利用 Cron-Job.org 定时访问 Render 服务，避免因长时间未访问而进入休眠。

---

## Step 1. 注册 & 登录

访问 [Cron-Job.org](https://console.cron-job.org/signup)，注册并登录。

![注册页面](/cronjob/NO.1.png)

---

## Step 2. 创建计划任务

1. 登录后，点击“创建计划任务”  
   ![创建任务](/cronjob/NO.2.png)

2. 填写任务信息：

- **标题**：Hajimi（自定义）
- **网址**：`https://你的实例.onrender.com/v1/chat/completions`
- **运行计划**：每10分钟
- **请求方法**：POST
- **时区**：Asia/Shanghai
- **请求头**：
  - Authorization：Bearer (你的API Key)
  - Content-Type：application/json
- **请求内容**：
    ```json
    {
      "model": "gemini-2.5-flash",
      "messages": [
        {"role": "user", "content": "Hello"}
      ],
      "max_tokens": 500
    }
    ```
- **超时**：30秒  
- 其它选项按实际需求开启/关闭。

![任务配置主页面](/cronjob/NO.3.png)
![请求参数配置](/cronjob/NO.4.png)

---

## Step 3. 测试与保存

1. 点击“测试运行”  
   - 若返回200 OK即为成功，如失败，多半是Render服务未激活，可手动访问一次WebUI后重试。

![测试运行](/cronjob/NO.5.png)

2. 测试通过后保存任务，之后Cron-Job会定时请求，Render服务即可长期活跃。

![任务列表](/cronjob/NO.6.png)

---

## 常见问题

- 测试失败多为服务休眠，请访问一次Web页面后再试。
- 可根据需求调整访问频率与参数。

---

> 配置保活后，Render免费服务可实现7x24小时稳定可用！
