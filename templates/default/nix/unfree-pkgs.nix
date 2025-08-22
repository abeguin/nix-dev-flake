{ nixpkgs, system }:
  import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  }