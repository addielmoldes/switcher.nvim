local config = require('switcher.config')

local M = {}

function M.setup(opts)
  opts = opts or {}

  M.config = vim.tbl_deep_extend('force', config, opts)
end

return M
