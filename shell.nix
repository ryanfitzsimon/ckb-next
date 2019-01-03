with import <nixpkgs> {};

mkShell {

  buildInputs = [
    qt5.qtbase
    udev
    zlib
  ];

  nativeBuildInputs = [
    cmake
    pkgconfig
  ];

}
