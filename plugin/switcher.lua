vim.api.nvim_create_user_command('SwBuf', function ()
  require('switcher.buf').switch()
end, {})

vim.api.nvim_create_user_command('SwWin', function ()
  require('switcher.win').switch()
end, {})

vim.api.nvim_create_user_command('SwTab', function ()
  require('switcher.tab').switch()
end, {})
