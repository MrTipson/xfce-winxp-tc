{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
  cfg = config.win-tc;
  pkg = cfg.package;

in
{
  options.win-tc = {
    enable = lib.mkEnableOption "Windows XP total conversion mod" // {
      default = cfg.package != null;
    };

    package = mkOption {
      description = "Package to use for themes and components";
      default = null;
      type = types.nullOr types.attrs;
    };

    cursor = mkOption {
      description = "Package to use for themes and components";
      default = "no-shadow";
      type = types.nullOr (
        types.enum [
          "no-shadow"
          "with-shadow"
        ]
      );
    };

    icons = mkOption {
      description = "Icon set to use";
      default = "no-shadow";
      type = types.nullOr (types.enum [ "luna" ]);
    };

  };
}
