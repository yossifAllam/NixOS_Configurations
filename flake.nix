{
  description = "My NixOS and Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, winapps, ... }:
    {
      nixosConfigurations.Alfy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/Alfy/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.yossif = import ./home/yossif/home.nix;
          }
          {
            nix.settings = {
              substituters = [ "https://winapps.cachix.org/" ];
              trusted-public-keys = [
                "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="
              ];
            };

            environment.systemPackages = [
              winapps.packages."x86_64-linux".winapps
              winapps.packages."x86_64-linux".winapps-launcher
            ];
          }
        ];
      };

      # Optional: Home Manager standalone config (non-NixOS)
      homeConfigurations."yossif@Alfy" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [ ./home/yossif/home.nix ];
        username = "yossif";
        homeDirectory = "/home/yossif";
      };
    }
    // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.git pkgs.nixfmt ];
        };
      });
}
