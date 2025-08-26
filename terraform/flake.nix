{
  description = "Terraform dev environment flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    common-pkgs.url = "github:abeguin/nix-common-packages";
  };

  outputs = { self, nixpkgs, flake-parts, common-pkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { system, pkgs, ... }:
        let
          unfreePkgs = import nixpkgs {
            system = system;
            config.allowUnfree = true;
          };

          commonPackages = builtins.attrValues common-pkgs.packages.${system};

          terraformPackages = [ unfreePkgs.terraform ] ++
            (with pkgs; commonPackages ++ [
              tflint
              # awscli2
              tflint-plugins.tflint-ruleset-google
              tflint-plugins.tflint-ruleset-aws
            ]);
        in
        {
          devShells.default = pkgs.mkShell {
            name = "terraform dev shell";
            packages = terraformPackages;
          };

          # expose packages for root flake
          packages = builtins.listToAttrs (map
            (pkg: {
              name = pkg.pname or "unnamed";
              value = pkg;
            })
            terraformPackages);
        };
    };
}
