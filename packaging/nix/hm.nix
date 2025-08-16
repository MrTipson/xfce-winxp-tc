{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
  cfg = config.win-tc;
in
{
  options.win-tc = {
    enable = lib.mkEnableOption "Windows XP total conversion mod" // {
      default = cfg.package != null;
    };

    package = mkOption {
      description = "Package to use for themes and components";
      default = null;
      type = types.nullOr types.package;
    };

    cursor = mkOption {
      description = "Package to use for themes and components";
      default = "Windows XP Standard";
      type = types.nullOr (
        types.enum [
          "Windows XP Standard"
          "Windows XP Standard (with pointer shadows)"
        ]
      );
    };

    icons = mkOption {
      description = "Icon set to use";
      default = "luna";
      type = types.nullOr (types.enum [ "luna" ]);
    };

    theme = mkOption {
      description = "Theme to use";
      default = "Windows XP style (Blue)";
      type = types.nullOr (
        types.enum [
          "Professional"
          "Windows Classic style"
          "Windows XP style (Blue)"
          "Windows XP style (Olive Green)"
          "Windows XP style (Silver)"
          "Zune style"
        ]
      );
    };

    installApplications = lib.mkEnableOption "optional applications" // {
      default = true;
    };

    enableFonts = lib.mkEnableOption "fonts" // {
      default = true;
    };

    enableSounds = lib.mkEnableOption "sound theme" // {
      default = true;
    };

    enableShortcuts = lib.mkEnableOption "shortcuts" // {
      default = true;
    };

    SKU = mkOption {
      description = "Which SKU to use";
      default = "xpclient-pro";
      type = types.nullOr (
        types.enum [
          # CLIENT
          "xpclient-per"
          "xpclient-pro"
          "xpclient-linux"
          "xpclient-mce"
          "xpclient-tabletpc"
          "xpclient-starter"
          "xpclient-embedded"
          "xpclient-flp"
          "xpclient-wepos"
          "xpclient-wes"
          "xpclient-posready"
          # SERVER
          "dnsrv-std"
          "dnsrv-ent"
          "dnsrv-dtc"
          "dnsrv-app"
          "dnsrv-bla"
          "dnsrv-sbs"
          "dnsrv-ccs"
          # SERVER R2
          "dnsrv_r2-std"
          "dnsrv_r2-ent"
          "dnsrv_r2-dtc"
          "dnsrv_r2-ss"
          "homesrv"
        ]
      );
    };
  };

  config = lib.mkIf (cfg.enable && cfg.package != null) (
    let
      pkg = cfg.package.overrideAttrs (old: {
        sku = cfg.SKU;
      });
    in
    lib.mkMerge [
      {
        xfconf.settings = {
          "xfwm4" = {
            "general/title_alignment" = "left";
            "general/show_dock_shadow" = false;
            "general/show_popup_shadow" = false;
            "general/show_app_icon" = false;
          };
          "xsettings"."Gtk/DecorationLayout" = "icon,menu:minimize,maximize,close";
        };
        xdg.mime.enable = true;
        home.packages = [ pkg ];
      }

      (lib.mkIf (cfg.cursor != null) ({
        home.pointerCursor = {
          enable = true;
          x11.enable = true;
          name = cfg.cursor;
          package = pkg;
        };
        xfconf.settings."xsettings"."Gtk/CursorThemeName" = cfg.cursor;
      }))

      (lib.mkIf (cfg.icons != null) ({
        gtk.gtk3.iconTheme = {
          name = cfg.icons;
        };
        xfconf.settings."xsettings"."Net/IconThemeName" = cfg.icons;
      }))

      (lib.mkIf (cfg.theme != null) {
        gtk.gtk3.theme = {
          name = cfg.theme;
        };
        xfconf.settings."xsettings" = {
          "Net/ThemeName" = cfg.theme;
          "Xfce/SyncThemes" = true;
        };
      })

      (lib.mkIf cfg.enableFonts {
        fonts.fontconfig.enable = true;
        home.packages = [ pkgs.dejavu_fonts ];
        xfconf.settings = {
          "xfwm4"."general/title_font" = "Trebuchet MS Bold 10";
          "xsettings" = {
            "Gtk/FontName" = "Tahoma Regular 8";
            "Xft/Antialias" = 1;
            "Xft/Hinting" = 1;
            "Xft/HintStyle" = "hintfull";
          };
        };
      })

      (lib.mkIf cfg.enableSounds {
        xfconf.settings."xsettings" = {
          "Net/EnableEventSounds" = true;
          "Net/EnableInputFeedbackSounds" = true;
          "Net/SoundThemeName" = "Windows XP Default";
        };
      })

      (lib.mkIf cfg.enableShortcuts {
        xfconf.settings."xfce4-keyboard-shortcuts" = {
          "commands/custom/<Super>r" = "run";
          "commands/custom/<Alt>F1" = "wintc-taskband --start";
        };
      })
    ]
  );
}
