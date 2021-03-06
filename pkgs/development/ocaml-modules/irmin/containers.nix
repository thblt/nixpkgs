{ buildDunePackage
, irmin, irmin-unix, irmin-git, ppx_irmin, lwt, mtime
, alcotest, alcotest-lwt
}:

buildDunePackage {
  pname = "irmin-containers";

  inherit (ppx_irmin) src version useDune2;

  nativeBuildInputs = [
    ppx_irmin
  ];

  propagatedBuildInputs = [
    irmin irmin-unix irmin-git ppx_irmin lwt mtime
  ];

  doCheck = true;
  checkInputs = [
    alcotest alcotest-lwt
  ];

  meta = ppx_irmin.meta // {
    description = "Mergeable Irmin data structures";
  };
}
