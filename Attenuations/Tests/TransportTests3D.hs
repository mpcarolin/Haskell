
{-# OPTIONS_GHC -F -pgmF htfpp #-}
{-# LANGUAGE BangPatterns #-}

module Tests.TransportTests3D where
import Tests.ExplicitGenerators
import RayTracer.FileToVector -- fileToAry, qArray, vLength, vSum
import RayTracer.Transport3D

import qualified Data.Vector.Unboxed as U
import Test.QuickCheck.Monadic
import Test.Framework

-- 3D data files: 7x7x7
allOnes = fileToAry "./Tests/dataallOnes3D"
gradientDoubles = fileToAry "./Tests/datagradArray3D"

{--

-- Arbitrary Lattice Tests
prop_QueryArbitraryLattice :: U.Vector Double -> Gen Bool
prop_QueryArbitraryLattice ary = do
  let rootSize = floor.sqrt.fromIntegral $ U.length ary
  x <- choose (0::Int, rootSize-1)
  y <- choose (0::Int, rootSize-1)
  return $ (abs.qArray rootSize (x, y)) ary >= 0

-- Ray Tests
prop_gradientArraySymmetry :: TestRay -> Property
prop_gradientArraySymmetry (Ray x θ) = monadicIO $ do
  ary <- run gradientDoubles
  let ijSeg = tail $ transport x θ -- because the head is not necessary.
  let pqSeg = tail $ uncurry transport $ mirrorCoords (x, θ)

  assert $ (eBall 13) (integrate ijSeg ary) (integrate pqSeg ary)
  where
    stopCond ((x,y), s) = x<7 && y<7 && x>0
    integrate l a = sum [ seg * qArray 7 ij a |
        (ij, seg) <- takeWhile stopCond l]

prop_stratifiedArraySymmetry :: TestRay -> Property
prop_stratifiedArraySymmetry (Ray x θ) = monadicIO $ do
  ary <- run stratifiedDoubles
  let ijSeg = tail $ transport x θ -- because the head is not necessary.
  let pqSeg = tail $ uncurry transport $ mirrorCoords (x, θ)

  assert $ (eBall 13) (integrate ijSeg ary) (integrate pqSeg ary)
  where
    stopCond ((x,y), s) = x<7 && y<7 && x>0
    integrate l a = sum [ seg * qArray 7 ij a |
        (ij, seg) <- takeWhile stopCond l]

prop_allOnesSymmetry :: TestRay -> Property
prop_allOnesSymmetry (Ray x θ) = monadicIO $ do
  ary <- run allOnes
  let ijSeg = tail $ transport x θ -- because the head is not necessary.
  let pqSeg = tail $ uncurry transport $ mirrorCoords (x, θ)

  assert $ (eBall 13) (integrate ijSeg ary) (integrate pqSeg ary)
  where
    stopCond ((x,y), s) = x<7 && y<7 && x>0
    integrate l a = sum [ seg * qArray 7 ij a |
        (ij, seg) <- takeWhile stopCond l]


mirrorCoords :: (XCoord, Angle) -> (XCoord, Angle)
mirrorCoords (x, θ) = (7-x, pi-θ)

prop_mirrorCoordsSelfInverse :: Gen Bool
prop_mirrorCoordsSelfInverse = do
  x <- choose (0, 7::Double)
  t <- zeroToPi
  let (y, s) = mirrorCoords.mirrorCoords $ (x, t)
  return $ (eBall 13) x y && (eBall 13) s t

--}

{-- 
  φ determines projection:
  φ == 0 or φ == pi => pure z component
  φ == π/2 => pure x-y components
--}

prop_pureZComponent = do
  s <- choose (3, 100::Double)
  φ <- oneof [return 0, return pi]
  θ <- zeroToPi
  x <- interval
  z <- interval
  let ijkSeg = transport (x*s, z*s) (θ, φ)
  return $ all (pureZcond x s) $ take 30 ijkSeg
  where    
    pureZcond x s ((i,j,k), _, _) =
      and [ i == floor (x * s), j == 0]

prop_pureXYComponents = do
  s <- choose (3, 100::Double)
  let φ = pi/2
  θ <- zeroToPi
  x <- interval
  z <- interval
  let ijkSeg = transport (x*s, z*s) (θ, φ)
  return $ all (pureZcond (z * s)) $ take 30 ijkSeg
  where    
    pureZcond z ((i,j,k), _, _) = k == floor z



{--
  fixing φ == π/2
  θ == 0 or θ == π => pure x component
  θ == π/2 ==> pure y component
--}

test_ArrayIsSevenCubed = do
  ones <- allOnes
  assertEqual (vLength ones) 343

test_ArrayIsAllOnes = do
  ones <- allOnes
  assertEqual (vSum ones) 343

-- test_allOnesDiagonal = do
--   ary <- allOnes
--   let pts = (0, 0)
--   let angles = (pi/4, pi/4)
--   let ijkSeg = transport pts angles
--   let eval = sum [ seg * qArray 7 ijk ary | (ijk, seg) <- takeWhile stopCond ijkSeg]
--   assertEqual (eval - correction) (7 * sqrt 3)
--   where
--     correction = 0.0
--     stopCond ((x,y,z), s) = x<7 && y<7 && z<7
