{ config, pkgs, ... }:

let
  mod = "Mod4";
in
with pkgs.lib;
{
  imports = [
    ../modules/settings.nix
  ];

  nixpkgs.config = import ./nixpkgs.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs.nix;
  nixpkgs.overlays = [(import ../pkgs/default.nix)];

  home.packages = with pkgs; [
    alacritty
#    autocutsel
    autojump
    bc
    file
#    android-studio
#    jetbrains.clion
#    datagrip
#    golang
#    idea-ultimate
#    jetbrains.pycharm-professional
#    webstorm
    coreutils
    feh
    ffmpeg
    firefox
#    gitAndTools.pre-commit
    google-chrome
    brave
    home-manager
    hstr
    ispell
    jq
    killall
    nerdfonts
    openjdk8
    pv
    python38
    python38.pkgs.pip
    python38.pkgs.setuptools
    python38.pkgs.wheel
    stdenv
    tilda
    tmuxinator
    unzip
    zip
    p7zip
#    nix-zsh-completions
    antibody
    vscode
    nitrokey-app
    # Zephyr
    xz
    tk
  ];

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
    pinentryFlavor = "gnome3";
  };
  /*
  programs.emacs.enable = true;
  services.emacs.enable = true;

  home.file.".emacs.d" = {
    source = ./.emacs.d;
    recursive = true;
  };

  home.file."fonts.el" = {
    target = ".emacs.d/config/fonts.el";
    text = ''
      (provide 'fonts)
      (set-frame-font "${config.settings.fontName}-${toString config.settings.fontSize}")
      (setq default-frame-alist '((font . "${config.settings.fontName}-${toString config.settings.fontSize}")))
    '';
  };

  */

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    shortcut = "u";
  };

  programs.ssh = {
    enable = true;
    forwardAgent = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "10m";

    matchBlocks = {
      "photon" = {
        hostname = "photon.kralovi.net";
        user = "pkral";
      };
    };
  };

/*
  home.file."id_rsa" = {
    source = ./. + "/../personal/ssh/${config.settings.profile}/id_rsa";
    target = ".ssh/id_rsa";
  };

  home.file."id_rsa.pub" = {
    source = ./. + "/../personal/ssh/${config.settings.profile}/id_rsa.pub";
    target = ".ssh/id_rsa.pub";
  };
*/

  programs.git = {
    enable = true;
    userName = config.settings.name;
    userEmail = config.settings.email;
    signing = {
      key = "7B88C3748C24D98B";
      signByDefault = false;
    };
    aliases = {
      s = "status -s -uno";
      gl = "log --oneline --graph";
      pullall = "!git pull --rebase && git submodule update --init --recursive";
    };
    ignores = [".#*" "*.desktop" "*.lock"];
    extraConfig = {
      branch.autosetuprebase = "never";
      push.default = "simple";
      gc.autoDetach = false;
      core = {
        autocrlf = "input";
        symlinks = true;
        longpaths = true;
      };
      http.sslVerify = false;
      log = {
        date = "format:%Y-%m-%d %H:%M";
      };
      format = {
        pretty = "format:%C(auto,yellow)%h%C(auto,magenta)% G? %C(auto,blue)%>(16,trunc)%ad %C(auto,green)%<(32,trunc)%ae%C(auto,reset)%s%C(auto,red)% gD% D";
      };

    };
  };

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };


