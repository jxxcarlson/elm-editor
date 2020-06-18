module View.Footer exposing (view)

import Element
    exposing
        ( Element
        , alignRight
        , el
        , height
        , paddingXY
        , px
        , row
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Font as Font
import Helper.Common
import Types exposing (Model, Msg)
import View.Helpers
import View.Style as Style
import View.Widget


view model width_ height_ =
    row
        [ width (View.Helpers.pxFloat (2 * Helper.Common.windowWidth width_ - 40))
        , height (View.Helpers.pxFloat height_)
        , Background.color (Element.rgb255 130 130 140)
        , Font.color (View.Helpers.gray 240)
        , Font.size 14
        , paddingXY 10 0
        , Element.moveUp 19
        , spacing 12
        ]
        [ View.Widget.openAuthorPopupButton model
        , View.Widget.openFileListPopupButton model
        , View.Widget.toggleFileLocationButton model
        , View.Widget.saveFileToStorageButton model
        , View.Widget.documentTypeButton model
        , View.Widget.openNewFilePopupButton model
        , View.Widget.openFilePopupButton model
        , View.Widget.importFileButton model
        , View.Widget.exportFileButton model
        , View.Widget.exportLaTeXFileButton model
        , displayFilename model
        , row [ alignRight, spacing 12 ]
            [ displayMessage model
            , View.Widget.aboutButton
            ]
        ]


displayFilename : Model -> Element Msg
displayFilename model =
    el [] (text model.fileName)


displayMessage model =
    View.Helpers.showIf (model.messageLife > 0)
        (el
            [ width (px 250)
            , paddingXY 8 8
            , Background.color Style.whiteColor
            , Font.color Style.blackColor
            ]
            (text model.message)
        )
