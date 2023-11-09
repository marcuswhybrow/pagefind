{
  description = "Pagefind";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = inputs: let
    supportedSystems = [
      "aarch64-darwin" # 64-bit ARM macOS
      "aarch64-linux" # 64-bit ARM Linux
      "x86_64-darwin" # 64-bit Intel macOS
      "x86_64-linux" # 64-bit Intel/AMD Linux
    ];

    forAllSystems = f: inputs.nixpkgs.lib.genAttrs supportedSystems (system: f {
      inherit system ;
      pkgs = import inputs.nixpkgs { inherit system; };
    });

    getBinary = kind: version: architecture: sha256: fetchTarball {
      inherit sha256;
      url = "https://github.com/CloudCannon/pagefind/releases/download/v${version}/${kind}-v${version}-${architecture}.tar.gz";
    };
  in {
    packages = forAllSystems ({ pkgs, system }: let 
      version = "1.0.3";
      src = ./.;
      meta = {
        description = "Static low-bandwidth search at scale";
        homepage = "https://pagefind.app";
        license = "MIT License";
        maintainers = ["Marcus Whybrow <marcus@whybrow.uk>"];
      };
    in {
      default = inputs.self.outputs.packages.${system}.pagefind;

      pagefind = pkgs.stdenv.mkDerivation rec {
        inherit version src meta;
        pname = "pagefind";

        installPhase = let
          binaries = {
            "aarch64-darwin" = getBinary "pagefind" version "aarch64-apple-darwin" "sha256:0bsc57cbfymfadxa27a64321g4a9zh3mz8yxbm2l7k0f1a62ysv9";
            "aarch64-linux" = getBinary "pagefind" version "aarch64-unknown-linux-musl" "sha256:0hikvdjafajjcdlix46chi4w7c7j57g579ssgggc0klx4yjvmxg9";
            "x86_64-darwin" = getBinary "pagefind" version "x86_64-apple-darwin" "sha256:0p84g2h4khnpahq0r7phbdkw9acy6k6gj2kpdxi4vi08wpnkhlil";
            "x86_64-linux" = getBinary "pagefind" version "x86_64-unknown-linux-musl" "sha256:0l4fnf8ad2cif2lvsxb9nfw7a2mqzi8bdn0i3b8wv33hzh9az2ak";
          };
        in ''
          mkdir -p $out/bin;
          cp ${binaries.${system}} $out/bin/pagefind
        '';
      };

      pagefind_extended = pkgs.stdenv.mkDerivation {
        inherit version src;
        pname = "pagefind_extended";

        meta = meta // {
          longDescription = "Pagefind publishes two releases, pagefind and \
          pagefind_extended. The extended release is a larger binary, but \
          includes specialized support for indexing Chinese and Japanese \
          pages.";
        };

        installPhase = let
          binaries = {
            "aarch64-darwin" = getBinary "pagefind_extended" version "aarch64-apple-darwin" "sha256:0xvy0b28wmla7f44iwk8434sxvv8aw5fj6zbad1dbyjm4fkx7aly";
            "aarch64-linux" = getBinary "pagefind_extended" version "aarch64-unknown-linux-musl" "sha256:1kjr6vk59vmvxjdjgfr028wg4qlicprpdznidyhgp8i8jzdhfzgy";
            "x86_64-darwin" = getBinary "pagefind_extended" version "x86_64-apple-darwin" "sha256:08p1mwpw1vhwalwrq5z0d1m0bvwrj44b0hy3wz8z1s7z6dv98cwn";
            "x86_64-linux" = getBinary "pagefind_extended" version "x86_64-unknown-linux-musl" "sha256:1klnalz874znd1rrjqxpaxcwgc9bg40h5p34f6mrxrpxprwakf85";
          };
        in ''
          mkdir -p $out/bin;
          cp ${binaries.${system}} $out/bin/pagefind_extended
        '';
      };
    });
  } // {
    overlays = {
      default = inputs.self.outputs.overlays.pagefind;
      pagefind = final: prev: forAllSystems ({ system, ... }: {
        pagefind = inputs.self.outputs.packages.${system}.pagefind;
        pagefind_extended = inputs.self.outputs.packages.${system}.pagefind_extended;
      });
    };
  };
}