/*
  xsession.enable = true;

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      bars = [
        {
          id = "bar-0";
          position = "top";
          fonts = ["${config.settings.fontName} ${toString config.settings.fontSize}"];
        }
      ];
      keybindings = mkOptionDefault (
        {
          "${mod}+p" = "exec ${pkgs.dmenu}/bin/dmenu_run";
          "${mod}+q" = "reload";
          "${mod}+Control+q" = "restart";
          "${mod}+Shift+q" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
          "${mod}+Shift+c" = "kill";
          "${mod}+Return" = "exec ${config.settings.terminal}";
          "${mod}+Shift+Return" = "exec ${config.settings.terminal} -e tmux";
          "${mod}+Shift+e" = "exec emacsclient -c";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+h" = "focus left";
          "${mod}+u" = "focus parent";
          "${mod}+Shift+U" = "focus child";
          "${mod}+Shift+J" = "move down";
          "${mod}+Shift+K" = "move up";
          "${mod}+Shift+L" = "move right";
          "${mod}+Shift+H" = "move left";
          "${mod}+c" = "layout tabbed";
          "${mod}+x" = "split v";
          "${mod}+z" = "split h";
          "${mod}+space" = "layout toggle splitv splith tabbed";
          "${mod}+y" = "bar mode toggle";
          "${mod}+Shift+N" = "exec \"xterm -e 'sudo nixos-rebuild switch; read -s -k \\?COMPLETE'\"";
          "${mod}+Shift+r" = "nop";
          "${mod}+v" = "nop";
          "${mod}+e" = "nop";
          "${mod}+s" = "nop";
        }
        // optionalAttrs (!config.settings.vm)
        {
          "${mod}+equal" = "workspace next";
          "${mod}+minus" = "workspace prev";
          "${mod}+grave" = "workspace 1";
          "${mod}+Shift+Control+L" = "exec i3lock";
          "XF86AudioRaiseVolume" = "exec --no-startup-id amixer sset Master 5%+ unmute";
          "XF86AudioLowerVolume" = "exec --no-startup-id amixer sset Master 5%- unmute";
          "XF86AudioMute" = "exec --no-startup-id amixer sset Master toggle";
        });
      modes.resize = {
        "h" = "resize shrink width 10 px or 10 ppt";
        "j" = "resize grow height 10 px or 10 ppt";
        "k" = "resize shrink height 10 px or 10 ppt";
        "l" = "resize grow width 10 px or 10 ppt";
        "Escape" = "mode default";
        "Return" = "mode default";
      };
      window.titlebar = false;
    };
    # inexplicably xserver wrapper doesn't set the background image
    extraConfig = ''
      focus_wrapping no
      exec_always "if [[ -e $HOME/.background-image ]]; then feh --bg-scale $HOME/.background-image ; fi"
    '';
  };

  xsession.initExtra =
    if (config.settings.xkbFile != "none" ) then
      let
        xkbFile = ../xkb + "/${config.settings.xkbFile}.xkb";
        compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
          ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${xkbFile} $out
       '';
      in
        "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY"
    else
      "";

  services.screen-locker = {
    enable = !config.settings.vm;
    lockCmd = "i3lock";
  };

  home.file.".Xresources" = {
    target = ".Xresources";
    text = ''
      xterm*faceName: ${config.settings.fontName}
      xterm*faceSize: ${toString config.settings.fontSize}
    '';
  };
  */


/*
programs = {
	zsh = {		
		interactiveShellInit = ''
#			export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
#			
#			# Customize oh-my-zsh options here
#			ZSH_THEME="agnoster"

#			HISTFILESIZE=500000
#			HISTSIZE=500000
#			export HISTFILE=~/.zsh_history			
#			bindkey -s "\C-r" "\eqhstr\n"
#
#			source $ZSH/oh-my-zsh.sh
		'';		
	  };
  };
*/

  programs.zsh = rec {
    enable = true;
#    enableAutosuggestions = false;
    # enabled by oh-my-zsh, this only ensure that compinit is not called twice
    enableCompletion = false;
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      size = 99999;
      path = ".config/zsh/.zsh_history";
    };

#    envExtra = ''
#    ZSH=$ZDOTDIR/oh-my-zsh
#    '';

    initExtraBeforeCompInit = ''
    source $ZDOTDIR/.shared.zshrc
    '';

#    plugins = [
#    ];

