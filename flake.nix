{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "corne";
        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];

        # boards
        board = "corneish_zen_v2_%PART%";
        parts = [ "left" "right" ];
        # enable for dongle setup
        #extraCmakeFlags = [ "-DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n" ];
        # logging
        #extraWestBuildFlags = [ "-S zmk-usb-logging" ];

        # dongle
        #board = "nice_nano_v2";
        #shield = "corneish_zen_v2_dongle";
        #parts = [ "dongle" ];

        # bt settings reset
        #board = "nice_nano_v2";
        #shield = "settings_reset";
        #parts = [ "left" "right" "dongle" ];

        zephyrDepsHash = "sha256-av76U3haI31dtBPkGIM9DpDml6hFLOBqD7oKg+yxT7c=";
        enableZmkStudio = true;

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
