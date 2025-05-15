{
  description = "NixOS configuration of Manu";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nuenv.url = "github:DeterminateSystems/nuenv";
  };

  outputs = inputs @ {
    nixpkgs,
    nixos-hardware,
    nuenv,
    ...
  }: {
    nixosConfigurations = {
      nixosvmai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs =
          inputs
          // {
            myvars.username = "manu";
            myvars.userfullname = "emmanuel vargas";
            myvars.initialHashedPassword = "$7$CU..../....w4NiIh5VZ1PK2xVIBE7570$0KzFUCpIYRzhqSKqyGMASO1fEuN6R7xBX.56ssXeWV7";
            myvars.sshAuthorizedKeys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJc9R8O3PZTpwi6RIqci41CnGuwjs1NxYxpoJ5ZV4LDp vargas@lonitx-vm-ubuntu"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINjaVclo7DZzoNgTowU5PQaTIXclfhTO9yizIIFjd25Y emmanuel.vargas@iress.com"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEG9sbnm7GF7LQ/csbk729YUlu89TSY2mLDmla/tgKGc emmanuel.vargas@gmail.com"
            ];
          };
        modules = [
          {networking.hostName = "nixosvmai";}

          ./configuration.nix

          ../modules/base.nix
          ../modules/nixos/base/i18n.nix
          ../modules/nixos/base/user-group.nix
          ../modules/nixos/base/networking.nix

          ../hosts/nixosvmai/hardware-configuration.nix
          ../hosts/nixosvmai/impermanence.nix
        ];
      };
    };
  };
}
