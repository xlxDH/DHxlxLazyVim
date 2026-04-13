local map = vim.keymap.set
-- TODO: 不知道为什么 <leader>w 和 <leader>c 无法在 which-key 中显示
-- 添加 <leader>w 来保存当前buffer 的映射
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
if not vim.g.vscode then
  local function run_project_task(mode)
    local valid = { build = true, run = true, launch = true, lsp = true }
    if not valid[mode] then
      vim.notify("不支持的任务模式: " .. tostring(mode), vim.log.levels.ERROR)
      return
    end

    local script = vim.fn.getcwd() .. "/scripts/ltask.ps1"
    if vim.fn.filereadable(script) == 0 then
      vim.notify("未找到脚本: " .. script, vim.log.levels.ERROR)
      return
    end

    vim.notify("正在执行项目任务: " .. mode, vim.log.levels.INFO)
    vim.fn.jobstart({ "powershell", "-ExecutionPolicy", "Bypass", "-File", script, "-Mode", mode }, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_exit = function(_, code)
        vim.schedule(function()
          if code == 0 then
            if mode == "lsp" then
              if vim.fn.exists(":LspRestart") == 2 then
                vim.cmd("silent! LspRestart")
                vim.notify("compile_commands.json 已更新，已自动执行 :LspRestart", vim.log.levels.INFO)
              else
                vim.notify("compile_commands.json 已更新（未找到 :LspRestart）", vim.log.levels.WARN)
              end
            else
              vim.notify("任务执行成功: " .. mode, vim.log.levels.INFO)
            end
          else
            vim.notify("任务执行失败(" .. mode .. ")，退出码: " .. code, vim.log.levels.ERROR)
          end
        end)
      end,
    })
  end

  local function select_project_task()
    vim.ui.select({ "build", "run", "launch", "lsp" }, { prompt = "选择项目任务" }, function(choice)
      if choice then
        run_project_task(choice)
      end
    end)
  end

  -- quit current window
  map("n", "<leader><leader>q", "<cmd>q<cr>", { desc = "Quit current window" })
  -- close current buffer
  map("n", "<leader>c", function()
    local bd = require("mini.bufremove").delete
    if vim.bo.modified then
      local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
      if choice == 1 then -- Yes
        vim.cmd.write()
        bd(0)
      elseif choice == 2 then -- No
        bd(0, true)
      end
    else
      bd(0)
    end
  end, { noremap = true, desc = "Delete Buffer" })

  -- copy relative path
  vim.cmd([[
command! -nargs=0 CpRelativePath lua require("fany.utils.fanyutils").copy_relative_path()
]])

  -- copy relative path
  vim.cmd([[
command! -nargs=0 CpFileName lua require("fany.utils.fanyutils").copy_current_filename()
]])

  -- copy absolute path
  vim.cmd([[
command! -nargs=0 CpAbsolutePath lua require("fany.utils.fanyutils").copy_absolute_path()
]])

  vim.api.nvim_create_user_command("ProjectTask", function(opts)
    run_project_task(opts.args)
  end, {
    nargs = 1,
    complete = function()
      return { "build", "run", "launch", "lsp" }
    end,
    desc = "Run project task: build/run/launch/lsp",
  })
  vim.api.nvim_create_user_command("Pt", function(opts)
    local mode = opts.args ~= "" and opts.args or "lsp"
    run_project_task(mode)
  end, {
    nargs = "?",
    complete = function()
      return { "build", "run", "launch", "lsp" }
    end,
    desc = "Run project task quickly (default: lsp)",
  })
  vim.api.nvim_create_user_command("LspCcdb", function()
    run_project_task("lsp")
  end, { desc = "Generate compile_commands.json for clangd" })
  map("n", "<leader>pt", select_project_task, { desc = "Project task picker" })
  map("n", "<leader>lg", function()
    run_project_task("lsp")
  end, { desc = "Generate compile_commands.json" })

  -- register F11 to toggle fullscreen in normal mode
  if vim.g.neovide == true then
    vim.api.nvim_set_keymap("n", "<F11>", ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>", {})
  end
else
  map(
    "n",
    "<leader><leader>q",
    "<Cmd>lua require('vscode').call('workbench.action.closeWindow')<CR>",
    { desc = "Quit VSCode" }
  )
  map(
    "n",
    "<leader>c",
    "<Cmd>lua require('vscode').call('workbench.action.closeEditorInAllGroups')<CR>",
    { desc = "Close Current Tab" }
  )
  map(
    "n",
    "<leader>e",
    "<Cmd>lua require('vscode').call('workbench.action.toggleSidebarVisibility')<CR>",
    { desc = "toggleSidebarVisibility" }
  )
  -- reveal current active file in vscode explorer view
  -- workbench.files.action.showActiveFileInExplorer
  map(
    "n",
    "<leader>E",
    "<Cmd>lua require('vscode').call('workbench.files.action.showActiveFileInExplorer')<CR>",
    { desc = "reveal active file" }
  )
  map(
    "n",
    "<leader>a",
    "<Cmd>lua require('vscode').call('workbench.action.toggleActivityBarVisibility')<CR>",
    { desc = "toggleActivityBarVisibility" }
  )
  -- run js codes
  map("n", "<leader>js", function()
    require("vscode").call("workbench.action.terminal.sendSequence", { args = { text = "clear\n" } })
    -- require("vscode").call("workbench.action.terminal.focus")
    require("vscode").call("workbench.action.terminal.sendSequence", { args = { text = "bun '${file}'\n" } })
  end, { desc = "Run JS or TS codes with node" })
  -- run ahk scripts
  map("n", "<leader>kk", function()
    require("vscode").call("workbench.action.terminal.sendSequence", { args = { text = "clear\n" } })
    require("vscode").call("workbench.action.terminal.sendSequence", { args = { text = "${file}\n" } })
  end, { desc = "Run ahk scripts" })
  -- run python scripts
  map("n", "<leader>py", function()
    require("vscode").call("workbench.action.terminal.sendSequence", { args = { text = "clear\n" } })
    require("vscode").call("workbench.action.terminal.sendSequence", { args = { text = "python '${file}'\n" } })
  end, { desc = "Run python scripts" })
end
