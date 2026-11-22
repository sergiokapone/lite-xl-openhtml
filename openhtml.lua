-- mod-version:3
--
-- openhtml: Ctrl+click on a .html / .htm file in the treeview opens it in the
-- default browser. A plain click still opens it in the editor.

local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local treeview = require "plugins.treeview"

local function open_external(target)
  local cmd
  if PLATFORM == "Windows" then cmd = { "cmd", "/c", "start", "", target }
  elseif PLATFORM == "Mac OS X" then cmd = { "open", target }
  else cmd = { "xdg-open", target } end
  local ok, err = pcall(process.start, cmd)
  if not ok then core.error("openhtml: %s", tostring(err)) end
end

-- The treeview binds ctrl+click to "new folder", so take it over: on an html
-- file open the browser, anywhere else keep the original behaviour.
command.add(nil, {
  ["openhtml:browser"] = function()
    local item = treeview.hovered_item
    local ext = item and item.type ~= "dir" and item.abs_filename:lower():match("%.(%w+)$")
    if ext == "html" or ext == "htm" then
      treeview:set_selection(item)
      open_external(item.abs_filename)
    else
      command.perform("treeview:new-folder")
    end
  end,
})
keymap.add { ["ctrl+lclick"] = "openhtml:browser" }
