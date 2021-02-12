{
  description = "RIScarlet: RISC-V in Scarlet";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      with nixpkgs.legacyPackages.x86_64-linux;

      let sv2v = haskellPackages.callPackage ./nix/sv2v.nix {};
      in mkShell {
        name = "riscarlet-dev";

        nativeBuildInputs = [
          cmake ninja verilator svls sv2v
        ];

        buildInputs = [
          zlib abseil-cpp
        ];
      };

  };
}