#    oh-my-zsh = {
#      enable = true;
#      plugins = ["autojump" "colored-man-pages" "git" "gitignore" "sudo" "docker" "kubectl"];
#      theme = "agnoster";
#    };

    shellAliases = {
      "ll" = "ls -al";
      "ns" = "nix-shell --command zsh";
      "hh" = "hstr";
    };

    initExtra = ''
    # hstr
    setopt hist_expire_dups_first
    setopt hist_ignore_all_dups
    setopt hist_ignore_space
    setopt hist_no_store
    setopt hist_reduce_blanks
    setopt share_history
    setopt magicequalsubst
    bindkey -s "\C-r" "\C-a hstr -- \C-j"
    export HSTR_CONFIG=hicolor
    export HISTFILE=$HISTFILE
    '';

    /*
    initExtra = let
      cdpath = "$HOME/src" +
        optionalString (config.settings.profile != "malloc47")
          " $HOME/src/${config.settings.profile}";
    in
    ''
      hg() { history | grep $1 }
      pg() { ps aux | grep $1 }

      function chpwd() {
        emulate -L zsh
        ls
      }

      cdpath=(${cdpath})
    '';
    */

    sessionVariables = {
#      EDITOR = "vim";
#      HSTR_CONFIG="hicolor";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10";
    };
  };

  programs.bash = {
    enable = true;
    historyFile = "\$HOME/.config/bash/.bash_history";
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../../";
      "...." = "cd ../../../";
      "....." = "cd ../../../../";
      "......" = "cd ../../../../../";
      "ll" = "ls -al";
      "ns" = "nix-shell --command zsh";
    };
    initExtra = ''
      hg() { history | grep "$1"; }
      pg() { ps aux | grep "$1"; }
      cd() { if [[ -n "$1" ]]; then builtin cd "$1" && ls; else builtin cd && ls; fi }
    '';
    sessionVariables = {
#      CDPATH = ".:~/src/" +
#        optionalString (config.settings.profile != "malloc47")
#        ":~/src/${config.settings.profile}";
      EDITOR = "vim";
    };
    shellOptions = [
    "autocd" "cdspell" "dirspell" "globstar" # bash >= 4
    "cmdhist" "nocaseglob" "histappend" "extglob"];
  };

/*
  systemd.user.services.autocutsel = {
    Unit.Description = "AutoCutSel";
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "forking";
      Restart = "always";
      RestartSec = 2;
      ExecStartPre = "${pkgs.autocutsel}/bin/autocutsel -fork";
      ExecStart = "${pkgs.autocutsel}/bin/autocutsel -selection PRIMARY -fork";
    };
  };
  */

  # home.file.".inputrc".source = ./.inputrc;

  # xdg.configFile."alacritty/alacritty.yml".source = ./.alacritty.yml;
  # xdg.configFile."i3status/config".source = ./.i3status.conf;
  # xdg.configFile.".user-dirs.dirs".source = ./.user-dirs.dirs;

/*
  home.file."wifi" = mkIf (!config.settings.vm) {
    target = "bin/wifi";
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${config.settings.terminal} -e nmtui
    '';    
  };
*/  

  home.file = {
    ".config/zsh/.shared.zshrc" = {
      text = ''
      ANTIBODY_HOME="$(antibody home)"
      ZSH_THEME="agnoster"

      plugins=(
        autojump
        colored-man-pages
        docker
        git
        gitignore
        kubectl
        sudo
      )

      export ZSH="$ANTIBODY_HOME/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh"

      # quit bugging me!
      DISABLE_AUTO_UPDATE="true"

      # omz!
      source <(antibody init)
      antibody bundle "
        robbyrussell/oh-my-zsh
        zsh-users/zsh-completions
        spwhitt/nix-zsh-completions
        zdharma/fast-syntax-highlighting
      "

      # TODO Tilda incompatability?
      # marzocchi/zsh-notify 

      setopt auto_cd
      unsetopt correct_all
      setopt no_flow_control
    '';
    };
  };
}
