{
  description = "Pagefind";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs; inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    getBinary = kind: version: architecture: sha256: fetchTarball {
      inherit sha256;
      url = "https://github.com/CloudCannon/pagefind/releases/download/v${version}/${kind}-v${version}-${architecture}.tar.gz";
    };
  in rec {
    overlays = rec {
      default = pagefind;
      pagefind = final: prev: {
        pagefind = packages.${system}.pagefind;
      };
    };

    packages = rec {
      default = pagefind;
      pagefind = pkgs.stdenv.mkDerivation rec {
        pname = "pagefind";
        version = "1.0.3";
        src = ./.;

        meta = {
          description = "Static low-bandwidth search at scale";
          homepage = "https://pagefind.app";
          license = "MIT License";
          maintainers = ["Marcus Whybrow <marcus@whybrow.uk>"];
        };

        installPhase = let
          binaries = {
            pagefind = {
              "aarch64-darwin" = getBinary "pagefind" version "aarch64-apple-darwin" "sha256:0bsc57cbfymfadxa27a64321g4a9zh3mz8yxbm2l7k0f1a62ysv9";
              "aarch64-linux" = getBinary "pagefind" version "aarch64-unknown-linux-musl" "sha256:0hikvdjafajjcdlix46chi4w7c7j57g579ssgggc0klx4yjvmxg9";
              "x86_64-darwin" = getBinary "pagefind" version "x86_64-apple-darwin" "sha256:0p84g2h4khnpahq0r7phbdkw9acy6k6gj2kpdxi4vi08wpnkhlil";
              "x86_64-linux" = getBinary "pagefind" version "x86_64-unknown-linux-musl" "sha256:0l4fnf8ad2cif2lvsxb9nfw7a2mqzi8bdn0i3b8wv33hzh9az2ak";
            };
            pagefindExtended = {
              "aarch64-darwin" = getBinary "pagefind_extended" version "aarch64-apple-darwin" "sha256:0xvy0b28wmla7f44iwk8434sxvv8aw5fj6zbad1dbyjm4fkx7aly";
              "aarch64-linux" = getBinary "pagefind_extended" version "aarch64-unknown-linux-musl" "sha256:1kjr6vk59vmvxjdjgfr028wg4qlicprpdznidyhgp8i8jzdhfzgy";
              "x86_64-darwin" = getBinary "pagefind_extended" version "x86_64-apple-darwin" "sha256:08p1mwpw1vhwalwrq5z0d1m0bvwrj44b0hy3wz8z1s7z6dv98cwn";
              "x86_64-linux" = getBinary "pagefind_extended" version "x86_64-unknown-linux-musl" "sha256:1klnalz874znd1rrjqxpaxcwgc9bg40h5p34f6mrxrpxprwakf85";
            };
          };
        in ''
          mkdir -p $out/bin;
          cp ${binaries.pagefind.${system}} $out/bin/pagefind
          cp ${binaries.pagefindExtended.${system}} $out/bin/pagefind_extended
        '';
      };
    };

    apps.pagefind_extended = {
      type = "app";
      program = "${self.packages.${system}.pagefind}/bin/pagefind_extended";
    };
  });
}
