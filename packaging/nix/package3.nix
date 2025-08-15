{
  stdenv,
  git,
  bash,
  cmake,
  coreutils,
  gcc,
  gnumake,
  pkg-config,
  python3,
  sqlite,
  xorg,
  xfce,
  libwnck,
  libsysprof-capture,
  sass,
  libpulseaudio,
  autoPatchelfHook,
  glib,
  webkitgtk_4_1,
  libzip,
  upower,
  libcanberra-gtk3,
  networkmanager,
  libcanberra,
  lightdm,
}:
stdenv.mkDerivation rec {
  name = "xfce-winxp-tc";

  buildInputs = [
    bash
    cmake
    coreutils
    sqlite
    gcc
    gnumake
    libwnck
    xfce.libxfce4windowing
    pkg-config
    (python3.withPackages (
      p: with p; [
        pillow
        packaging
      ]
    ))
    libcanberra-gtk3
    xorg.xcursorgen
    xfce.libxfce4ui
    xfce.garcon
    libsysprof-capture
    sass
    libpulseaudio
    glib
    webkitgtk_4_1
    libzip
    upower
    networkmanager
    libcanberra
    lightdm
  ];

  nativeBuildInputs = [
    git
    autoPatchelfHook
  ];
  src = ../..;

  dontConfigure = true;
  CFLAGS = "-w";

  preBuild = ''
    ${git}/bin/git apply -R packaging/nix/intree.patch
    substituteInPlace packaging/*.sh \
    --replace-warn '/usr/bin/env bash' ${bash}/bin/bash
  '';

  buildPhase = ''
    runHook preBuild
    cd packaging
    ./buildall.sh -z
    runHook postBuild
  '';

  installPhase = ''
      runHook preInstall
      cd build
      # Package shared libraries
      lib_list=$(find shared -mindepth 1 -maxdepth 1 -type d)
    	for lib in $lib_list; do
    		make -C "$lib" install
    	done

      # Package components
    	comp_list=$(sed 's/#.*$//g' < "../targets")
    	for comp in $comp_list; do
    		make -C "$comp" install
    	done
      runHook postInstall
  '';

  preFixup = ''
    patchelf --add-needed libwnck-3.so $out/lib64/libwintc-shelldpa.so.1.0
    patchelf --add-needed libxfce4windowing-0.so $out/lib64/libwintc-shelldpa.so.1.0
  '';
}
