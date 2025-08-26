{
  description = "Nix flake for bun projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    common-pkgs.url = "github:abeguin/nix-common-packages";
  };

  outputs = { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { system, pkgs, ... }:
        let
          commonPackages = builtins.attrValues inputs.common-pkgs.packages.${system};
          bunPackages = with pkgs; commonPackages ++ [
            bun
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            name = "bun dev shell";
            packages = bunPackages;
          };

          # expose packages for root flake
          packages = builtins.listToAttrs (map
            (pkg: {
              name = pkg.pname or "unnamed";
              value = pkg;
            })
            bunPackages);
        };
    };
}
