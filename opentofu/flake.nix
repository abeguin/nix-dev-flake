{
  description = "Nix flake for opentofu projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { system, pkgs, ... }:
        let
          shared = import ../nix/shared.nix { inherit pkgs; };
          tofuPackages = with pkgs; shared.commonPackages ++ [
            opentofu
            #awscli2
            tflint
            tflint-plugins.tflint-ruleset-google
            tflint-plugins.tflint-ruleset-aws
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            name = "tofu dev shell";
            packages = tofuPackages;
          };

          # expose packages for root flake
          packages = builtins.listToAttrs (map
            (pkg: {
              name = pkg.pname or "unnamed";
              value = pkg;
            })
            tofuPackages);
        };
    };
}
