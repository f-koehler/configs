{
  pkgs,
  lib,
  isWorkstation,
  ...
}: let
  swaync = pkgs.swaynotificationcenter;
  rofi = pkgs.rofi-wayland;
  wezterm = pkgs.wezterm;
  kanshi = pkgs.kanshi;
  waybar = pkgs.waybar;
  swayosd = pkgs.swayosd;
  swaylock = pkgs.swaylock;
in
  lib.mkIf (isWorkstation && pkgs.stdenv.isLinux) {
    programs = {
      swaylock = {
        enable = true;
        package = swaylock;
      };
      waybar = {
        enable = true;
        package = waybar;
        settings = {
          mainBar = {
            height = 22;
            spacing = 15;
            modules-left = ["sway/workspaces" "sway/mode"];
            modules-right = ["custom/notifications" "tray" "clock" "battery#BAT0" "custom/power"];
            tray = {
              spacing = 5;
            };

            "custom/notification" = {
              "tooltip" = false;
              "format" = "{icon}";
              "format-icons" = {
                "notification" = "<span foreground='red'><sup></sup></span>";
                "none" = "";
                "dnd-notification" = "<span foreground='red'><sup></sup></span>";
                "dnd-none" = "";
                "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
                "inhibited-none" = "";
                "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
                "dnd-inhibited-none" = "";
              };
              "return-type" = "json";
              "exec" = "${swaync}/bin/swaync-client -swb";
              "on-click" = "${swaync}/bin/swaync-client -t -sw";
              "on-click-right" = "${swaync}/bin/swaync-client -d -sw";
              "escape" = true;
            };
          };
        };
        style = ''
          * {
            font-family: Cascadia Code NF;
            font-size: 10px;
            margin: 0;
          }
        '';
      };
    };
    wayland.windowManager.sway = rec {
      enable = true;
      systemd = {
        xdgAutostart = true;
      };
      config = {
        bars = [];
        focus.followMouse = false;
        menu = "${rofi}/bin/rofi -show drun";
        modifier = "Mod4";
        terminal = "${wezterm}/bin/wezterm";
        startup = [
          {
            command = "${waybar}/bin/waybar";
          }
          {
            command = "${swaync}/bin/swaync";
          }
          {
            command = "${kanshi}/bin/kanshi";
          }
          {
            command = "${swayosd}/bin/swaysosd-server";
          }
        ];
      };
      extraConfig = ''
        bindsym ${config.modifier}+Shift+n exec ${swaync}/bin/swaync-client -t -sw
        bindsym ${config.modifier}+Shift+z exec ${swaylock}/bin/swaylock
        bindsym ${config.modifier}+Shift+r exec ${pkgs.sway}/bin/swaymsg reload

        bindsym XF86AudioRaiseVolume exec  ${swayosd}/bin/swayosd-client --output-volume raise
        bindsym XF86AudioLowerVolume exec  ${swayosd}/bin/swayosd-client --output-volume lower
        bindsym XF86AudioMute exec         ${swayosd}/bin/swayosd-client --output-volume mute-toggle
        bindsym XF86AudioMicMute exec      ${swayosd}/bin/swayosd-client --input-volume mute-toggle
        bindsym --release Caps_Lock   exec ${swayosd}/bin/swayosd-client --caps-lock
        bindsym XF86MonBrightnessUp   exec ${swayosd}/bin/swayosd-client --brightness raise
        bindsym XF86MonBrightnessDown exec ${swayosd}/bin/swayosd-client --brightness lower
      '';
    };
    services = {
      kanshi = {
        enable = true;
        settings = [
          {
            profile = {
              name = "work";
              outputs = [
                {
                  criteria = "eDP-1";
                  mode = "1920x1200";
                  position = "0,0";
                }
                {
                  criteria = "Lenovo Group Limited LEN L27m-28 U45XPDF3";
                  mode = "1920x1080";
                  position = "0,-1080";
                }
              ];
            };
          }
        ];
      };
      swaync.enable = true;
      swayosd.enable = true;
    };

    home.packages = [kanshi];
  }
