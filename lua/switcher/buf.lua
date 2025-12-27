local Menu = require('nui.menu')
local NuiLine = require('nui.line')
local NuiText = require('nui.text')
local web_devicons = require('nvim-web-devicons')

local config = require('switcher').config

local popup_options = {
  position = '50%',
  border = {
    style = 'rounded',
    text = {
      top = 'Buffers',
      top_align = 'left'
    }
  },
  win_options = {
    winhighlight = 'Normal:Normal,Cursor:BHCursor'
  }
}

local M = {}

function M.switch()
  if config.switch_on_command then
    vim.cmd [[b#]]
  end

  M.build_menu()
end

function M.get_active_buffers()
  local raw_buffers = vim.api.nvim_command_output('buffers')
  local buffer_list = {}
  local end_pos = 0

  while true do
    local raw_info = ''

    -- check for line breaks
    if raw_buffers:find('\n', end_pos + 1) then
      _, end_pos, raw_info = raw_buffers:find('(.-)\n', end_pos + 1)
      if end_pos == nil then break end
      table.insert(buffer_list, raw_info)
    else
      _, _, raw_info = raw_buffers:find('(.+)', end_pos + 1)
      table.insert(buffer_list, raw_info)
      break
    end
  end

  local buffers = {}

  for _, buffer in pairs(buffer_list) do
    local _, _, buffer_id, buffer_state, buffer_mod, buffer_name = string.find(buffer, '(%d+)%s+(%g+)([%s%g]-)(%b"")')
    _, _, buffer_name = buffer_name:find('"(.+)"') -- Sanitize name
    table.insert(buffers, {id = buffer_id, name = buffer_name, state = buffer_state, mod = buffer_mod})
  end

  return buffers
end

function M.build_menu_lines()
  local buffers = M.get_active_buffers()
  local lines = {}

  table.sort(buffers, function (a, b)
    if a.state:find('%%a') ~= nil then return true end
    if a.state:find('#h') ~= nil and b.state:find('%%a') == nil then return true end
    return false
  end)

  for _, buffer in pairs(buffers) do
    local icon, hi_group = web_devicons.get_icon(buffer.name)
    local filename = buffer.name

    -- Skip filenames like [No Name], [Quickfix List], etc.
    if not buffer.name:find('%b[]') then
      -- Check if file is a dir
      if buffer.name:find('/') then
        _, _, filename = buffer.name:find('[./]-.+/(.+)')
      else
        _, _, filename = buffer.name:find('.-/-(.+)')
      end
    end

    local line = NuiLine({
      NuiText(' '),
      NuiText(config.buffer_opts.show_buffer_id and buffer.id .. ' ' or ''), -- buffer id
      NuiText(config.buffer_opts.show_buffer_state and buffer.state .. ' ' or ''), -- buffer state
      NuiText(icon ~= nil and icon .. ' ' or '', hi_group), -- buffer filetype icon
      NuiText(config.buffer_opts.show_buffer_full_name and buffer.name .. ' ' or filename .. ' '), -- buffer file name
      NuiText(config.buffer_opts.show_buffer_path and buffer.name .. ' ' or ''), -- buffer path
      NuiText(buffer.mod or '', 'Added') -- buffer mod
    })

    table.insert(lines, Menu.item(line, { id = buffer.id }))
  end

  return lines
end

function M.build_menu()
  local menu = Menu(popup_options, {
    lines = M.build_menu_lines(),
    keymap = config.keymaps,
    min_width = config.min_width,
    on_submit = function(item)
      vim.cmd(string.format("b%d", item.id))
    end,
    on_change = function (item, _menu)
      _menu:map('n', 'd', function (_) -- delete/close buffer under cursor
        -- vim.cmd('bdelete ' .. item.id)
        vim.api.nvim_buf_delete(tonumber(item.id), {})
      end, { noremap = true })
    end
  })

  menu:mount()
end

return M
