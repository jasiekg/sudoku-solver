module Sudoku.GUI.Raster (compose, handleEvents) where

import Prelude
import FPPrac.Events hiding (Button)
import FPPrac.Graphics hiding (dim)
import Sudoku.GUI.State

handleEvents s e = (s, [])

size = 540.0
borderColor = makeColor 1 1 1 0.5

compose :: State -> Input -> Picture
compose s e = Translate (-100) 0 $ Pictures
  [ Color violet $ rectangleWire (size + 2) (size + 2)
  , Translate shift shift $ Pictures tiles      
  ]
  where
    dim' = fromIntegral (dim s) :: Float
    tiles = [ composeTile s e i j | i<-[1..(dim s)], j<-[1..(dim s)] ]
    shift = (-size / 2) - (size / dim') / 2

composeTile :: State -> Input -> Int -> Int -> Picture
composeTile s (MouseMotion (mx, my)) i j
  | mx > x - (size / 2) - cellSize - 100 &&
    mx < x - (size / 2) - 100 &&
    my > y - (size / 2) - cellSize &&
    my < y - (size / 2) &&
    ((sudoku s) !! (i - 1) !! (j - 1)) == '.'
  = Translate x y $ Pictures
    [ Color violet $ rectangleWire (cellSize + 2) (cellSize + 2)
    , Color borderColor $ rectangleWire cellSize cellSize
    , Translate (-35 * scale) (-50 * scale) $ Color white $ Scale scale scale $ Text "?"
    ]
  where
    [i', j', dim']  = map fromIntegral [i, j, dim s]
    cellSize        = (size / dim')
    x               = (i' * cellSize)
    y               = (j' * cellSize)
    scale           = 2.5 / dim'

composeTile s _ i j =
  Translate (i' * cellSize) (j' * cellSize) $ Pictures
    [ Color borderColor $ rectangleWire cellSize cellSize
    , Translate (-8) (-10) $ Color (greyN 0.5) $ Scale 0.2 0.2 $ Text [((sudoku s) !! (i - 1) !! (j - 1))]
    ]
  where
    [i', j', dim']  = map fromIntegral [i, j, dim s]
    cellSize        = (size / dim')

-- TODO
-- inBoundary :: Float -> Float -> Button -> Bool
-- inBoundary mx my (Rectangular coords _ _ _)
