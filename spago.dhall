{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "affjax"
  , "argonaut"
  , "arrays"
  , "console"
  , "datetime"
  , "debug"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "foreign"
  , "foreign-object"
  , "halogen-subscriptions"
  , "http-methods"
  , "integers"
  , "js-timers"
  , "math"
  , "maybe"
  , "newtype"
  , "now"
  , "partial"
  , "prelude"
  , "psci-support"
  , "react"
  , "react-dom"
  , "refs"
  , "st"
  , "transformers"
  , "tuples"
  , "web-dom"
  , "web-events"
  , "web-html"
  , "web-socket"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
