vim.g.focus_mode = false

vim.defer_fn(function()
	require("gitsigns").toggle_signs(false)
	vim.opt.laststatus = 0
end, 500)

return {}
