return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.nvim",
    },
    cmd = { "RenderMarkdown" },
    keys = {
      {
        "<leader>mp",
        "<cmd>RenderMarkdown toggle<cr>",
        ft = "markdown",
        desc = "Markdown Preview Toggle",
      },
    },
    opts = {
      heading = {
        enabled = true,
      },
      bullet = {
        enabled = true,
      },
      code = {
        enabled = true,
        sign = false,
      },
    },
  },
}
