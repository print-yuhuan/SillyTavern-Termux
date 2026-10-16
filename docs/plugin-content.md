# 插件说明规范与资料来源

资料核对日期：2026-10-16。适用范围：`Menu.sh` 的插件列表与详情页，以及 README 的插件摘要。

配色基准为 `cc0e75b`，按该提交的菜单和详情页逐项恢复。新增的参考文档、交流反馈与许可说明，分别沿用原仓库地址、群号与版权行的颜色。

## 书写与展示规范

| 项目 | 统一规则 |
|:---|:---|
| 板块顺序 | 仓库地址、插件简介、核心亮点、使用须知、安全提示、参考文档、交流反馈、插件名称、开发作者、版权页脚、许可说明 |
| 可选板块 | 安全提示、参考文档、交流反馈、预设作者及许可说明按资料实际情况显示；版权页脚在全部七个插件中显示 |
| 标题 | 酒馆助手主标题为绿色，记忆表格为蓝色，自定义模型为紫色，其余插件为青色；仓库地址、须知、安全提示为黄色，简介为青色，亮点为普通蓝色 |
| 正文 | 沿用原有颜色常量及字重：酒馆助手简介为绿色，记忆表格和自定义模型亮点为绿色，其余说明正文为白色；插件名称整行为青色，作者整行为绿色 |
| 链接 | 与 `cc0e75b` 的仓库链接相同，使用终端默认前景色；每个地址独立一行，不插入额外着色 |
| 列表 | 安装列表的颜色及名称后的留白直接采用 `cc0e75b`，仅保留当前分类文案；卸载列表为蓝色编号与绿色名称；返回项为黄色 |
| 符号与换行 | 功能和须知统一使用“·”；段落间空一行；一条描述表达一个要点，过长的解释可缩进续行 |
| 语言 | 中文描述配合规范技术名称，如 SillyTavern、JavaScript、EJS、API、Google/Gemini、TTS |
| 作者昵称 | 保留作者自己的大小写；多个同类作者用顿号分隔，插件作者与配套预设作者分开标注 |
| 版权 | 按用户指定的旧版写法，全部插件统一显示紫色加粗的 `© 2026 {copyright_owner}. All rights reserved.`；英文署名沿用旧版大小写 |
| 交流反馈 | 记忆表格使用“官方Q群：1030109849” |
| 内容依据 | 当前功能与兼容要求来自仓库文档、清单和指定参考资料；规划功能不写成已实现功能 |

插件编号、仓库地址、详情文案与配色沿用上述规范。安装和卸载增加范围选择，按以下规则管理公有与私有插件。

## 安装与卸载范围

| 范围编号 | 适用用户 | 插件目录 |
|:---|:---|:---|
| 1 | 所有用户共用 | `$HOME/SillyTavern/public/scripts/extensions/third-party/` |
| 2 起 | 所选用户独享，按用户名排序编号 | `$HOME/SillyTavern/data/<用户名>/extensions/` |

安装与卸载均先选择范围，`1` 始终为公有目录。用户列表只读取 `data` 的直接子目录，排除 `_` 或 `.` 开头的目录、普通文件和符号链接；`default-user` 与其他有效用户目录一样参与编号。私有安装仅按需创建已有用户目录下的 `extensions`，不创建用户目录。

安装时，在选定范围的插件列表中选择插件并确认。卸载时，仅列出选定范围内已安装的插件，再按插件编号选择并确认；操作不影响公有目录或其他用户目录中的同名插件。每层菜单输入 `0` 返回上一层，可重新选择范围。

## 署名、版权页脚与许可

版权页脚采用用户指定的展示模板；下表保留上游资料的核对结果。已确认的许可条款另外展示，不用统一页脚替代上游许可证。

| 插件 | 页面版权署名 |
|:---|:---|
| 酒馆助手 | N0VI028 |
| 记忆表格 | muyoou、lesser |
| 自定义模型 | LenAnderson |
| 小白X | biex |
| 柏宝书 | BaiBai |
| 提示词模板 | zonde306 |
| 龙血玄黄·数据库 | Albus |

| 插件 | 作者显示 | 版权与许可依据 |
|:---|:---|:---|
| 酒馆助手 | KAKAA、青空莉想做舞台少女的狗 | 文档站署名为 © 2026 N0VI028；仓库采用 PolyForm Noncommercial 1.0.0 |
| 记忆表格 | 开发作者：木悠；预设作者：LSR | 仓库清单作者为 muyoo；用户提供的 LSR 文档属于配套预设说明，分开标注其角色 |
| 自定义模型 | LenAnderson | 使用上游项目与清单署名 |
| 小白X | biex | 上游版权文件为 © 2025 biex；Apache License 2.0，含自定义署名要求 |
| 柏宝书 | 柏柏 | README 与清单均使用中文署名“柏柏” |
| 提示词模板 | zonde306 | README 与 LICENSE 声明 GNU AGPL-3.0；不把许可证正文中的自由软件基金会年份当作插件版权年份 |
| 龙血玄黄·数据库 | Albus | 名称和作者遵循用户明确指定的署名，参考资料也将原作者标为 Albus |

