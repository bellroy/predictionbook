{ sources ? import ./nix/sources.nix
, system ? builtins.currentSystem
}:
let
  nixpkgs = import sources.nixpkgs { inherit system; };
  ruby = nixpkgs.ruby_3_1.override { };
  bundler = nixpkgs.bundler.override { inherit ruby; };
in
nixpkgs.mkShell {
  name = "bellroy-prediction-book-env";
  buildInputs = with nixpkgs; [
    # bundler
    libnotify
    niv
    pkg-config
    postgresql_12
    readline
    ruby
    zlib
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv darwin.apple_sdk.frameworks.CoreServices ];
  shellHook = ''
    bundle config --local path "$PWD/vendor/bundle"
    bundle config --local build.sassc --disable-lto
  '';
}
