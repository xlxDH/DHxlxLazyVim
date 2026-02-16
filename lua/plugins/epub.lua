return {
  "CrystalDime/epub.nvim",
  config = function()
    require("epub").setup({
      auto_open = true,
    })
  end,
}
