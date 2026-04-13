-- ~/.config/nvim/lua/plugins/clangd.lua
-- 使用 blink.cmp（与 LazyVim 默认一致），不再单独引入 nvim-cmp

local function first_existing_path(paths)
  for _, path in ipairs(paths) do
    if vim.fn.executable(path) == 1 or vim.fn.isdirectory(path) == 1 then
      return path
    end
  end
end

local function detect_mingw_libstdcpp_includes()
  local roots = {
    "C:/msys64/ucrt64/include/c++",
    "C:/msys64/mingw64/include/c++",
    "C:/msys64/clang64/include/c++",
  }
  for _, root in ipairs(roots) do
    if vim.fn.isdirectory(root) == 1 then
      local versions = vim.fn.glob(root .. "/*", false, true)
      table.sort(versions)
      local version_dir = versions[#versions]
      if version_dir and vim.fn.isdirectory(version_dir) == 1 then
        local target_dir = first_existing_path({
          version_dir .. "/x86_64-w64-mingw32",
          version_dir .. "/x86_64-pc-msys",
        })
        return version_dir, target_dir
      end
    end
  end
end

local function clangd_compile_flags()
  local cpp_standard = vim.g.clangd_cpp_standard or "c++17"
  local flags = { "-std=" .. cpp_standard }

  local stdlib = vim.g.clangd_stdlib_include or vim.env.NVIM_CLANGD_STDLIB_INCLUDE
  if stdlib and stdlib ~= "" and vim.fn.isdirectory(vim.fn.expand(stdlib)) == 1 then
    flags[#flags + 1] = "-isystem" .. vim.fn.expand(stdlib)
    return flags
  end

  local version_dir, target_dir = detect_mingw_libstdcpp_includes()
  if version_dir then
    flags[#flags + 1] = "-isystem" .. version_dir
  end
  if target_dir then
    flags[#flags + 1] = "-isystem" .. target_dir
  end

  return flags
end

local function clangd_query_driver_arg()
  local user_value = vim.g.clangd_query_driver or vim.env.NVIM_CLANGD_QUERY_DRIVER
  if user_value and user_value ~= "" then
    return "--query-driver=" .. user_value
  end

  local drivers = {}
  local function add_driver(path)
    if path and path ~= "" and vim.fn.executable(path) == 1 then
      drivers[#drivers + 1] = path
    end
  end

  -- Prefer compilers detected from PATH; this handles custom install locations (e.g. D:/Program Files/...)
  add_driver(vim.fn.exepath("g++"))
  add_driver(vim.fn.exepath("gcc"))
  add_driver(vim.fn.exepath("clang++"))
  add_driver(vim.fn.exepath("clang"))

  local candidates = {
    "C:/msys64/ucrt64/bin/g++.exe",
    "C:/msys64/mingw64/bin/g++.exe",
    "C:/msys64/clang64/bin/clang++.exe",
    "C:/Program Files/LLVM/bin/clang++.exe",
    "D:/Program Files/mingw-w64/mingw64/bin/g++.exe",
    "D:/Program Files/LLVM/bin/clang++.exe",
  }
  for _, path in ipairs(candidates) do
    add_driver(path)
  end
  if #drivers > 0 then
    local uniq = {}
    local dedup = {}
    for _, driver in ipairs(drivers) do
      if not uniq[driver] then
        uniq[driver] = true
        dedup[#dedup + 1] = driver
      end
    end
    return "--query-driver=" .. table.concat(dedup, ",")
  end
end

return {
  "p00f/clangd_extensions.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },
  ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  config = function()
    local lspconfig = require("lspconfig")
    local blink_cmp = require("blink.cmp")

    local capabilities = blink_cmp.get_lsp_capabilities()
    capabilities.offsetEncoding = { "utf-16" }

    local cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--offset-encoding=utf-16",
      "--all-scopes-completion",
      "--cross-file-rename",
    }
    local query_driver = clangd_query_driver_arg()
    if query_driver then
      cmd[#cmd + 1] = query_driver
    end

    lspconfig.clangd.setup({
      capabilities = capabilities,
      cmd = cmd,
      init_options = {
        clangdFileStatus = true,
        compileFlags = clangd_compile_flags(),
      },
      on_attach = function(client, bufnr)
        require("clangd_extensions").setup({
          server = {
            capabilities = capabilities,
            cmd = vim.lsp.get_client_by_id(client.id).cmd,
            init_options = client.config.init_options,
          },
          extensions = {
            autoSetHints = true,
            auto_complete = true,
            type_hints = {
              inline = vim.fn.has("nvim-0.10") == 1,
              only_current_line = false,
              show_parameter_hints = true,
              parameter_hints_prefix = "<- ",
              other_hints_prefix = "=> ",
              highlight = "Comment",
            },
            memory_usage = { border = "rounded" },
            symbol_info = { border = "rounded" },
          },
        })

        local map = vim.keymap.set
        map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", { buffer = bufnr, desc = "Clangd: 切换头文件/源文件" })
        map("n", "<leader>ct", "<cmd>ClangdTypeHierarchy<CR>", { buffer = bufnr, desc = "Clangd: 类型层次视图" })
        map("n", "<leader>cm", "<cmd>ClangdMemoryUsage<CR>", { buffer = bufnr, desc = "Clangd: 内存使用视图" })
        map("n", "<leader>cs", "<cmd>ClangdSymbolInfo<CR>", { buffer = bufnr, desc = "Clangd: 符号信息" })
        map("n", "<leader>cr", "<cmd>ClangdRestart<CR>", { buffer = bufnr, desc = "Clangd: 重启服务" })
      end,
    })
  end,
}
