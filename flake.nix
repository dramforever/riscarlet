{
  description = "RIScarlet: RISC-V in Scarlet";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      with nixpkgs.legacyPackages.x86_64-linux;

      mkShell {
        name = "riscarlet-dev";

        nativeBuildInputs = [
          cmake ninja verilator svls yosys
        ];

        buildInputs = [
          zlib abseil-cpp
        ];
      };

  };
}
