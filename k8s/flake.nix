{
  description = "Nix flake for k8s projects";

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
          k8sPackages = with pkgs; commonPackages ++ [
            kubectl
            #helm # helm is not available for aarch64-darwin, please install it with another package manager
            k9s
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            name = "k8s dev shell";
            packages = k8sPackages;
          };

          # expose packages for root flake
          packages = builtins.listToAttrs (map
            (pkg: {
              name = pkg.pname or "unnamed";
              value = pkg;
            })
            k8sPackages);
        };
    };
}
