return {
  "neovim/nvim-lspconfig",
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- disable a keymap
    keys[#keys + 1] = { "<leader>ca", false }
    keys[#keys + 1] = { "<leader>cc", false }
    keys[#keys + 1] = { "<leader>cC", false }
    keys[#keys + 1] = { "<leader>cR", false }
    keys[#keys + 1] = { "<leader>cr", false }
    keys[#keys + 1] = { "<leader>cA", false }
    keys[#keys + 1] = { "<leader>cl", false }
    keys[#keys + 1] = { "<leader>cs", false }
    keys[#keys + 1] = { "<leader>cS", false }
  end,
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.servers.clangd = opts.servers.clangd or {}
    -- LazyVim clangd extra 会注入 servers.clangd.keys，vim.lsp health 在某些版本会因此报 concat 错误
    opts.servers.clangd.keys = nil
    -- Mason 安装的 PSES；bundle_path 用 stdpath("data")，避免写死用户名路径
    if not vim.g.vscode then
      opts.servers.powershell_es = {
        filetypes = { "ps1", "psm1", "psd1" },
        bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
        settings = { powershell = { codeFormatting = { Preset = "OTBS" } } },
        init_options = {
          enableProfileLoading = false,
        },
      }
    end
    return opts
  end,
}
