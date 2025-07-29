{
  description = "Root flake combining Python and Terraform environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    python.url = ./python;
    terraform.url = ./terraform;
    bun.url = ./bun;
    tofu.url = ./opentofu;
    flutter.url = ./flutter;
  };

  outputs = inputs@{ flake-parts, nixpkgs, python, terraform, bun, tofu, flutter, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { system, ... }:
        let
          pkgs = import ./nix/unfree-pkgs.nix { inherit nixpkgs system; };
          shared = import ./nix/shared.nix { inherit pkgs; };

          terraformPkgs = builtins.attrValues terraform.packages.${system};
          pythonPkgs = builtins.attrValues python.packages.${system};
          tofuPkgs = builtins.attrValues tofu.packages.${system};
          bunPkgs = builtins.attrValues bun.packages.${system};
          flutterPkgs = builtins.attrValues flutter.packages.${system};

          combined = pkgs.lib.lists.unique (shared.commonPackages ++
            pythonPkgs ++
            terraformPkgs ++
            tofuPkgs ++
            bunPkgs ++
            flutterPkgs
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

          devShells.python = python.devShells.${system}.default;
          devShells.terraform = terraform.devShells.${system}.default;
          devShells.tofu = tofu.devShells.${system}.default;
          devShells.bun = bun.devShells.${system}.default;
          devShells.flutter = flutter.devShells.${system}.default;
        };
    };
}
