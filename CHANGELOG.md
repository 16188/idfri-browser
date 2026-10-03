# 更新日志

## 未发布

- 修复 Linux 打包冒烟配置缺少 `schema_version` 导致 Chromium 主动中止的问题，并支持复用已完成的编译缓存重新验收、打包和发布，无需重复耗时编译。
- 新增 Linux x64 IDFRI Chromium 153 完整构建链：固定 portablelinux/ungoogled-chromium 提交，复用同一组源码级指纹补丁和中文 IDFRI 品牌，分段续编译，并在发布前使用 `--fury-fp-fd=0` 进行真实渲染器指纹冒烟验证。
- 将当前 Chromium 153 源码迁移为独立的 IDFRI Browser 单提交仓库，不迁移上游提交、标签和贡献者历史。
- 将源码、构建输出和发布说明中的项目地址统一为 `https://github.com/16188/idfri-browser`。
- 暂停 Dependabot 自动更新分支，确保首次源码发布只保留 `main`。
- 修复 IDFRI Browser 发布任务未检出 Git 仓库时无法创建 GitHub Release 的问题。
- 支持校验并手动发布 `idfri-153-fast` 成功构建生成的 Chromium 153 x64 成品，确保恢复构建可以直接进入 IDFRI 桌面端集成。
- 修正 Chromium 153 成品包的 IDFRI 文件名匹配规则，并在连续五次上传失败时中止构建，避免工作流无成品却误报成功。
- 修复 Windows Chromium 从匿名管道读取指纹配置失败的问题，并支持从上一构建阶段继续编译；恢复补丁兼容已有源码的头文件布局，避免重新执行已完成的耗时阶段。
- 将 Windows x64 Chromium 构建并发从 2 提升至 4，以缩短开发预览版构建时间。
- 在原有 CI 阶段时限内自动重试一次失败的增量 Ninja 构建，恢复 Chromium DevTools 打包过程中偶发退出的 Node 进程。
- 修复指纹配置补丁的 unified diff hunk 行数，确保 Chromium 源码构建可正确应用补丁。

- 接入 BSD-3-Clause 的 Chromium 153 源码级指纹补丁，覆盖 UA/UA-CH、屏幕、Canvas、WebGL/WebGPU、音频、字体、媒体设备、WebRTC、时区、权限、自动化痕迹及跨 Worker/iframe 一致性。
- 新增 IDFRI 标准输入安全配置通道与构建后真实浏览器冒烟验证；指纹配置不进入命令行，也不落明文临时文件。
- 发布修订号升级为 idfri2。

- 为 Windows Chromium 源码构建启用 Python UTF-8 模式，使中文 IDFRI 品牌文件可被 Chromium 构建工具正确读取。
