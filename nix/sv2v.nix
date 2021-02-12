{ mkDerivation, alex, array, base, cmdargs, containers, directory
, fetchFromGitHub, filepath, githash, happy, hashable, lib, mtl, vector
, pkgs
}:

let rev = "8e1f2bbafb8933dd94a30678f28b65323ff11991"; in

mkDerivation {
  pname = "sv2v";
  version = "0.0.6";
  src = fetchFromGitHub {
    inherit rev;
    owner = "zachjs";
    repo = "sv2v";
    hash = "sha256-NzGl1YcN2B2RvhrpqsdzFYljGfKvbA8bLq908ydF6ao=";
  };
  postPatch = ''
    substituteInPlace src/Job.hs --replace 'giDescribe $$tGitInfoCwd' '"${lib.substring 0 7 rev}"'
  '';
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    array base cmdargs containers directory filepath githash hashable
    mtl vector
  ];
  executableToolDepends = [ alex happy ];
  homepage = "https://github.com/zachjs/sv2v";
  description = "SystemVerilog to Verilog conversion";
  license = lib.licenses.bsd3;
}

