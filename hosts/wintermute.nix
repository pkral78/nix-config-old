{ config, pkgs, ... }: rec {
  imports = [
    ../config/common.nix
    ../hardware/workstation.nix
    ../modules/settings.nix
  ];

  settings = {
    #xkbFile = "macbook-modified";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "wintermute";
  networking.interfaces.enp6s0.useDHCP = true;
  #networking.interfaces.enp7s0f1.useDHCP = true;
  #networking.firewall.trustedInterfaces = [ "enp6s0"];

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
    virtualbox = {
       host.enable = true;
       host.enableExtensionPack = true;
    };
  };

  users.extraGroups.vboxusers.members = [ "${config.settings.username}" ];
  services.fwupd.enable = true;
  services.getty.autologinUser = "${config.settings.username}";

  services.xserver = {
    enable = true;
    autorun = true;
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

    autoLogin = {
	enable = true;
	user = "${config.settings.username}";
    };

    gdm = {
      enable = false;
      wayland = false;
      autoSuspend = false;
    };
  };

  /* services.xserver.desktopManager = {
         default = "none";
         xterm.enable = false;
     #  default = "xfce";
     #  xfce = {
     #    enable= true;
     #    noDesktop = true;
     #    enableXfwm = false;
     #  };
       };

       services.xserver.displayManager.lightdm = {
       enable = true;
       greeter.enable = false;
       autoLogin.enable = true;
       autoLogin.user = "${config.settings.username}";
       };

       services.xserver.windowManager = {
         default = "i3";
       i3 = {
         enable = true;
         package = pkgs.i3-gaps;
         extraPackages = with pkgs; [
           dmenu
           i3status
           i3lock
       #    i3blocks
         ];
       };
       };
  */

  # Android ADB setup
  programs.adb.enable = true;
  users.users.${config.settings.username}.extraGroups = [ "adbusers" ];
  services.udev.packages = [ 
    pkgs.android-udev-rules 
    #pkgs.jlink 
  ];

  programs.steam.enable = true;
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

  fileSystems."/mnt/nas" = {
    device = "//nas/share";
    fsType = "cifs";
    options = [
      "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${
        toString ../private/smb_creds_nas
      },uid=nobody,gid=nogroup,iocharset=utf8,noperm"
    ];
  };

  fileSystems."/mnt/share" = {
    device = "//photon/public";
    fsType = "cifs";
    options = [
      "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${
        toString ../private/smb_creds_share
      },uid=nobody,gid=nogroup,iocharset=utf8,noperm"
    ];
  };

  fileSystems."/mnt/omsquare" = {
    device = "//share.omsquare.com/public";
    fsType = "cifs";
    options = [
      "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,guest,uid=nobody,gid=nogroup,iocharset=utf8,noperm"
    ];
  };

  # shodan specific packages
  home-manager.users.${config.settings.username} = {

    home.packages = with pkgs; [
      #jlink
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
      #libreoffice
      vlc
      wine
      tdesktop
      wireshark

      alacritty
      openjdk8
      discord
      sqlitebrowser
      zim
      stm32cubemx
      trezor-suite
      ledger-live-desktop
      jetbrains.pycharm-community
      jetbrains.idea-community
      jetbrains.webstorm
      android-studio
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