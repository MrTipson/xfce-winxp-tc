{ pkgs, ... }:
{
  services.xserver.desktopManager.xfce.enable = true;
  environment.systemPackages = [ (pkgs.callPackage ./package.nix { }) ];
}
