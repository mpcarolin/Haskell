
{-# OPTIONS_GHC -F -pgmF htfpp #-}

module Tests.SymmetryTests where
import RayTracer.RayLength
import Test.Framework

{--
Truly generalized algebraic testing.

import Text.Show.Functions

prop_ComposeAssoc f g h x =
  ((f . g) . h) x == (f . (g . h)) x
  where types = [f, g, h] :: [Int->Int]
--}

--tolerance 12 decimal places
--better would be an epsilon ball
tol :: Double -> Integer
tol d = round $ d * 10^12

-- TODO: figure out replay args.
-- replayArg = "Just (TFGenR 15067B55359906C0776B9C0A73ACEE7D9C124B4AE3DAC3AFCB451E04B1EF7BD1 0 31 5 0,28)"
-- pt = ((0.0, 0.0), -63.8735667731305)
-- prop_rot4IdReplay =
--   withQCArgs (\a -> a { replay = read replayArg })
--   prop_rot4Id

-- Rotation Tests
prop_rot90 = do
  x <- choose (0, pi)
  return $ (tol.cos) (pi/2 - x) == (tol.sin) x

prop_rot4Id x y t =
  let coords = ((x, y),t) in
  let rotFour = foldr (.) id [rot90 | x<-[1..4]] in
  (mtol.divPi.rotFour) coords == mtol coords
  where
    divPi ((x, y),theta) = ((x, y), theta - (2*pi))
    mtol ((x,y), t) = ((ttol x, ttol y), ttol t)
    ttol d = round $ d * 10^9 -- not very good accuracy.

prop_rotInv' x y t = let coords = ((x, y),t) in
  (mtol.rot90.rot270) coords == mtol coords
  where
    mtol ((x,y), t) = ((tol x, tol y), tol t)

prop_rotInv = do
  x <- choose (0,1)
  y <- choose (0,1)
  t <- choose (0,2*pi)
  let coords = ((x,y), t)
  let mtol ((x,y), t) = ((tol x, tol y), tol t)
  let rotTol = mtol.rot90.rot270
  return $ rotTol coords == mtol coords
