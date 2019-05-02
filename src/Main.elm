module Main exposing (main)

import Browser
import Html exposing (Html, button, form, input, label, text)
import Html.Events
import Http
import Json.Decode as D


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }


view : Model -> Html Msg
view model =
    form [ Html.Events.onSubmit CitySelected ]
        [ label [] [ text "City" ]
        , input [ Html.Events.onInput CityChanged ] []
        , button [] [ text "Hell yeah!" ]
        , text <| "Weather " ++ Maybe.withDefault "missing" model.weather
        ]


type Msg
    = CityChanged String
    | CitySelected
    | GotWeather (Result Http.Error String)


type alias Model =
    { cityInput : String, weather : Maybe String }


initialModel : Model
initialModel =
    { cityInput = "", weather = Nothing }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CityChanged city ->
            ( { model | cityInput = city }, Cmd.none )

        CitySelected ->
            ( model, getWeather model.cityInput )

        GotWeather result ->
            case result of
                Ok weather ->
                    ( { model | weather = Just weather }, Cmd.none )

                Err err ->
                    let
                        a =
                            Debug.log "Wether request failed" err
                    in
                    ( { model | weather = Nothing }, Cmd.none )


getWeather : String -> Cmd Msg
getWeather city =
    Http.get
        { url = "https://api.openweathermap.org/data/2.5/weather?q=" ++ city ++ "&appId=<APP_ID_HERE>"
        , expect = Http.expectJson GotWeather (D.at [ "weather" ] (D.index 0 (D.at [ "description" ] D.string)))
        }
