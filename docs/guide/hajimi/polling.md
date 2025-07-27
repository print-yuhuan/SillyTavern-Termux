# Render适用于Hajimi轮询项目的部署教程

> 本教程适用于在 [Render](https://dashboard.render.com) 平台上零基础部署 [Hajimi轮询项目](https://github.com/wyeeeee/hajimi)。  
> 包含必要环境变量说明、注意事项与常见问题解答。

---

## 前置准备

- **科学上网**：建议开启 “TUN模式” 和 “全局模式”，确保IP干净，避免Render绑卡验证。
- **相关工具/平台**：
  - [Gemini模型列表](https://ai.google.dev/gemini-api/docs/models?hl=zh-cn)
  - [Gemini创建项目](https://console.cloud.google.com/projectcreate)
  - [Gemini获取秘钥](https://aistudio.google.com/app/apikey)
  - [环境变量参考](https://github.com/wyeeeee/hajimi/blob/main/app/config/settings.py)

---

## Step 1. 登录 Render

访问 [Render官网](https://dashboard.render.com)，注册/登录账号。

> 登录遇到问题时，尝试关闭TUN，或切换代理“规则模式”！

![Render登录页面](/hajimi/NO.2.png)

---

## Step 2. 创建 Web Service

1. 首页选择 **Web Services**  
   ![Web Service选项](/hajimi/NO.3.png)
2. 选择 **Public Git Repository**，填入仓库地址：
   ```
   https://github.com/wyeeeee/hajimi
   ```
   ![填写仓库地址](/hajimi/NO.4.png)

---

## Step 3. 配置服务参数

1. **Region** 推荐选择 `Singapore`（亚洲更快）。  
   ![选择Region](/hajimi/NO.5.png)

2. **Instance Type** 选择 `Free`（免费）。
   ![Instance Type](/hajimi/NO.6.png)

3. **环境变量添加**  
   按下表填写，未涉及项可留空：
   | 变量名             | 是否必填 | 作用及说明                                            | 示例值                             |
   |--------------------|---------|----------------------------------------------------|------------------------------------|
   | WEB_PASSWORD       | 可选    | WebUI前端配置密码（如忽略，值同PASSWORD）           | web-yuhuan                         |
   | PASSWORD           | 必填    | API调用密钥（后续可改）                             | key-yuhuan                         |
   | WHITELIST_MODELS   | 可选    | 限定可用模型ID，逗号分隔                            | gemini-2.5-flash,gemini-2.5-pro    |
   | GEMINI_API_KEYS    | 可选    | Gemini API密钥，逗号分隔                            | AIzaSy...                          |
   | TZ                 | 可选    | 日志/统计参考时区                                   | Asia/Shanghai                      |

   ![环境变量配置](/hajimi/NO.7.png)

---

## Step 4. 部署与访问

1. 点击 **Deploy Web Service**  
   ![部署服务按钮](/hajimi/NO.8.png)
2. 状态变为绿色“Live”后，复制页面URL，即为WebUI入口和API端点。  
   ![URL与状态](/hajimi/NO.9.png)

---

## Step 5. SillyTavern 连接配置示例

- **API类型**：聊天补全
- **聊天补全来源**：自定义（兼容OpenAI）
- **端点URL**：`https://你的实例.onrender.com/v1`
- **API密钥**：与 PASSWORD 环境变量一致
- **输入模型名**：如 `gemini-2.5-pro`
- **连接状态**：绿色为正常  
- **自动连接**：建议开启

![酒馆连接配置](/hajimi/NO.10.jpg)

---

## 常见问题

- Render 免费服务15分钟未访问将自动休眠，再次访问需等待空间激活（约1分钟）。
- 推荐结合保活方案，见文档“[Cron-Job保活配置](/guide/cronjob/keepalive)”。
```
