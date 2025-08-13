{
  description = "Nix flake for xfce-winxp-tc";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = with nixpkgs; (lib.genAttrs lib.systems.flakeExposed);
    in
    {
      packages = forAllSystems (
        system: import ./packaging/nix/package.nix (nixpkgs.legacyPackages.${system})
      );
      homeManagerModules.default = import ./packaging/nix/hm.nix;
    };
}
