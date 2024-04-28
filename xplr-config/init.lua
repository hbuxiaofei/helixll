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
    local i = 0
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

local function render_right_pane(ctx)
    local node = ctx.app.focused_node
    if is_dir(node) then
        return ""
    end

    local abs_path = ctx.app.focused_node.absolute_path

    if node.is_symlink then
        if node.is_broken then
            return ""
        else
            abs_path = node.symlink.absolute_path
        end
    end

    if is_text_file(abs_path) then
        return abs_path .. "\n\n" .. read(abs_path, 100)
    end

    return abs_path
end

local args = {}
args.right_pane_renderer = args.right_pane_renderer or render_right_pane

local xplr = xplr
xplr.fn.custom.tri_pane = {}

xplr.fn.custom.tri_pane.render_right_pane = args.right_pane_renderer


local right_pane = {
  CustomContent = {
    body = {
      DynamicParagraph = {
        render = "custom.tri_pane.render_right_pane",
      },
    },
  },
}

xplr.config.layouts.builtin.default = {
  Horizontal = {
    config = {
      margin = 1,
      horizontal_margin = 1,
      vertical_margin = 1,
      constraints = {
        { Percentage = 50 },
        { Percentage = 50 },
      }
    },
    splits = {
      "Table",
      right_pane ,
    }
  }
}

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

