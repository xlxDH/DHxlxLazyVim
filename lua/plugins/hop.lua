return {
  "smoka7/hop.nvim",
  version = "*",
  vscode = true,
  opts = {},
  keys = {
    {
      "s",
      function()
        require("hop").hint_words()
      end,
      mode = { "n" },
      desc = "Hop hint words",
    },
    {
      "s",
      function()
        require("hop").hint_words({ extend_visual = true })
      end,
      mode = { "v" },
      desc = "Hop hint words (extend selection)",
    },
    {
      "<S-s>",
      function()
        require("hop").hint_lines()
      end,
      mode = { "n" },
      desc = "Hop hint lines",
    },
    {
      "<S-s>",
      function()
        require("hop").hint_lines({ extend_visual = true })
      end,
      mode = { "v" },
      desc = "Hop hint lines (extend selection)",
    },
  },
}
