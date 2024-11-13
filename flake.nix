{
  inputs = {
    nix-go = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:matthewdargan/nix-go";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cachix/pre-commit-hooks.nix";
    };
    systems.url = "github:nix-systems/default";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.pre-commit-hooks.flakeModule];
      perSystem = {
        config,
        inputs',
        pkgs,
        ...
      }: rec {
        devShells.default = pkgs.mkShell {
          packages = [inputs'.nix-go.packages.go inputs'.nix-go.packages.golangci-lint];
          shellHook = "${config.pre-commit.installationScript}";
        };
        packages.cam2ip = inputs'.nix-go.legacyPackages.buildGoModule {
          doCheck = false;
          meta.mainProgram = "cam2ip";
          pname = "cam2ip";
          src = ./.;
          vendorHash = "sha256-Ri7n7A6wpXkEB5OIpev/y4gz1FXEKs0KcrhWhlamc38=";
          version = "0.1.6";
        };
        packages.default = packages.cam2ip;
        pre-commit = {
          check.enable = false;
          settings = {
            hooks = {
              alejandra.enable = true;
              deadnix.enable = true;
              statix.enable = true;
            };
            src = ./.;
          };
        };
      };
      systems = import inputs.systems;
    };
}
