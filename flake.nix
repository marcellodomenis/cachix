{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    cachix-deploy-flake.url = "github:cachix/cachix-deploy-flake";
    cachix-deploy-flake.inputs.darwin.follows = "darwin";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-utils, darwin, nixpkgs, cachix-deploy-flake }:
    flake-utils.lib.eachDefaultSystem (
      system: {
        defaultPackage = let
          pkgs = import nixpkgs { inherit system; };
          cachix-deploy-lib = cachix-deploy-flake.lib pkgs;
        in
          cachix-deploy-lib.spec {
            agents = {
              dream-machine = cachix-deploy-lib.darwin (
                { pkgs, ... }:
                {
                  networking.hostName = "dream-machine";

                  environment = {
                    systemPackages = with pkgs; [ cachix ];
                  };
                  services = {
                    cachix-agent.enable = true;
                    nix-daemon.enable = true;
                  };

                  nix.package = pkgs.nix;
                }
              );
              # TODO not yet supported
              # marcellodomenis = cachix-deploy-lib.home ({ pkgs, ... }: {});
            };
          };
      }
    );
}
