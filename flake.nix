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
      packages = forAllSystems (system: import ./package.nix (nixpkgs.legacyPackages.${system}));
    };
}
