local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

config.keys = {
  {
    key = 'Enter',
    mods = 'ALT',
    action = act.DisableDefaultAssignment,
  },
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
  {
    key = 'd',
    mods = 'SUPER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'SUPER|SHIFT',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '[',
    mods = 'SUPER',
    action = act.ActivatePaneDirection 'Prev'
  },
  {
    key = ']',
    mods = 'SUPER',
    action = act.ActivatePaneDirection 'Next'
  },
  {
    key = 'u',
    mods = 'SUPER',
    action = act.EmitEvent 'toggle-opacity',
  },
}

-- config.color_scheme = 'One Dark (Gogh)'
-- config.color_scheme = 'OneDark (base16)'
-- config.color_scheme = 'OneHalfDark'
-- config.color_scheme = 'nightfox'
-- config.color_scheme = 'nordfox'
-- config.color_scheme = 'duskfox'
-- config.color_scheme = 'Catppuccin Frappe'
-- config.color_scheme = 'Catppuccin Macchiato'
-- config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'rose-pine-moon'
config.color_scheme = 'tokyonight'
-- config.color_scheme = 'nord'

-- https://zenn.dev/paiza/articles/9ca689a0365b05
config.font = wezterm.font_with_fallback({
  { family = "Cica" },
  { family = "Cica", assume_emoji_presentation = true },
})
config.font_size = 16.0

config.window_background_opacity = 0.8
config.macos_window_background_blur = 5

-- https://wezfurlong.org/wezterm/config/appearance.html#styling-inactive-panes
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
end)

-- https://wezfurlong.org/wezterm/config/lua/window/set_config_overrides.html を参考に
wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}

  -- set_config_overrides は文字通り config に対して上書きする値を設定する
  -- 透過度は `config.window_background_opacity = 0.9` を設定しているので
  -- `overrides.window_background_opacity == nil` のとき透過が適用され
  -- `overrides.window_background_opacity == 1.0` で未透過になる
  --
  -- lua はテーブルで nil を割り当てるとキーが存在しないことと同じ扱いになるため
  -- `overrides.window_background_opacity = nil` は `window_background_opacity` の上書きをしないことになるらしい
  if overrides.window_background_opacity then
    overrides.window_background_opacity = nil
  else
    overrides.window_background_opacity = 1.0
  end

  window:set_config_overrides(overrides)
end)

return config
