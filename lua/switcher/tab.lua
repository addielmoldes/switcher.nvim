local Menu = require('nui.menu')
local NuiText = require('nui.text')
local NuiLine = require('nui.line')

local config = require('switcher.config')
local util = require('switcher.util')

local popup_options = {
  position = '50%',
  border = {
    style = 'rounded',
    text = {
      top = 'Tabs',
      top_align = 'left'
    }
  },
  win_options = {
    winhighlight = 'Normal:Normal,Cursor:BHCursor'
  }
}

local M = {}

function M.switch()
  M.build_tab_menu()
end

function M.get_tabpages()
  local tab_list = vim.api.nvim_list_tabpages()
  local valid_tab_list = {}

  for _, tab_id in pairs(tab_list) do
    if vim.api.nvim_tabpage_is_valid(tab_id) then
      table.insert(valid_tab_list, tab_id)
    end
  end

  return valid_tab_list
end

function M.get_wins_by_tab()
  local wins_by_tab = {}

  for _, tab_id in pairs(M.get_tabpages()) do
    local wins = {}
    for _, win_id in pairs(vim.api.nvim_tabpage_list_wins(tab_id)) do
      if vim.api.nvim_win_is_valid(win_id) then
        table.insert(wins, win_id)
      end
    end

    table.insert(wins_by_tab, { [tab_id] = wins })
  end

  vim.print(wins_by_tab)

  return wins_by_tab
end

function M.build_menu_lines()
  local lines = {}

  for _, tab_id in pairs(M.get_tabpages()) do
    local tab_number = vim.api.nvim_tabpage_get_number(tab_id)
    local line = NuiLine({
      NuiText(' '),
      NuiText(string.format('%d ', tab_number))
    })

    table.insert(lines, Menu.item(line, { id = tab_number }))
  end

  return lines
end

function M.build_tab_menu()
  local menu = Menu(popup_options, {
    lines = M.build_menu_lines(),
    keymap = config.keymaps,
    min_width = config.min_width,
    on_submit = function(item)
      vim.api.nvim_set_current_tabpage(item.id)
    end,
    on_change = function (item, _menu)
      _menu:map('n', 'd', function (_) -- close tab under cursor
        local ok, error = pcall(vim.api.nvim_command, string.format('tabclose %d', item.id))

        if not ok then
          _, _, error = error:find('[.:]-(E[%d:]+.+)')
          vim.notify(error, vim.log.levels.ERROR)
        end
      end, { noremap = true })
      _menu:map('n', 'n', function (_)
        vim.cmd [[tabnew]]
        _menu:unmount()
      end)
    end
  })

  menu:mount()
end

return M
