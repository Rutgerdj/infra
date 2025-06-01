{
  config,
  pkgs,
  ...
}:
let
  mod = "Mod4";
in
{
  home.packages = with pkgs; [
    brightnessctl
    arandr
    rofi
    dmenu
    clipmenu
    font-awesome
    intel-gpu-tools
    playerctl
    xorg.xev
  ];

  home.file.".config/i3/scripts".source = ./scripts;
  home.file.".config/i3/scripts".recursive = true;

  imports = [
    ./i3-status-rust.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      startup = [
        {
          command = "xrandr --newmode \"3440x1440_60.00\"  319.75  3440 3600 3952 4464  1440 1443 1453 1483 -hsync +vsync";
          always = true;
        }
        {
          command = "xrandr --addmode HDMI-1 \"3440x1440_60.00\"";
          always = true;
        }
        {
          command = "exec --no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet";
          always = true;
        }
        {
          command = "exec --no-startup-id ${pkgs.blueman}/bin/blueman-applet";
          always = true;
        }
        {
          command = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ 1";
          always = true;
        }
      ];

      window = {
        titlebar = true;
        border = 2;
      };

      modes = {
        resize = {
          Down = "resize grow height 10 px or 10 ppt";
          Escape = "mode default";
          Left = "resize shrink width 10 px or 10 ppt";
          Return = "mode default";
          Right = "resize grow width 10 px or 10 ppt";
          Up = "resize shrink height 10 px or 10 ppt";
        };
      };

      colors = {
        focused = {
          border = "#013220"; # dark green border
          background = "#005f00";
          text = "#ffffff";
          indicator = "#005f00";
          childBorder = "#005f00";
        };
      };

      workspaceLayout = "tabbed";
      bars = [
        {
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
          position = "bottom";
          fonts = {
            size = 12.0;
          };
          colors.background = "#001e26";
          colors.statusline = "#708183";
          # trayOutput = "\*";
        }
      ];

      modifier = mod;
      keybindings = {
        "${mod}+Shift+e" = "exec i3-msg exit";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+d" = "exec ${pkgs.grobi}/bin/grobi update";
        "${mod}+Shift+r" = "restart";
        "${mod}+Shift+l" = "exec --no-startup-id xflock4";
        "${mod}+Return" = "exec i3-sensible-terminal";

        "XF86AudioRaiseVolume" =
          "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" =
          "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@  -5%";
        "XF86AudioMute" =
          "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@  toggle";
        "XF86AudioMicMute" =
          "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@  toggle";

        "XF86AudioPlay" = "exec --no-startup-id ~/.config/i3/scripts/exec_for_all_players.sh play-pause";
        "XF86AudioNext" = "exec --no-startup-id ~/.config/i3/scripts/exec_for_all_players.sh next";
        "XF86AudioPrev" = "exec --no-startup-id ~/.config/i3/scripts/exec_for_all_players.sh previous";
        "XF86HomePage" =
          "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl --player=spotify --player=com.unicornsonlsd.finamp previous";
        "XF86Mail" =
          "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl --player=spotify --player=com.unicornsonlsd.finamp next";

        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";

        "Print" = "exec --no-startup-id flameshot gui";

        # "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show combi -combi-modi window#run#ssh -modi combi";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show run";
        "${mod}+Shift+q" = "kill";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+r" = "mode resize";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        "${mod}+1" = "workspace 1";
        "${mod}+2" = "workspace 2";
        "${mod}+3" = "workspace 3";
        "${mod}+4" = "workspace 4";
        "${mod}+5" = "workspace 5";
        "${mod}+6" = "workspace 6";
        "${mod}+7" = "workspace 7";
        "${mod}+8" = "workspace 8";
        "${mod}+9" = "workspace 9";
        "${mod}+0" = "workspace 10";

        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+2" = "move container to workspace 2";
        "${mod}+Shift+3" = "move container to workspace 3";
        "${mod}+Shift+4" = "move container to workspace 4";
        "${mod}+Shift+5" = "move container to workspace 5";
        "${mod}+Shift+6" = "move container to workspace 6";
        "${mod}+Shift+7" = "move container to workspace 7";
        "${mod}+Shift+8" = "move container to workspace 8";
        "${mod}+Shift+9" = "move container to workspace 9";
        "${mod}+Shift+0" = "move container to workspace 10";

        "${mod}+Ctrl+Left" = "move workspace to output left";
        "${mod}+Ctrl+Right" = "move workspace to output right";
        "${mod}+Ctrl+Up" = "move workspace to output up";
        "${mod}+Ctrl+Down" = "move workspace to output down";
      };
    };
  };
}
