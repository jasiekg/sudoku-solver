{-# LANGUAGE RecordWildCards #-}

module Sudoku.GUI.Events (handleEvents) where

import Prelude
import Data.Maybe
import FPPrac.Events
import FPPrac.Graphics hiding (dim)
import Sudoku
import Sudoku.Strategy
import Sudoku.Strategy.NakedSingle
import Sudoku.GUI.State
import qualified Sudoku.GUI.Button as Btn
import qualified Sudoku.GUI.Menu as Menu
import qualified Sudoku.GUI.Solver as Solver
import qualified Sudoku.GUI.Raster as Raster

handleEvents state@(State {stage="menu",..}) (MouseUp (mx, my)) 
  | Btn.inBoundary mx my (Menu.buttons !! 0)
  = f $ state { stage = "solver", sudoku = empty4x4Sudoku, dim = 4, mousePressed = False }
  | Btn.inBoundary mx my (Menu.buttons !! 1)
  = f $ state { stage = "solver", sudoku = exampleSudoku1, dim = 9, mousePressed = False }
  | Btn.inBoundary mx my (Menu.buttons !! 2)
  = f $ state { stage = "solver", sudoku = empty12x12Sudoku, dim = 12, mousePressed = False }
  where
    f s = (s, redraw s $ MouseUp (mx, my))

-- TODO restoreState { ... }
-- restoreState = .. mousePressed = False

handleEvents state@(State {stage="solver",dim=d,sudoku=su,..}) (MouseUp (mx, my))
  | Btn.inBoundary mx my (Solver.buttons !! 0)
  = f $ state { stage = "menu", mousePressed = False }
  | Btn.inBoundary mx my (Solver.buttons !! 1)
  = f $ state { sudoku = (es d), mousePressed = False }
  | Btn.inBoundary mx my (Solver.buttons !! 2)
  = f $ state { sudoku = (ns d), mousePressed = False }
  | isJust cell
  = (state { selectedCell = cell, mousePressed = False }, [GraphPrompt ("Enter a number", hint)])
  where
    range = allowedChars su
    hint = "Range (" ++ (show $ head range) ++ ".." ++ (show $ last range) ++ ")"
    cell = Raster.calculateCell mx my d
    f s = (s, redraw s $ MouseUp (mx, my))
    ns d = step su resolveAllCandidates
    es d  | d == 4    = empty4x4Sudoku
          | d == 9    = empty9x9Sudoku
          | d == 12   = empty12x12Sudoku

handleEvents state@(State {stage="solver",selectedCell=sc,sudoku=su,dim=d,..}) (Prompt ("Enter a number", n))
  = (s', redraw s' NoInput)
  where
    c = head n
    (row, column) = fromJust sc
    su' | isNothing sc ||
          not (isAllowed su row column c)
        = su
        | isJust sc
        = (update (su) c (fst $ fromJust sc) (snd $ fromJust sc))
    s'  | su == su'
        = state { selectedCell = Nothing, sudoku = su', invalidCell = sc }
        | otherwise
        = state { selectedCell = Nothing, sudoku = su' }

handleEvents s (MouseMotion (mx, my))
  = (s, redraw s $ MouseMotion (mx, my))

handleEvents s (MouseDown (mx, my)) =
  let s' = s { mousePressed = True, invalidCell = Nothing }
  in (s', redraw s' $ MouseDown (mx, my))

handleEvents s (MouseUp (mx, my)) =
  let s' = s { mousePressed = False }
  in (s', redraw s' $ MouseUp (mx, my))

handleEvents s _ = (s, [])

redraw :: State -> Input -> [Output]
redraw s e
  | stage s == "menu"
  = [DrawOnBuffer True, ScreenClear, DrawPicture $ Menu.draw s e]
  | stage s == "solver"
  = [DrawOnBuffer True, ScreenClear, DrawPicture $ Solver.draw s e]



