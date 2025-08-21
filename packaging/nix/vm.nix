{ pkgs, ... }:
let
  winxp-tc = (pkgs.callPackage ./package.nix { }).overrideAttrs (old: {
    patches = old.patches ++ [ ./vm-dbus.patch ];
  });
in
{
  boot.initrd.systemd.enable = true;
  boot.loader.grub.enable = true;
  boot.kernelParams = [ "quiet" ];
  boot.plymouth = {
    enable = true;
    theme = "bootvid";
    themePackages = [ winxp-tc ];
  };
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
    ];
    createHome = true;
    initialPassword = "nixos";
  };

  services.upower.enable = true;
  networking.networkmanager.enable = true;
  programs.dconf.enable = true;

  xdg = {
    icons.enable = true;
    menus.enable = true;
    mime.enable = true;
    portal = {
      enable = true;
      config.common.default = "gtk";
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };

  services.displayManager = {
    defaultSession = "wintc";
    sessionPackages = [ winxp-tc ];
  };
  services.xserver = {
    enable = true;
    displayManager = {
      startx.enable = true;
      xserverArgs = [ "-keeptty" ];
      lightdm = {
        enable = true;
        greeter = {
          name = "wintc-logonui";
          package = winxp-tc.xgreeters;
        };
      };
    };
  };
  environment.systemPackages =
    with pkgs;
    with xfce;
    [
      xorg.xinit
      xorg.xauth
      xorg.xorgserver
      xorg.setxkbmap
      xorg.xinput
      libinput

      tumbler
      exo
      xfconf
      xfce4-xkb-plugin
      xfwm4
      xfce4-session
      xfce4-settings
      libxfce4ui
      libxfce4util
      libxfce4windowing
      xfce4-notifyd
      xfce4-icon-theme
      xfce4-pulseaudio-plugin
      xfce4-screensaver
      xfce4-screenshooter
      xfce4-volumed-pulse
      xfce4-power-manager
      garcon

      xfce4-terminal
      xfce4-taskmanager
      mousepad
      ristretto
      thunar
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman

      hicolor-icon-theme

      winxp-tc

      # Some extra packages
      htop
      gdb
    ];

  system.stateVersion = "25.11";
}
