{
  stdenv,
  lib,
  autoPatchelfHook,
  sku ? "xpclient-pro",
  ...
}@pkgs:
with builtins;
let
  src = ../..;
  readLines =
    filename:
    lib.optionals (pathExists filename) (
      filter (s: stringLength s > 0) (lib.splitString "\n" (readFile filename))
    );
  getDeps =
    filename: map (str: elemAt (lib.splitString ":" str) 1) (readLines "${src}/${filename}/deps");
  depsMap =
    with pkgs;
    {
      "glib2" = glib.dev;
      "canberra" = libcanberra;
      "canberra-gtk3" = libcanberra-gtk3;
      "sass" = sass;
      "garcon" = xfce.garcon;
      "garcon-gtk3" = xfce.garcon;
      "msgfmt" = gettext;
      "xdg-mime" = xdg-utils;
      "xcursorgen" = xorg.xcursorgen;
      "gtk3" = gtk3;
      "networkmanager" = networkmanager;
      "pulseaudio" = pulseaudio;
      "upower-glib" = upower;
      "webkitgtk" = webkitgtk_4_1;
      "lightdm" = lightdm;
      "sqlite3" = sqlite;
      "plymouth" = plymouth;
      "gdk-pixbuf2" = gdk-pixbuf;
      "zip" = libzip;
      # dummy packages
      "python3-venv" = cmake;
      "python3-packaging" = cmake;
      "sysinfo" = cmake;
    }
    // lib.mapAttrs' (name: type: {
      name = "wintc-${name}";
      value = mkComponent "shared/${name}";
    }) (lib.filterAttrs (name: type: type == "directory") (readDir "${src}/shared"));
  mkComponent =
    target:
    stdenv.mkDerivation {
      inherit src;
      name = "xfce-winxp-tc-${target}";

      buildInputs =
        with pkgs;
        [
          util-linux
          libselinux
          libsepol
          libthai
          libdatrie
          xorg.libXdmcp
          xorg.libXtst
          xfce.libxfce4ui
          libwnck
          xfce.libxfce4windowing
          lerc
          libxkbcommon
          libxklavier
          libepoxy
          coreutils
          cmake
          pcre2
          libsysprof-capture
          (python3.withPackages (
            p: with p; [
              pillow
              packaging
            ]
          ))
        ]
        ++ lib.attrVals (getDeps target) depsMap;
      nativeBuildInputs = with pkgs; [
        pkg-config
        autoPatchelfHook
      ];

      configurePhase = ''
        runHook preConfigure

        cmake -DBUILD_SHARED_LIBS=ON    \
          -DCMAKE_BUILD_TYPE="Release"  \
          -DCMAKE_INSTALL_PREFIX="$out" \
          -DWINTC_SKU="${sku}"          \
          -DWINTC_PKGMGR="nix"          \
          "$src/${target}" 

        runHook postConfigure
      '';
      preFixup =
        if target == "shared/shelldpa" then
          ''
            patchelf --add-needed libwnck-3.so $out/lib64/libwintc-shelldpa.so.1.0
            patchelf --add-needed libxfce4windowing-0.so $out/lib64/libwintc-shelldpa.so.1.0
          ''
        else
          "";
    };
in
lib.updateManyAttrsByPath (map (target: {
  path = lib.splitString "/" target;
  update = _: mkComponent target;
}) (readLines "${src}/packaging/targets")) { }
