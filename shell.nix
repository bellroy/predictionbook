{ sources ? import ./nix/sources.nix }:
let
  nixpkgs = import sources.nixpkgs { };
in
nixpkgs.mkShell {
  name = "bellroy-gem-env";
  buildInputs = with nixpkgs; [
    bundler
    libnotify
    niv
    nodejs-10_x
    pkg-config
    postgresql_11
    readline
    ruby_2_7
    zlib
  ]
  ++ (lib.optionals stdenv.hostPlatform.isDarwin [ libiconv darwin.apple_sdk.frameworks.CoreServices ]);
  shellHook = ''
    bundle config --local path "$PWD/vendor/bundle"
  '';
}
