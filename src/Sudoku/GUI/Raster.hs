module Sudoku.GUI.Raster (draw, handleEvents, calculateCell) where

import Prelude
import Data.Maybe
import FPPrac.Events hiding (Button)
import FPPrac.Graphics hiding (dim)
import qualified FPPrac.Graphics as Gfx (dim)
import Sudoku.GUI.State
import Sudoku

handleEvents s e = (s, [])

size = 540.0
cellColor = makeColor 1 1 1 0.5
frameColor = white
invalidCellColor = Gfx.dim (makeColor 1 0 0 0.5)
gridLineWidth = 2
gridLineColor s | isValid (sudoku s) = Gfx.dim green
                | otherwise = violet

draw :: State -> Input -> Picture
draw s e = Translate (-100) 0 $ Pictures
  [ drawFrame s e
  , drawVerticalGridLines s e
  , drawHorizontalGridLines s e
  , Translate shift shift $ drawCells s e
  ]
  where
    dim' = fromIntegral (dim s) :: Float
    shift = (-size / 2) + (size / dim') / 2

drawCells :: State -> Input -> Picture
drawCells s e = Pictures [ drawCell s e i j | i<-[0..(dim s - 1)], j<-[0..(dim s - 1)] ]

drawCell :: State -> Input -> Int -> Int -> Picture
drawCell state@(State {dim=d,sudoku=su}) (MouseMotion (mx, my)) i j
  | mx > x - (size / 2) - 100 &&
    mx < x - (size / 2) + cellSize - 100 &&
    my > y - (size / 2) &&
    my < y - (size / 2) + cellSize
  = Translate x y $ Pictures
    [ Color violet $ rectangleWire (cellSize + 2) (cellSize + 2)
    , Color cellColor $ rectangleWire cellSize cellSize
    , Translate (-35 * scale) (-50 * scale) $ Color white $ Scale scale scale $ Text "..."
    ]
  where
    [i', j', dim']  = map fromIntegral [i, j, d]
    cellSize        = (size / dim')
    x               = (i' * cellSize)
    y               = (j' * cellSize)
    scale           = 2 / dim'

drawCell state@(State {invalidCell=sc,dim=d,sudoku=su}) _ i j
  = Translate (i' * cellSize) (j' * cellSize) $ Pictures $ [] ++
    (if isJust sc && fromJust sc == (d - j - 1, i) then
      [ Translate (-35 * scale) (-50 * scale) $ Color (Gfx.dim red) $ Scale scale scale $ Text "..." ]
    else
      [ Color cellColor $ rectangleWire cellSize cellSize
      , Translate (-35 * scale) (-50 * scale) $ Color (greyN 0.75) $ Scale scale scale $ Text text
      ]
    )
  where
    [i', j', dim']  = map fromIntegral [i, j, d]
    cellSize        = (size / dim')
    text            = showCell su (d - j - 1) i
    scale           = 2 / dim'

drawVerticalGridLines :: State -> Input -> Picture
drawVerticalGridLines s e = Pictures
  [ drawVerticalGridLine s e i | i<-(filter (\x -> mod x bw == 0) [0..(dim s)]) ]
  where bw = blockWidth (sudoku s)
  
drawVerticalGridLine :: State -> Input -> Int -> Picture
drawVerticalGridLine s e i = let cellSize = (size / fromIntegral (dim s)) in
  Translate ((-size / 2) + (cellSize * fromIntegral i)) 0 $ Color (gridLineColor s) $ rectangleSolid gridLineWidth size

drawHorizontalGridLines :: State -> Input -> Picture
drawHorizontalGridLines s e = Pictures
  [ drawHorizontalGridLine s e i | i<-(filter (\x -> mod x bh == 0) [0..(dim s)]) ]
  where bh = blockHeight (sudoku s)

drawHorizontalGridLine :: State -> Input -> Int -> Picture
drawHorizontalGridLine s e i = let cellSize = (size / fromIntegral (dim s)) in
  Translate 0 ((-size / 2) + (cellSize * fromIntegral i)) $ Color (gridLineColor s) $ rectangleSolid size gridLineWidth

drawFrame :: State -> Input -> Picture
drawFrame s i = Color cellColor $ rectangleWire (size - 2) (size - 2)

showCell :: Sudoku -> Int -> Int -> String
showCell su i j | isValidChar su c  = [c]
                | otherwise         = ""
                where c = su !! i !! j

calculateCell :: Float -> Float -> Int -> Maybe (Int, Int)
calculateCell mx my dim | elem i [0..(dim - 1)] && elem j [0..(dim - 1)] = Just (i, j)
                        | otherwise = Nothing
                        where
                          cellSize = size / (fromIntegral dim)
                          i = dim - ceiling ((my + (size / 2)) / cellSize)
                          j = floor ((mx + 100 + (size / 2)) / cellSize)


