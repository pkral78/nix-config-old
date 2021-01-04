{ config, pkgs, options, ... }:

{
  imports = [
    ../modules/settings.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  nixpkgs.config = import ../config/nixpkgs.nix;
  nixpkgs.overlays = [ (import ../pkgs/default.nix) ];

  # Using https://nixos.wiki/wiki/Overlays to let the local nix tools
  # get the same overlays as we define in this file
  environment.etc."overlays-compat" = {
    text = ''
      self: super:
      with super.lib;
      let
        eval = import <nixpkgs/nixos/lib/eval-config.nix>;
        paths = (eval {modules = [(import <nixos-config>)];})
          .config.nixpkgs.overlays;
      in
      foldl' (flip extends) (_: super) paths self
    '';
    target = "nixos/overlays-compat/overlays.nix";
  };

  nix.nixPath =
    options.nix.nixPath.default ++
    [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];

  # Set time zone.
  time.timeZone = "Europe/Prague";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bind
    curl
    docker_compose
    git
    gnupg
    mc
    vim
    wget
    xorg.xkill
    usbutils
    pciutils
    hwinfo
    tcpdump
    htop
    rsync
    tpm2-tools
    nixpkgs-fmt
    cntr
  ];

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  nix.useSandbox = "relaxed";
  nix.trustedUsers = ["pkral"];

  environment.variables = {
    #    EDITOR = "urxvt";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.pcscd.enable = false;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # Required because /run/user/1000 tempfs is too small for docker
  services.logind.extraConfig = ''
    RuntimeDirectorySize=8G
  '';

  security.sudo.wheelNeedsPassword = false;

  #programs.zsh.enable = true;

  users.mutableUsers = false;
  users.users.${config.settings.username} = {
    isNormalUser = true;
    createHome = true;
    home = "/home/${config.settings.username}";
    description = "${config.settings.name}";
    extraGroups = [ "audio" "docker" "networkmanager" "wheel" "dialout" ];
    hashedPassword = "$6$EQGBQvubTZ$um26okodYC7rw8SwnJToA.2UxawxO7ZDuf3KsCvTXbDIscDcmTxfx/YzQNYc0EEntbXGSjFA79nuzO5kaNeIz0";
    uid = 1000;
    #openssh.authorizedKeys.keys = "ssh-dss AA xxx" ];
    #openssh.authorizedKeys.keys = [
    #  (builtins.readFile (../personal/ssh + "/${config.settings.profile}/id_rsa.pub"))
    #];
    shell = pkgs.zsh;
  };

  home-manager.users.${config.settings.username} = import ../config/home.nix;
  #  home-manager.users.${config.settings.username}.settings = config.settings;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
