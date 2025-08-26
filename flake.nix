{
  description = "Root flake combining Python and Terraform environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    common-pkgs.url = "github:abeguin/nix-common-packages";
    python.url = ./python;
    terraform.url = ./terraform;
    bun.url = ./bun;
    tofu.url = ./opentofu;
  };



  outputs = { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      flake = {
        templates = {
          bun = {
            path = ./bun;
            description = "Bun flake";
          };
          opentofu = {
            path = ./opentofu;
            description = "Opentofu flake";
          };
          python = {
            path = ./python;
            description = "Python flake";
          };
          terraform = {
            path = ./terraform;
            description = "Terraform flake";
          };
        };
      };
      perSystem = { system, pkgs, ... }:
        let
          commonPackages = builtins.attrValues inputs.common-pkgs.packages.${system};
          terraformPkgs = builtins.attrValues inputs.terraform.packages.${system};
          pythonPkgs = builtins.attrValues inputs.python.packages.${system};
          tofuPkgs = builtins.attrValues inputs.tofu.packages.${system};
          bunPkgs = builtins.attrValues inputs.bun.packages.${system};

          combined = pkgs.lib.lists.unique (commonPackages ++
            pythonPkgs ++
            terraformPkgs ++
            tofuPkgs ++
            bunPkgs
          );
        in
        {
          devShells.default = pkgs.mkShell {
            name = "combined-shell";
            packages = combined;

            shellHook = ''
              echo "combined dev shell is ready !"
              echo "combined packages:"
              ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - ${pkg.pname or "?"}") combined}
            '';
          };

          devShells.python = inputs.python.devShells.${system}.default;
          devShells.terraform = inputs.terraform.devShells.${system}.default;
          devShells.tofu = inputs.tofu.devShells.${system}.default;
          devShells.bun = inputs.bun.devShells.${system}.default;
        };
    };
}
