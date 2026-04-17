# Harmony TVBox Client

HarmonyOS + ArkTS 项目骨架，目标是做一个 TVBox-like 客户端：

- 配置 URL 管理
- 读取 TVBox 风格 JSON
- 展示源列表
- 搜索与详情页
- 播放页占位
- 后端适配层预留

## 重要说明

当前版本：
- 支持读取和展示 `https://pandown.pro/tvbox/tvbox.json` 这类配置结构
- 不直接执行外部 `jar` / `spider` / `csp_*`
- 推荐将复杂解析放在后端适配层完成

## 页面规划

- HomePage.ets：首页 / 源列表
- SearchPage.ets：搜索
- DetailPage.ets：详情
- PlayerPage.ets：播放页
- SettingsPage.ets：设置页

## 推荐后端接口

- GET /sources
- GET /search?q=
- GET /detail?id=
- GET /play?id=
