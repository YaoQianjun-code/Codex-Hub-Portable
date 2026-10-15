Codex Hub Portable v4.3 — DS 配置补全版

使用方法
1. 将整个压缩包解压到一个准备长期保留的目录。不要在压缩包内直接运行。
2. 关闭已经打开的 Codex Hub，双击 Start-Setup.cmd。
3. 按提示填写 DS 接口地址、模型和 API Key。
   官方 DS 地址默认：https://api.deepseek.com
   默认模型：deepseek-flash；也可填 deepseek-v4-pro。
   地址和模型直接回车即可使用默认值；API Key 输入时不会显示。
4. 等待出现“DS 密钥、模型和 Responses 接口测试通过”和“安装完成”。
   测试会发起一条很短的真实 API 请求，可能产生少量 API 费用。
   如果测试失败，安装脚本会明确报错；修正后重新运行即可。
5. 双击桌面新生成的“Codex Hub”，在“工作环境”下拉框选择官方 Codex 或 DeepSeek。
   原程序中的 DeepSeek 名称仍可能显示“DeepSeek（预留）”；这只是原程序的标签。
   API 配置由本安装包补齐，不需要改用另一个终端来启动 DS。

前提条件
- Windows 和可用的官方 Codex；本版要求 Codex CLI 0.155.1 或更新版本。
- 官方端继续使用你原有的 OpenAI 登录与配置。
- DS 端需要自己的 API Key、可用额度和网络。OpenAI/ChatGPT 订阅不提供 DS API 额度。
- 只需 Windows 自带的 PowerShell，不需要 Python、Node.js 或额外代理程序。
- 如果系统没有可用的 WebView2 运行时，原来的 Hub 界面可能无法启动。

以后修改 DS 配置
运行 Configure-DeepSeek.cmd，或者桌面的“Codex DS 设置”。
API Key 留空会保留已有密钥；首次配置不能留空。
修改完成后请关闭并重新打开 Hub，让后台重新读取配置。
只检查真实连接：Test-DeepSeek.cmd。
只检查本机文件、密钥和 CLI 版本：Diagnose.cmd，不发起 API 请求。
Start-CodexHub.cmd 也可启动原 Hub 界面。
桌面的“Codex Plus”和“Codex DeepSeek”分别打开独立 CLI。

隔离和密钥保存
- 官方 CODEX_HOME：%USERPROFILE%\.codex
- DS CODEX_HOME：%USERPROFILE%\.codex-deepseek
- 安装脚本不修改官方 config.toml，不复制官方登录令牌，不设置全局 DS 密钥环境变量。
- DS 的 config.toml 保存接口地址、模型和取密钥命令；不写入明文 API Key。
- 密钥以 Windows DPAPI CurrentUser 加密，存放在 DS 目录的 .hub 中。
- Hub 直接启动 app-server 时，由 Codex 按 DS 配置调用取密钥程序，所以直接使用界面也能认证。
- 加密密钥绑定保存它的 Windows 账户和计算机。换电脑/账户后请重新输入密钥。
- 此处隔离的是配置、认证和会话目录；工作目录仍由你在 Hub 中选择。

已有 DS 配置和备份
本工具管理 DS 的 config.toml、models.json 和 .hub 内的认证配置。
更新前会将被替换的旧文件备份到：
%USERPROFILE%\.codex-deepseek\.hub\backups\日期-随机编号\
如果检测到非本工具生成的 config.toml，会先询问是否备份后替换。
自定义 DS 配置中的 MCP、信任目录等额外设置只保留在备份中，需要自行合并回新 config.toml。
DS 会话历史不删除。若需还原旧 DS 配置，关闭 Hub 后，将备份文件复制回原位置。
官方端不参与此替换。

常见错误
- 401：API Key 无效或已失效。
- 402：余额不足。
- 403：权限不足。
- 404：地址或模型不正确，或者接口不支持 Responses API。
- 429：请求限制或额度不足。
- 无法解密：请使用原 Windows 账户，或者重新配置密钥。
- 使用中转地址：必须提供 Responses API；基地址不要带 /responses 或 /chat/completions。
- 安装完成后保留解压目录；桌面快捷方式会引用该目录。

版本范围
v4.3 更新的是安装、DS 配置、认证、测试、诊断和启动脚本。
codex-hub.exe 和官方 CLI 启动脚本保留原文件；原 Hub 程序没有源代码，未重新编译或修改二进制。

官方参考（2026-10-15 核对）
DeepSeek Codex 接入：https://api-docs.deepseek.com/quick_start/agent_integrations/codex/
DeepSeek Responses API：https://api-docs.deepseek.com/guides/responses_api/
OpenAI Codex 配置：https://developers.openai.com/codex/config-reference/
