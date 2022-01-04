module Rps.UI where

import Data.Maybe (fromJust)
import Effect (Effect)
import Partial.Unsafe (unsafePartial)
import Prelude (Unit, bind, ($), void)
import React as React
import ReactDOM as ReactDOM
import Rps.UI.App (AppProps, app)
import Web.DOM.NonElementParentNode (getElementById) as DOM
import Web.HTML (window) as DOM
import Web.HTML.HTMLDocument (toNonElementParentNode) as DOM
import Web.HTML.Window (document) as DOM

renderApp :: AppProps -> Effect Unit
renderApp props = do
  window <- DOM.window
  document <- DOM.document window

  let
      node = DOM.toNonElementParentNode document

  maybeElement <- DOM.getElementById "root" node

  let
      element' = unsafePartial (fromJust maybeElement)

  void $ ReactDOM.render (React.createLeafElement app props) element'
