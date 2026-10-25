-- noice.nvim calls vim.fn.localtime() from UI event handlers (fast context),
-- which nvim 0.12 rejects with E5560 on every mouse scroll.
return {
  "folke/noice.nvim",
  init = function()
    vim.fn.localtime = os.time
  end,
}
