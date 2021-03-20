{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, name = "it-is-the-egg"
, dependencies =
    [ "aff"
    , "affjax"
    , "argonaut"
    , "canvas"
    , "console"
    , "datetime"
    , "debug"
    , "effect"
    , "enums"
    , "matrices"
    , "node-fs-aff"
    , "now"
    , "prelude"
    , "psci-support"
    , "random"
    , "refs"
    , "spec"
    , "web-dom"
    , "web-html"
    , "web-uievents"
    ]
, packages = ./packages.dhall
}
