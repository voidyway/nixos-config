{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = ["amdgpu" "kvm-intel"];

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      intel-media-driver
      vpl-gpu-rt
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.mesa
      driversi686Linux.intel-media-driver
    ];
  };

  networking = {
    networkmanager.enable = true;
    hostName = "nixos";

    # DNS Over HTTPS
    nameservers = ["127.0.0.1" "::1"];
    networkmanager.dns = "none";
  };

  # DNS Over HTTPS
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
      };

      ipv6_servers = true;
      block_ipv6 = false;

      require_dnssec = true;
      require_nolog = true;
      require_nofilter = false;

      server_names = ["cloudflare" "cloudflare-ipv6"];
    };
  };
  systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = "dnscrypt-proxy";

  time.timeZone = "Asia/Riyadh";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
    plasma-systemmonitor
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.voidy = {
    isNormalUser = true;
    description = "voidy";
    extraGroups = ["networkmanager" "wheel" "gamemode" "libvirtd"];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.variables = {
    RUSTICL_ENABLE = "radeonsi";
    ROC_ENABLE_PRE_VEGA = "1";
  };

  fileSystems."/mnt/penguin" = {
    device = "/dev/disk/by-uuid/4c1d31ff-fff7-4637-b348-c58109f5c7d4";
    fsType = "ext4";
    options = [
      "nosuid"
      "nodev"
      "nofail"
      "x-gvfs-show"
      "x-gvfs-name=penguin"
      "noatime"
    ];
  };

  fileSystems."/".options = ["noatime"]; # Main Disk

  programs.firefox.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/voidy/nixos-config";
  };

  programs.starship = {
    enable = true;
    presets = ["no-runtime-versions"];
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["voidy"];
  };

  programs.steam = {
    enable = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
  };

  programs.ssh.startAgent = true;
  programs.gnupg = {
    agent.enable = true;
  };

  programs.gamemode.enable = true;

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = "
    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh\n
    export GPG_TTY=$(tty)
    ";
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    # Apps
    brave
    qalculate-qt
    obs-studio
    kdePackages.kate
    kdePackages.kfind
    kdePackages.filelight
    normcap
    mission-center
    
    # Development
    vscode
    jetbrains.clion
    nil
    alejandra
    clang
    clang-tools
    gcc
    gdb

    # Gaming
    heroic

    # Additional
    aspellDicts.en
    aspellDicts.ar
    kdePackages.breeze # fixes steam cursor
    kdePackages.breeze-gtk
    kdePackages.sddm-kcm
    bibata-cursors
    zsh-fzf-tab
  ];

  fonts = {
    packages = with pkgs; [nerd-fonts.jetbrains-mono ibm-plex dejavu_fonts rubik ubuntu-sans amiri cairo inter iosevka source-sans source-serif source-code-pro];
    fontconfig = {
      subpixel.rgba = "rgb";
      defaultFonts = {
        serif = ["New York" "SF Arabic"];
        sansSerif = ["SF Pro" "SF Arabic"];
        monospace = ["JetBrainsMono Nerd Font"];
        emoji = ["Apple Color Emoji"];
      };
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [virtiofsd];
  };

  # Before changing this value read the documentation for this option
  system.stateVersion = "25.05"; # Did you read the comment?
}
