(
  self: super: {
    geosanslight = super.callPackage geosanslight/default.nix { };

    jlink = super.callPackage jlink/default.nix { };
    crosstool-ng = super.callPackage crosstool-ng/default.nix { };
    nrf5x-cli = super.callPackage nrf5x-cli/default.nix { };
    gitlint = super.callPackage gitlint/default.nix { };
    cmake-stable = super.libsForQt5.callPackage cmake-stable/default.nix { };
  }
)
