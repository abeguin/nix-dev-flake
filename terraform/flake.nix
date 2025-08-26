{
  description = "Terraform dev environment flake";

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
          unfree = import pkgs {
            system = system;
            config.allowUnfree = true;
          };
          commonPackages = builtins.attrValues inputs.common-pkgs.packages.${system};
          terraformPackages = [ unfree.terraform ] ++
            (with pkgs; commonPackages ++ [
              terraform
              # awscli2
              tflint
              tflint-plugins.tflint-ruleset-google
              tflint-plugins.tflint-ruleset-aws
            ]);
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
