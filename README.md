# 💤 DHxlxLazyVim

Based on the starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to learn more about it.

Some Prerequisites:

- gzip: `scoop install gzip`
- gcc: `scoop install mingw`
- Nerd Font: 
    ```powershell
    scoop bucket add nerd-fonts
    scoop install nerd-fonts/CascadiaCode-NF
    ```

Effects are as follows,

![](https://i.imgur.com/fS2lFic.png)

![](https://i.imgur.com/NFiBfv5.png)

![](https://i.imgur.com/3hx9KJD.png)

![](https://i.imgur.com/ebT9DaG.png)

## 快捷键与项目任务

以下是当前配置中与 C/C++ 项目最相关的快捷键和命令：

- `<leader>pt`：打开项目任务选择器（`build` / `run` / `launch` / `lsp`）
- `:ProjectTask <mode>`：直接执行项目任务，`mode` 可选 `build` / `run` / `launch` / `lsp`
- `:Pt`：快捷命令，默认等价于 `:ProjectTask lsp`
- `:Pt build`：编译项目
- `:Pt run`：在新开的 PowerShell 终端中运行已编译的可执行文件
- `:Pt launch`：先编译再运行
- `:Pt lsp`：生成并更新 `compile_commands.json`，并自动执行 `:LspRestart`

补充说明：

- `:Pt run` 只负责运行，不会自动编译；若提示找不到 exe，请先执行 `:Pt build`
- `:Pt lsp` 用于 clangd 补全所需的编译数据库刷新
- 在本配置中，C/C++ 的 clangd 附加快捷键：
  - `<leader>ch`：切换头/源文件
  - `<leader>ct`：类型层次
  - `<leader>cm`：内存使用
  - `<leader>cs`：符号信息
  - `<leader>cr`：重启 clangd
