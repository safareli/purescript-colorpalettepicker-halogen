module Main where

import Prelude

import CSS as CSS
import ColorPalettePicker.Halogen.Component as CPP
import Compact.Halogen.Component as Compact
import Control.Monad.Aff.Class (class MonadAff)
import Control.Monad.Eff (Eff)
import Data.Either.Nested as Either
import Data.Functor.Coproduct.Nested as Coproduct
import Data.Maybe (Maybe(..))
import Debug.Trace (spy)
import Halogen as H
import Halogen.Aff as HA
import Halogen.Component.ChildPath as CP
import Halogen.HTML as HH
import Halogen.HTML.CSS as HCSS
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)

main ∷ Eff (HA.HalogenEffects ()) Unit
main = HA.runHalogenAff do
  body ← HA.awaitBody
  runUI example unit body

data Query a
  = Query Unit a
  | CompactQuery (Compact.Message CPP.Message) a

type State = {}
type CompactPickerQuery = Compact.Query CPP.Query CPP.Input CPP.Message
type ChildQuery = Coproduct.Coproduct2 CPP.Query CompactPickerQuery
type Slot = Either.Either2 Int Int


cpPicker ∷ CP.ChildPath CPP.Query ChildQuery Int Slot
cpPicker = CP.cp1

cpCompactColor ∷ CP.ChildPath CompactPickerQuery ChildQuery Int Slot
cpCompactColor = CP.cp2


type HTML m = H.ParentHTML Query ChildQuery Slot m
type DSL m = H.ParentDSL State Query ChildQuery Slot Void m


example ∷ ∀ m r. MonadAff (CPP.PickerEffects r) m => H.Component HH.HTML Query Unit Void m
example = H.parentComponent
    { initialState: const {}
    , render
    , eval
    , receiver: const Nothing
    }

render ∷ ∀ m r. MonadAff (CPP.PickerEffects r) m => State → HTML m
render _ = HH.div_
  [ HH.h1_ [ HH.text "Picker 0" ]
  -- , HH.slot' cpPicker 0 (CPP.input) unit (HE.input Query)
  -- , HH.slot' cpPicker 0 (CPP.input) unit (HE.input Query)
  , HH.h1_ [ HH.text "Picker 1" ]
  , HH.slot'
    cpCompactColor
    0
    (Compact.factory CPP.input)
    { compactView: \{ expand } ->
        HH.div
          [ HP.classes [HH.ClassName "Compact-expand"]
          , HP.id_ "foo"
          , HE.onClick $ spy >>> (const $ Just $ expand)
          -- , HCSS.style $ CSS.backgroundColor value
          ] [HH.text "EXPAND"]
    , detailView: \{embed, compact} ->
        HH.div
          [ HP.classes [HH.ClassName "Compact-details"] ]
          [ HH.div
            [ HP.classes [HH.ClassName "Compact-compact"]
            , HP.id_ "bar"
            , HE.onClick $ spy >>> (const $ Just $ compact)
            ] [HH.text "COMPACT"]
          , embed unit
          ]
    , shouldCompact: spy >>> const true
    }
    $ HE.input CompactQuery
  ]

eval ∷ ∀ m. Query ~> DSL m
eval (Query _ next) = pure next
eval (CompactQuery _ next) = pure next
