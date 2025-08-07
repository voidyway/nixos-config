{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "palace";
  time.timeZone = "Asia/Riyadh";

  # DON'T FORGET 'passwd'
  users.users.omar = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDD02Y9FLoeScsjEyZ/vgFM5ufW84fkJPbvZzUUaR78Q voidy" # macbook
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDC+r5aiSWMp9a6sOg+zQFseTKAVWZWA3cOXWdKtQYIb u0_a124" # tablet's termux
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };

    ssh = {
      startAgent = true;
      extraConfig = "
      Host github.com
      IdentityFile ~/.ssh/nixos
      ";
    };

    git = {
      enable = true;
      config = {
        init = {
          defaultBranch = "main";
        };
        user = {
          name = "voidyway";
          email = "175210480+voidyway@users.noreply.github.com";
        };
      };

    };
  };

  environment.systemPackages = with pkgs; [
    helix
    nixd
    nixfmt-rfc-style
  ];

  # List services that you want to enable:

  services = {

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

  };

  system.stateVersion = "25.05";
}
