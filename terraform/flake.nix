{
  description = "Terraform dev environment flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { system, pkgs, ... }:
        let
          pkgs = import ../nix/unfree-pkgs.nix { inherit nixpkgs system; };
          shared = import ../nix/shared.nix { inherit pkgs; };
          terraformPackages = with pkgs; shared.commonPackages ++ [
            terraform
            # awscli2
            tflint
            tflint-plugins.tflint-ruleset-google
            tflint-plugins.tflint-ruleset-aws
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            name = "terraform dev shell";
            packages = terraformPackages;
          };

          # expose terraformPackages for root flake
          packages = builtins.listToAttrs (map
            (pkg: {
              name = pkg.pname or "unnamed";
              value = pkg;
            })
            terraformPackages);

        };
    };
}
