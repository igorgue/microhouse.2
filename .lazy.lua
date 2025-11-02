vim.opt.cursorline = true
vim.opt.cursorcolumn = true

vim.g.focus_mode = false
vim.g.cmp_auto_brackets = false

vim.defer_fn(function()
	require("gitsigns").toggle_signs(false)
  vim.opt.laststatus = 0
end, 1000)

return {}
