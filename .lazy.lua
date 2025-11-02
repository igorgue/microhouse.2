vim.g.focus_mode = false

vim.defer_fn(function()
	require("gitsigns").toggle_signs(false)
	vim.opt.laststatus = 0
end, 500)

-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "TidalLaunch",
-- 	callback = function()
-- 		vim.defer_fn(function()
-- 			require("tidal.core.message").sclang.send_line("MIDIClient.init;")
-- 		end, 1000)
-- 	end,
-- })

return {}
