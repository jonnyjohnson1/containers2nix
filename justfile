build:
    nix build .#compose --extra-experimental-features nix-command --extra-experimental-features flakes

compose:
    nix run .#compose --extra-experimental-features nix-command --extra-experimental-features flakes

discover:
    nix run .#discover-packages --extra-experimental-features nix-command --extra-experimental-features flakes

run:
    nix run .#services-flake-zrok --extra-experimental-features nix-command --extra-experimental-features flakes