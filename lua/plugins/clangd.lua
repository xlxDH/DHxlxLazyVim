-- ~/.config/nvim/lua/plugins/clangd.lua
return {
  -- 先确保 nvim-cmp 及其依赖已安装
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP 补全源
      "hrsh7th/cmp-buffer",   -- 缓冲区补全源
      "hrsh7th/cmp-path",     -- 路径补全源
      "hrsh7th/cmp-cmdline",  -- 命令行补全源
      "L3MON4D3/LuaSnip",     -- 代码片段引擎
      "saadparwaiz1/cmp_luasnip", -- 连接 Luasnip 和 nvim-cmp
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- 基础 cmp 配置（保证补全功能可用）
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认补全
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP 补全（核心）
          { name = "luasnip" },  -- 代码片段
          { name = "buffer" },   -- 缓冲区文字
          { name = "path" },     -- 文件路径
        }),
      })
    end,
  },

  -- clangd 增强插件核心配置
  "p00f/clangd_extensions.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp", -- 现在依赖的 cmp-nvim-lsp 已有前置依赖
  },
  ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp") -- 现在能正常找到 cmp 模块了

    -- ===================== 核心配置项（请修改这里！）=====================
    local stdcpp_h_include_path = "/c/MinGW/lib/gcc/mingw32/6.3.0/include/c++/mingw32"
    local cpp_standard = "c++17"

    -- ===================== 固定配置（无需修改）=====================
    local capabilities = cmp_nvim_lsp.default_capabilities()
    capabilities.offsetEncoding = { "utf-16" }

    lspconfig.clangd.setup({
      capabilities = capabilities,
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--offset-encoding=utf-16",
        "--all-scopes-completion",
        "--cross-file-rename",
      },
      init_options = {
        clangdFileStatus = true,
        compileFlags = {
          "-std=" .. cpp_standard,
          "-I" .. stdcpp_h_include_path,
        },
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

        -- 快捷键配置
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
