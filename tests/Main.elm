module Main exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Debug exposing (..)

--import ElmTest exposing (..)

import Model exposing (..)
import Update exposing (skipList, sortBasedOnHistory2)


testm : Model
testm =
    { initialModel
        | gRoom =
            { id = "570a5925187bb6f0eadebf05", name = "", userCount = 0 }
    }


cAshok : Camper
cAshok =
    { chist =
        [ { delta = 1, points = 350, ts = 1518892020524 }
        , { delta = 9, points = 349, ts = 1518889467698 }
        , { delta = 10, points = 340, ts = 1518218502684 }
        , { delta = 5, points = 330, ts = 1517861564348 }
        , { delta = 5, points = 325, ts = 1517764495001 }
        , { delta = 320, points = 320, ts = 1517588916347 }
        ]
    , last = { delta = 1, points = 350, ts = 1518892020524 }
    , uname = "kgashok"
    }


cSrimathi =
    { chist =
        [ { delta = 33, points = 249, ts = 1518889467698 }
        , { delta = 12, points = 216, ts = 1517861564348 }
        , { delta = 19, points = 204, ts = 1517851916496 }
        , { delta = 185, points = 185, ts = 1517588916347 }
        ]
    , last = { delta = 33, points = 249, ts = 1518889467698 }
    , uname = "srimathic"
    }


cDivya =
    { chist =
        [ { delta = 62, points = 225, ts = 1518889467698 }
        , { delta = 6, points = 163, ts = 1518218502684 }
        , { delta = 157, points = 157, ts = 1517588916347 }
        ]
    , last = { delta = 62, points = 225, ts = 1518889467698 }
    , uname = "divyamano"
    }


createMember : String -> Int -> Member
createMember name points =
    { uname = name
    , points = points
    }


memberList : List Member
memberList =
    [ createMember "kgashok" 140
    , createMember "sudhar" 100
    , createMember "ramya" 150
    ]


historyS : List Cdata
historyS =
    [ pointsData 124 16000 120
    , pointsData 120 15000 110
    , pointsData 110 9000 100
    , pointsData 100 8000 0
    ]


historyR : List Cdata
historyR =
    [ pointsData 222 17000 170
    , pointsData 170 15500 151
    , pointsData 151 9000 150
    , pointsData 150 8000 0
    ]


historyA : List Cdata
historyA =
    [ pointsData 229 17000 226
    , pointsData 226 11000 222
    , pointsData 222 10000 220
    , pointsData 220 9000 140
    , pointsData 140 8000 0
    ]



{- Both the below needed to be included in the model -}
{- In Elm repl inHours 2592000000 = 720 hours  or 30 days -}


cutOff : Float
cutOff =
    10000


assignHistory : List Cdata -> Camper -> Camper
assignHistory data camper =
    { camper | chist = data
             , last = Maybe.withDefault camper.last (List.head data)
    }


createCampersFromMembers : List Member -> List Camper
createCampersFromMembers mList =
    let
        cList =
            List.map (createCamper 0) memberList
    in
        List.map2 assignHistory [ historyA, historyS, historyR ] cList


dinfo : { c | last : { b | points : a }, uname : String } -> String
dinfo { uname, last } =
    uname ++ " " ++ (toString last.points)


{-| contains a portion of the output that is generated by the FCC bot
-}
url : String
url =
    "http://myjson.com/2dzdj"


all : Test
all =
    let
        clist =
            createCampersFromMembers memberList

        dummy =
            createCamper 0 { uname = "NA", points = 0 }

        first =
            List.head clist |> Maybe.withDefault dummy

        
        sortOut =
            List.map dinfo (sortBasedOnHistory2 20000 20000 clist)

        truncated = sortBasedOnHistory2 20000 8000 clist
        
        sortOutWithCO =
            List.map dinfo truncated 
        -- _ = Debug.log "truncated" truncated
        
    in
        describe "Fcc Test Suite"
            [ describe "Unit test examples"
                [ test "zero" <| \() -> Expect.equal 0 0
                , test "truth" <| \() -> Expect.true "the truth" True
                , test "booleans" <| \() -> Expect.notEqual True False
                , test "pass" <| \() -> Expect.equal [ 0, 30, 60, 90, 120, 150, 180 ] (skipList 170)
                , test "history" <| \() -> Expect.equal historyA first.chist
                , test "sort" <|
                    \() ->
                        Expect.equal [ "kgashok 229", "ramya 222", "sudhar 124" ] sortOut
                , test "sortcut" <|
                    \() ->
                        Expect.equal [ "ramya 222", "sudhar 124", "kgashok 229" ] sortOutWithCO
                
                , test "sortCamper" <|
                    \() ->
                        Expect.equal [ cAshok, cSrimathi, cDivya ]
                            (Update.sortBasedOnHistory 1518898649827 1518898649827 [ cDivya, cAshok, cSrimathi ])
                
                , test "sortCamper2" <|
                    \() ->
                        Expect.equal [ "divyamano 225", "srimathic 249", "kgashok 350" ]
                            (List.map dinfo
                                (Update.sortBasedOnHistory2 1518898649827 670965014 [ cSrimathi, cAshok, cDivya ])
                            )
                ]

                , todo "Have to write tests for excluded List Bug > Total Campers!"
                , test "gitterRequest" <|
                    \() ->
                        -- -> Expect.equal [] (Update.refreshGitterIDs gUrl)
                        Expect.equal 0 0
                
            ]



{--
consoleTests : Test
consoleTests =
    suite "All Tests" tests

main : Program Never
main =
    runSuite consoleTests
    --runSuiteHtml consoleTests

--}
