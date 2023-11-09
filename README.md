Unofficial Nix flake for [Pagefind](https://pagefind.app).

```
nix run github:marcuswhybrow/pagefind
nix run github:marcuswhybrow/pagefind#pagefind_extended
```

For use in your own flake:

```
{
  description = "Example website that uses Pagefind";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    pagefind.url = "github:marcuswhybrow/pagefind";
  };

  outputs = let
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [inputs.pagefind.overlays.default];
    };
  in {
    packages.x86_64-linux.exampleWebsite = pkgs.mkDerivation {
      pname = "Example Website";
      version = "1.0.0";
      src = ./.;

      buildPhase = ''
        ${pkgs.pagefind}/bin/pagefind --site ./your_site_location
      '';
    };
  });
}

```
