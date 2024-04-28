-- See:
--   https://github.com/sayanarijit/tri-pane.xplr
--   https://xplr.dev/en/layouts

version = '0.21.7'

xplr.config.node_types.directory.meta.icon = ""
xplr.config.node_types.file = { meta = { icon = "" } }

local function is_text_file(path)
    local file = io.open(path, "rb")
    if not file then
        return false
    end

    local is_text = true
    local i = 1
    local max_bytes = 1024

    for i = 1, max_bytes do
        local byte = file:read(1)
        if not byte then
            break
        end

        local char_code = string.byte(byte)
        if char_code < 32 and char_code ~= 9 and char_code ~= 10 and char_code ~= 13 then
            is_text = false
            break
        end
    end

    file:close()
    return is_text
end

local function read(path, height)
  if not is_text_file(path) then
      return nil
  end

  local p = io.open(path)

  if p == nil then
    return nil
  end

  local i = 0
  local res = ""
  for line in p:lines() do
    -- if line:match("[^ -~\n\t]") then
      -- p:close()
      -- return
    -- end

    res = res .. line .. "\n"
    if i == height then
      break
    end
    i = i + 1
  end
  p:close()

  return res
end

local function is_dir(n)
  return n.is_dir or (n.symlink and n.symlink.is_dir)
end

local function stat(node)
  return xplr.util.to_yaml(xplr.util.node(node.absolute_path))
end

xplr.fn.custom.preview_pane = {}
xplr.fn.custom.preview_pane.render = function(ctx)
  local title = nil
  local body = ""
  local n = ctx.app.focused_node
  if n and n.canonical then
    n = n.canonical
  end

  if n then
    title = { format = n.absolute_path, style = xplr.util.lscolor(n.absolute_path) }
    if n.is_file then
      body = read(n.absolute_path, ctx.layout_size.height) or stat(n)
    else
      body = stat(n)
    end
  end

  return { CustomParagraph = { ui = { title = title }, body = body } }
end

local preview_pane = { Dynamic = "custom.preview_pane.render" }
local split_preview = {
  Horizontal = {
    config = {
      constraints = {
        { Percentage = 50 },
        { Percentage = 50 },
      },
    },
    splits = {
      "Table",
      preview_pane,
    },
  },
}

-- xplr.config.layouts.builtin.default =
    -- xplr.util.layout_replace(xplr.config.layouts.builtin.default, "Table", split_preview)

xplr.config.layouts.builtin.default = split_preview

local home = os.getenv("HOME")
package.path = home
  .. "/.config/xplr/plugins/?/init.lua;"
  .. home
  .. "/.config/xplr/plugins/?.lua;"
  .. package.path

require("tree-view").setup({
    as_initial_layout = true,

    focus_next_key = "down",

    focus_prev_key = "up",
})

