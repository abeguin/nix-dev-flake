{
  description = "Nix flake for bun projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { system, pkgs, ... }:
        let
          shared = import ../nix/shared.nix { inherit pkgs; };
          bunPackages = with pkgs; shared.commonPackages ++ [
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
