{-# LANGUAGE BangPatterns #-}

module RayTracer.ParallelTracer (parallelTrace) where
import Control.Parallel.Strategies (rdeepseq, parListChunk, using)
import RayTracer.Constants (center, size)
import RayTracer.FileToVector (qArray)
import RayTracer.Transport (transport)
import RayTracer.GaussianBeam (beam)

import qualified Data.Vector.Unboxed as U
import Data.List (foldl')

data Pair = Pair !Int !Double

{--
distance from source to face and converts mm to units.
a source 1mm distance to the front face is 4 units from the exit.
Thus the x2 in the input to the beam.

mmToUnits :: Double -> Double
mmToUnits d  = 2 * d
--}

parallelTrace ary d σ seed = do
  let gBeams = beam (2*d) σ seed -- Distance Deviation
  let rays = map (attenuation ary) gBeams
  let results = rays `using` parListChunk 1024 rdeepseq
  return results -- [(x, z, SegmentLength)]

attenuation ary ((x, z), (θ, φ)) =
  let path = takeWhile stopCond $ transport (x, z) (θ, φ) in
  let (i,j,k) = fst.last $ path in (i, k, sum' ary path)
  where
    stopCond ((x,y,z), _) =
      x<size && y<size && z<size &&
      x>=0 && z>=0

sum' :: U.Vector Double -> [((Int, Int, Int), Double)] -> Double
sum' ary xs = s
  where
    Pair n s       = foldl' k (Pair 0 0) xs
    k (Pair n s) x = Pair (n+1) (s + f x)
    f (ijk, seg) = seg * qArray size ijk ary