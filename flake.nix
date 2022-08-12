{
  description = "RIScarlet: RISC-V in Scarlet";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      with nixpkgs.legacyPackages.x86_64-linux;

      mkShell {
        name = "riscarlet-dev";

        nativeBuildInputs = [
          cmake ninja verilator yosys haskellPackages.sv2v
        ];

        buildInputs = [
          zlib abseil-cpp
        ];
      };

  };
}
