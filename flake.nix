{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:MIC92/sops-nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        disko.follows = "disko";
      };
    };

    nixgl = {
      url = "github:nix-community/nixGL";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
  };

  outputs = { nix-darwin, home-manager, nix-index-database, nixpkgs, nixgl, hyprland, ... }: {
    darwinConfigurations."mac_arm64" = nix-darwin.lib.darwinSystem {
      modules = [
        nix-index-database.darwinModules.nix-index
        ./macos/default.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.fkoehler = import ./home/default.nix;
          };
        }
      ];
    };

    homeConfigurations = {
      "linux_x64" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [ nixgl.overlay ];
        };
        modules = [
          hyprland.homeManagerModules.default
          nix-index-database.hmModules.nix-index
          ./home/default.nix
          {
            home = {
              username = "fkoehler";
              homeDirectory = "/home/fkoehler";
            };
          }
        ];
      };
      "gha" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          nix-index-database.hmModules.nix-index
          ./home/default.nix
          {
            home = {
              username = "runner";
              homeDirectory = "/home/runner";
            };
          }
        ];
      };
    };
  };
}
