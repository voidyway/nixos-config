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

  # networking.hostName = "palace";
  networking = {
    hostName = "palace";
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    networkmanager.enable = true;
    networkmanager.dns = "none";

  };

  time.timeZone = "Asia/Riyadh";

  users.users.omar = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
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
        export COLORTERM="truecolor" # fix iterm2 ssh colors
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

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/omar/nixos-config";
    };

  };

  environment.systemPackages = with pkgs; [
    helix
    nixd
    nixfmt-rfc-style
  ];

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    stubby = {
      enable = true;
      settings = pkgs.stubby.passthru.settingsExample // { # The default settings are available at pkgs.stubby.passthru.settingsExample
        upstream_recursive_servers = [
          {
            address_data = "1.1.1.1";
            tls_auth_name = "cloudflare-dns.com";
            tls_pubkey_pinset = [
              {
                digest = "sha256";
                value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA=";
              }
            ];
          }
          {
            address_data = "1.0.0.1";
            tls_auth_name = "cloudflare-dns.com";
            tls_pubkey_pinset = [
              {
                digest = "sha256";
                value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA=";
              }
            ];
          }
        ];
      };
    };

  };

  system.stateVersion = "25.05";
}
