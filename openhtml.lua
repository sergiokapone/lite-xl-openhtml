-- mod-version:3
--
-- openhtml: click a .html / .htm file in the treeview to open it in the
-- default browser. Ctrl+click opens it in the editor instead.

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

local entry = command.map["treeview:open"]
local original = entry.perform
entry.perform = function(...)
  local item = treeview.selected_item
  if item and item.type ~= "dir" then
    local ext = item.abs_filename:lower():match("%.(%w+)$")
    if ext == "html" or ext == "htm" then
      open_external(item.abs_filename)
      return
    end
  end
  return original(...)
end

-- The treeview binds ctrl+click to "new folder", so it never reaches the code
-- above. Take ctrl+click over: on a file open it in the editor, on a folder
-- keep the original behaviour.
command.add(nil, {
  ["openhtml:edit"] = function()
    local item = treeview.hovered_item
    if item and item.type ~= "dir" then
      treeview:set_selection(item)
      core.try(function()
        core.root_view:open_doc(core.open_doc(core.normalize_to_project_dir(item.abs_filename)))
      end)
    else
      command.perform("treeview:new-folder")
    end
  end,
})
keymap.add { ["ctrl+lclick"] = "openhtml:edit" }
