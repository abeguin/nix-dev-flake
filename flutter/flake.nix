{
  description =
    "Nix flake for Flutter breathing exercise app with Python tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    shared-packages.url = "github:abeguin/nix-dev-flake";
  };

  outputs = inputs@{ flake-parts, nixpkgs, shared-packages, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { system, pkgs, ... }:
        let
          shared = import "${shared-packages}/nix/shared.nix" { inherit pkgs; };

          flutterPakages = with pkgs; shared.commonPackages ++ [
            flutter
          ];

        in
        {
          devShells.default = pkgs.mkShell {
            name = "flutter dev shell";
            packages = flutterPakages;
          };

          packages = builtins.listToAttrs (map
            (pkg: {
              name = pkg.pname or "unnamed";
              value = pkg;
            })
            (flutterPakages));
        };
    };
}
