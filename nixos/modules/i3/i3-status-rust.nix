{
  config,
  pkgs,
  ...
}:
{
  programs.i3status-rust = {
    enable = true;
    bars = {
      bottom = {
        blocks = [
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            interval = 60;
            warning = 20.0;
            alert = 10.0;
          }
          {
            block = "memory";
          }
          {
            block = "cpu";
            interval = 1;
          }
          { block = "sound"; }
          {
            block = "battery";
          }
          {
            block = "time";
            interval = 60;
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
          }
        ];
        settings = {
          theme = {
            theme = "solarized-dark";
            overrides = {
              idle_bg = "#123456";
              idle_fg = "#abcdef";
              separator = " ";
            };
          };
        };
        icons = "awesome5";
        theme = "gruvbox-dark";
      };
    };
  };
}