本次核对时，记忆表格、自定义模型、柏宝书和龙血玄黄·数据库的仓库未见项目独立许可证，因此详情页省略许可说明板块，版权页脚仍按上述统一模板显示。

## 各插件的资料来源

### 酒馆助手

- [仓库 README](https://github.com/N0VI028/JS-Slash-Runner/blob/main/README.md)
- [用户指定的介绍与安全说明](https://n0vi028.github.io/JS-Slash-Runner-Doc/guide/%E5%85%B3%E4%BA%8E%E9%85%92%E9%A6%86%E5%8A%A9%E6%89%8B/%E4%BB%8B%E7%BB%8D.html)
- [最低酒馆版本声明](https://github.com/N0VI028/JS-Slash-Runner/blob/main/manifest.json)
- [许可证](https://github.com/N0VI028/JS-Slash-Runner/blob/main/LICENSE)

界面渲染、脚本、变量、世界书与事件等能力按文档归纳。iframe 作为实现方式，不描述为对敏感数据访问的完整安全隔离。

### 记忆表格

- [仓库 README](https://github.com/muyoou/st-memory-enhancement/blob/master/README.md)
- [使用教程](https://muyoo.com.cn/memory/doc/start)与[问题自查](https://muyoo.com.cn/memory/doc/installFaq)由仓库 README 提供；本次抓取教程站失败，具体功能以可读取的 README 和用户资料为依据
- 用户提供的《记忆表格插件.txt》，内容为 LSR 配套预设的使用与排错说明
- 资料中引用的 [Extension-MessageLimit](https://github.com/SillyTavern/Extension-MessageLimit)

仅聊天补全模式的限制来自 README。LSR 方案中的提示词模板、世界书、正则、限制发送两条消息及标签配置属于配套方案，不列为插件通用依赖。节点编辑器及 README 标注为“未来”的主副 API 分步操作，不列入已实现的核心亮点。

### 自定义模型

- [用户指定的仓库 README](https://github.com/LenAnderson/SillyTavern-CustomModels/blob/master/README.md)

功能限定为给 OpenAI、Claude 和 Google/Gemini 连接添加模型名称，不扩写为提供新模型、新接口或额外权限。

### 小白X

- [仓库 README](https://github.com/RT15548/LittleWhiteBox/blob/main/README.md)
- [用户指定的文档站](https://docs.littlewhitebox.qzz.io/)
- [代码块渲染说明](https://docs.littlewhitebox.qzz.io/%E6%B8%B2%E6%9F%93%E4%BA%A4%E4%BA%92/%E4%BB%A3%E7%A0%81%E5%9D%97%E6%B8%B2%E6%9F%93)
- [LICENSE.md](https://github.com/RT15548/LittleWhiteBox/blob/main/docs/LICENSE.md)、[COPYRIGHT](https://github.com/RT15548/LittleWhiteBox/blob/main/docs/COPYRIGHT)、[NOTICE](https://github.com/RT15548/LittleWhiteBox/blob/main/docs/NOTICE)

文档站补充了代码渲染、变量、消息检查、循环任务及外部服务配置；许可展示保留自定义署名条款，未简写成无附加条件的标准 Apache-2.0。

### 柏宝书

- [仓库 README](https://github.com/baibai-git/ST-BaiBai-Book/blob/main/README.md)
- [最低酒馆版本声明](https://github.com/baibai-git/ST-BaiBai-Book/blob/main/manifest.json)
- 用户提供的《柏宝书插件.txt》

摘要可跟随主 API，副 API 与向量记忆均非必需。删除聊天会影响随聊天保存的记忆，使用须知保留备份提醒；不使用“永不失忆”等效果保证。

### 提示词模板

- [仓库 README](https://github.com/zonde306/ST-Prompt-Template/blob/main/README.md)
- [用户指定的中文功能文档](https://github.com/zonde306/ST-Prompt-Template/blob/main/docs/features_cn.md)
- [许可证](https://github.com/zonde306/ST-Prompt-Template/blob/main/LICENSE)

说明覆盖提示词生成前处理、回复渲染后处理、变量作用域与内容注入。两阶段都可能执行模板语句，因此安全提示同时提及导入模板和 AI 输出中的可执行内容。

### 龙血玄黄·数据库

- [项目仓库](https://github.com/AlbusKen/shujuku)
- [插件清单](https://github.com/AlbusKen/shujuku/blob/main/manifest.json)与[插件入口](https://github.com/AlbusKen/shujuku/blob/main/src/entry-extension.ts)
- [向量索引配置界面说明](https://github.com/AlbusKen/shujuku/blob/main/src/presentation-v2/copy/vector-index-copy.ts)
- 用户提供的《龙血玄黄·数据库插件.txt》

仓库当前未提供 README，采用用户资料与实际插件入口交叉核对。当前菜单安装插件版；参考资料中的“导入脚本和正则到酒馆助手”属于脚本版步骤。酒馆助手为插件模式的可选依赖，酒馆预设 API 生成功能另有依赖要求。未采用“召回精度提升 192%”等缺少测试口径的量化宣传。
