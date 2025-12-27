local web_devicons = require('nvim-web-devicons')

local M = {}

function M.get_buffer_icon_and_name(buffer_name)
  local icon, hi_group = web_devicons.get_icon(buffer_name)
  local filename = buffer_name

  -- Skip filenames like [No Name], [Quickfix List], etc.
  if not buffer_name:find('%b[]') then
    -- Check if file is a dir
    if buffer_name:find('/') then
      _, _, filename = buffer_name:find('[./]-.+/(.+)')
    else
      _, _, filename = buffer_name:find('.-/-(.+)')
    end
  end

  return icon, hi_group, filename
end

return M
