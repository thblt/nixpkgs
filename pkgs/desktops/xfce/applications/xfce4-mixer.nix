{ stdenv, fetchurl, pkgconfig, intltool, glib, gstreamer, gst_plugins_base, gtk
, libxfce4util, libxfce4ui, xfce4panel, xfconf, libunique?null }:

let
  # The usual Gstreamer plugins package has a zillion dependencies
  # that we don't need for a simple mixer, so build a minimal package.
  gst_plugins_minimal = gst_plugins_base.override {
    minimalDeps = true;
  };

in

stdenv.mkDerivation rec {
  p_name  = "xfce4-mixer";
  ver_maj = "4.10";
  ver_min = "0";

  src = fetchurl {
    url = "mirror://xfce/src/apps/${p_name}/${ver_maj}/${name}.tar.bz2";
    sha256 = "1pnsd00583l7p5d80rxbh58brzy3jnccwikbbbm730a33c08kid8";
  };
  name = "${p_name}-${ver_maj}.${ver_min}";

  buildInputs =
    [ pkgconfig intltool glib gstreamer gst_plugins_minimal gtk
      libxfce4util libxfce4ui xfce4panel xfconf libunique
    ];

  postInstall =
    ''
      mkdir -p $out/nix-support
      echo ${gst_plugins_minimal} > $out/nix-support/propagated-user-env-packages
    '';

  meta = {
    homepage = http://www.xfce.org/projects/xfce4-mixer; # referenced but inactive
    description = "A volume control application for the Xfce desktop environment";
    license = "GPLv2+";
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.eelco ];
  };
}
