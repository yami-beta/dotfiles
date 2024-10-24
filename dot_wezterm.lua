local wezterm = require 'wezterm'

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
  {
    key = '\\',
    mods = 'ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = 'ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'u',
    mods = 'SUPER',
    action = wezterm.action.EmitEvent 'toggle-opacity',
  },
}

-- config.color_scheme = 'One Dark (Gogh)'
config.color_scheme = 'OneDark (base16)'
-- config.color_scheme = 'nightfox'
-- config.color_scheme = 'nordfox'
-- config.color_scheme = 'duskfox'

-- https://zenn.dev/paiza/articles/9ca689a0365b05
config.font = wezterm.font_with_fallback({
  { family = "Cica" },
  { family = "Cica", assume_emoji_presentation = true },
})
config.font_size = 16.0

config.window_background_opacity = 0.9

-- https://wezfurlong.org/wezterm/config/lua/config/cursor_blink_rate.html
config.cursor_blink_rate = 0

-- https://wezfurlong.org/wezterm/config/appearance.html#styling-inactive-panes
config.inactive_pane_hsb = {
  -- saturation = 0.8,
  brightness = 0.6,
}

return config
