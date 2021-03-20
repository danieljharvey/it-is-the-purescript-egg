let mkPackage =
      https://raw.githubusercontent.com/purescript/package-sets/psc-0.13.0-20190614/src/mkPackage.dhall sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.0-20210318/packages.dhall sha256:98bbacd65191cef354ecbafa1610be13e183ee130491ab9c0ef6e3d606f781b5

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
