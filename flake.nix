{
  description = "PredictionBook";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
  };
  outputs = inputs:
  inputs.flake-utils.lib.eachSystem [
    "x86_64-linux"
    "x86_64-darwin"
  ] (system:
  let
    pkgs = import inputs.nixpkgs { inherit system; };
    ruby = pkgs.ruby_3_2;
    bundler = pkgs.bundler.override { inherit ruby; };
    developmentInputs = with pkgs; [
      bundler
      libnotify
      pkg-config
      postgresql_12
      readline
      ruby
      zlib
    ]
    ++ (lib.optionals stdenv.hostPlatform.isDarwin [ pkgs.libiconv pkgs.darwin.apple_sdk.frameworks.CoreServices ]);
  in
  {
    devShells.default= pkgs.mkShell {
      name = "development";
      buildInputs = developmentInputs;
      shellHook = ''
        bundle config --local path "$PWD/vendor/bundle"
        bundle config --local build.sassc --disable-lto
        ruby -e "puts RUBY_VERSION" > "$PWD/.ruby-version"
      '';
    };
  });
}

