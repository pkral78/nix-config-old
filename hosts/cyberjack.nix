{ config, pkgs, ... }: rec {
  imports = [
    ../nixos/configuration.nix
    ../hardware/thinkpad-t440p.nix
    ../modules/settings.nix
  ];

  settings = {
    #xkbFile = "macbook-modified";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #networking.hostId = "aca3f499";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;
  networking.interfaces.wwp0s20u10i6.useDHCP = true;

  networking.hostName = "cyberjack";
  networking.networkmanager.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    podman-compose
    dropbox-cli
    fwupd
    gnome3.gnome-tweaks
    gnome3.gnome-shell-extensions
    binutils-unwrapped
    (ripgrep.override { withPCRE2 = true; })
    gnutls
    fd
    imagemagick
    zstd
    sqlite
  ];

  virtualisation = {
    #      containers.users = [ "pkral" ];
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  services.fwupd.enable = true;

  networking.extraHosts = ''
    #1.2.3.4 jetbrains.com www.jetbrains.com account.jetbrains.com www-weighted.jetbrains.com
    10.30.10.10 gitlab.wn-cz.local
    10.30.0.63 jira.wn-cz.local
    10.30.0.69 confluence.wn-cz.local
  '';

  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    # 5678 - Cisco Discovery Protocol
    # 20561 - MAC Telnet
    allowedUDPPorts = [ 17500 5678 ];
    trustedInterfaces = [ "enp0s31f6" "wlp82s0" ];
  };

  services.xserver = {
    enable = true;
    autorun = false;
    layout = "us";
    xkbOptions = "eurosign:e";
    #    autoRepeatDelay = 250;
  };

  services.xserver.desktopManager = {
    xterm.enable = false;
    gnome.enable = true;
  };

  services.xserver.displayManager = {
    sessionCommands = ''
      ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER
    '';
    gdm = {
      enable = true;
      wayland = false;
      autoSuspend = false;
    };
  };

  # Android ADB setup
  programs.adb.enable = true;
  users.users.${config.settings.username}.extraGroups = [ "adbusers" ];
  services.udev.packages = [ pkgs.android-udev-rules pkgs.jlink ];

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 5";
      }
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 5";
      }
    ];
  };

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.trezord.enable = true;

  #  warnings = ["${services.logind.extraConfig}"];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # cyberjack specific packages
  home-manager.users.${config.settings.username} = {

    home.packages = with pkgs; [
      jlink
      nerdfonts
      feh
      firefox
      google-chrome
      brave
      nitrokey-app
      slack
      sublime-merge-dev
      remmina
      tilda
      thunderbird
      libreoffice-fresh
      vlc
      wine
      tdesktop
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        background_opacity = 0.95;

        window = {
          padding.x = 0;
          padding.y = 0;
          #decorations = "none";
        };

        font = {
          size = 11.0;
          use_thin_strokes = true;

          normal.family = "DejaVuSansMono Nerd Font Mono";
          bold.family = "DejaVuSansMono Nerd Font Mono";
          italic.family = "DejaVuSansMono Nerd Font Mono";
        };

        cursor.style = "Beam";

        colors = {
          # Blood-moon
          # https://github.com/dguo/blood-moon/blob/master/applications/alacritty/blood-moon.yml
          primary = {
            background = "0x10100E";
            foreground = "0xC6C6C4";
          };

          # Normal colors
          normal = {
            black = "0x10100E";
            red = "0xC40233";
            green = "0x009F6B";
            yellow = "0xFFD700";
            #      blue =    "0x0087BD";
            blue = "0x123e7c";
            magenta = "0x9A4EAE";
            cyan = "0x20B2AA";
            white = "0xC6C6C4";
          };

          # Bright colors
          bright = {
            black = "0x696969";
            red = "0xFF2400";
            green = "0x03C03C";
            yellow = "0xFDFF00";
            blue = "0x007FFF";
            magenta = "0xFF1493";
            cyan = "0x00CCCC";
            white = "0xFFFAFA";
          };
        };
      };
    };

    # TODO vscode
    # .config/Code/User/settings.json:
    # {
    # "remote.extensionKind": { "ms-azuretools.vscode-docker": "workspace" }
    #
    programs.vscode = {
      enable = true;
      # see https://discourse.nixos.org/t/vscode-with-extensions-and-settings-using-home-manager/5747/2
      #    userSettings = {
      #      "window.zoomLevel" = 1;
      #      "git.autofetch" = false;
      #      "diffEditor.ignoreTrimWhitespace" = true;
      #      "gitlens.advanced.messages" = {
      #        "suppressFileNotUnderSourceControlWarning" = true;
      #      };
      #      "files.exclude" = {
      #        "**/.classpath" = true;
      #        "**/.project" = true;
      #        "**/.settings" = true;
      #      };
      #      "remote.SSH.defaultExtensions" = [
      #        "eamodio.gitlens"
      #      ];
      #    };
      # extensions = with pkgs.vscode-extensions; [
      #   bbenoist.Nix
      #   ms-vscode-remote.remote-ssh
      #   ms-azuretools.vscode-docker
      # ];
    };

    programs = {
      mbsync.enable = true;
      msmtp.enable = true;
      notmuch = {
        enable = true;
        hooks = { preNew = "mbsync --all"; };
      };
    };

    accounts.email = import ../private/accounts.nix;

    services.gpg-agent = {
      enable = true;
      enableScDaemon = false;
      enableSshSupport = true;
      defaultCacheTtl = 1800;
      pinentryFlavor = "gnome3";
    };
  };

  fonts.fonts = with pkgs; [
    corefonts
    geosanslight
    inconsolata
    libertine
    libre-baskerville
    (nerdfonts.override {
      fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ];
    })
  ];

}
