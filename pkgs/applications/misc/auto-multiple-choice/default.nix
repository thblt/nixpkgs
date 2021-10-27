{ lib
, stdenv
, fetchurl
, perlPackages
, makeWrapper
, wrapGAppsHook
, cairo
, dblatex
, gnumake
, gobject-introspection
, graphicsmagick
, gsettings-desktop-schemas
, gtk3
, libnotify
, librsvg
, libxslt
, netpbm
, opencv
, pango
, perl
, pkg-config
, poppler
, auto-multiple-choice
}:
stdenv.mkDerivation rec {
  pname = "auto-multiple-choice";
  version = "1.5.1";
  src = fetchurl {
    url = "https://download.auto-multiple-choice.net/${pname}_${version}_precomp.tar.gz";
    sha256 = "71831122f7b43245d3289617064e0b561817c0130ee1773c1b957841b28b854c";
  };
  tlType = "run";

  # There's only the Makefile
  dontConfigure = true;

  # Reported upstream as MR!25
  patches = [ ./0001-fix-module-path-detection.patch ];

  makeFlags = [
    "PERLPATH=${perl}/bin/perl"
    # We *need* to pass DESTDIR, as the Makefile ignores PREFIX.
    "DESTDIR=$(out)"
    # Relative paths.
    "BINDIR=/bin"
    "PERLDIR=/share/perl5"
    "MODSDIR=/lib/AMC"
    "TEXDIR=/share/texmf/tex/latex/AMC"
    "TEXDOCDIR=/share/doc/texmf/AMC/"
    "MAN1DIR=/share/man/man1"
    "DESKTOPDIR=/share/applications"
    "METAINFODIR=/share/metainfo"
    "ICONSDIR=/share/auto-multiple-choice/icons"
    "APPICONDIR=/share/icons/hicolor"
    "LOCALEDIR=/share/locale"
    "MODELSDIR=/share/auto-multiple-choice/models"
    "DOCDIR=/share/doc/auto-multiple-choice"
    "SHARED_MIMEINFO_DIR=/share/mime/packages"
    "LANG_GTKSOURCEVIEW_DIR=/share/gtksourceview-4/language-specs"
    # Pretend to be redhat so `install` doesn't try to chown/chgrp.
    "SYSTEM_TYPE=rpm"

  ];

  preFixup = ''
  makeWrapperArgs+=("''${gappsWrapperArgs[@]}")'';

  postFixup = ''
    mv $out/share/texmf/tex $out
    wrapProgram $out/bin/auto-multiple-choice \
    ''${makeWrapperArgs[@]} \
    --prefix PERL5LIB : "${with perlPackages; makePerlPath [
      ArchiveZip
      DBDSQLite
      Cairo
      CairoGObject
      DBI
      Glib
      GlibObjectIntrospection
      Gtk3
      LocaleGettext
      PerlMagick
      TextCSV
      XMLParser
      XMLSimple
      XMLWriter
    ]}:"$out/share/perl5 \
    --prefix XDG_DATA_DIRS : "$out/share" \
    --set TEXINPUTS ":.:$out/share/texmf/tex/latex/AMC"
'';

  nativeBuildInputs =
    [ pkg-config
      makeWrapper
      wrapGAppsHook
    ];

  buildInputs =
    [ cairo
      cairo.dev
      dblatex
      gnumake
      gobject-introspection
      graphicsmagick
      gsettings-desktop-schemas
      gtk3
      libnotify
      librsvg
      libxslt
      netpbm
      opencv
      pango
      perl
      perlPackages.ArchiveZip
      perlPackages.Cairo
      perlPackages.CairoGObject
      perlPackages.DBDSQLite
      perlPackages.DBI
      perlPackages.Glib
      perlPackages.GlibObjectIntrospection
      perlPackages.Gtk3
      perlPackages.LocaleGettext
      perlPackages.PerlMagick
      perlPackages.TextCSV
      perlPackages.XMLParser
      perlPackages.XMLSimple
      perlPackages.XMLWriter
      poppler
    ];

  meta = with lib; {
    description = "Create and manage multiple choice questionnaires with automated marking.";
    longDescription = ''
Create, manage and mark multiple-choice questionnaires.
auto-multiple-choice features automated or manual formatting with
LaTeX, shuffling of questions and answers and automated marking using
Optical Mark Recognition.

Questionnaires can be created using either a very simple text syntax,
AMC-TXT, or LaTeX. In the latter case, your TeXLive installation must
be combined with this package.  This can be done in configuration.nix
as follows:

<screen>
…
environment.systemPackages = with pkgs; [
  auto-multiple-choice
  (texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    extra =
      {
        pkgs = [ auto-multiple-choice ];
      };
  })
];
</screen>

For usage instructions, see documentation at the project's homepage.
    '';
    homepage = "https://www.auto-multiple-choice.net/";
    changelog = "https://gitlab.com/jojo_boulix/auto-multiple-choice/-/blob/master/ChangeLog";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.thblt ];
    platforms = platforms.all;
  };
}
