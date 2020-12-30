{
  description = "RIScarlet: RISC-V in Scarlet";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      with nixpkgs.legacyPackages.x86_64-linux;

      mkShell {
        name = "riscarlet-dev";

        nativeBuildInputs = [
          cmake ninja
          verilator
        ];

        buildInputs = [
          zlib abseil-cpp
        ];
      };
  };
}
