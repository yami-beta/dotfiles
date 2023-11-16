local wezterm = require 'wezterm'

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
end)

local config = {}

local act = wezterm.action

config.keys = {
  {
    key = 'w',
    mods = 'ALT',
    action = act.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES'
    },
  },
  -- https://wezfurlong.org/wezterm/config/lua/keyassignment/SwitchToWorkspace.html#prompting-for-the-workspace-name
  -- Prompt for a name to use for a new workspace and switch to it.
  {
    key = 'W',
    mods = 'ALT|SHIFT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for current workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          wezterm.mux.rename_workspace(
            window:active_workspace(),
            line
          )

          -- window:perform_action(
          --   act.SwitchToWorkspace {
          --     name = line,
          --   },
          --   pane
          -- )
        end
      end),
    },
  },
}

-- config.color_scheme = 'One Dark (Gogh)'
config.color_scheme = 'OneDark (base16)'
-- config.color_scheme = 'nightfox'
-- config.color_scheme = 'nordfox'
-- config.color_scheme = 'duskfox'

config.font = wezterm.font("Cica")
config.font_size = 16.0

config.window_background_opacity = 0.9

return config
