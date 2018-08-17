module Main where
import Data.Array.Unboxed (UArray, elems, listArray)
import System.Directory (doesPathExist, createDirectory)
import System.Random (mkStdGen, randomRs)
import Data.List (sort)

import qualified Data.Vector.Unboxed as U
import System.Random (mkStdGen, randomRs)
import Data.List (sort)

type ULattice = UArray Int Double
type Lattice = U.Vector Double

main = do -- Write empty plates and test data.
  sparse  <- doesPathExist "./Data/sparseArray3D"
  emptyA  <- doesPathExist "./Data/emptyArray2D"
  dataDir <- doesPathExist "./Data"
  if dataDir
    then putStr "\n/Data exists\n"
    else do
      putStr "creating Data directory"
      createDirectory "./Data"
  if sparse
    then putStr "sparseArray3D exists\n"
    else do
      putStr "creating sparseArray3D"
      saveArr "sparseArray3D" sparseArray3D

  if emptyA
    then putStr "emptyArray2D exists\n"
    else do
      putStr "creating emptyArray2D"
      saveZeros 1000

randos = randomRs (0, 1::Double).mkStdGen $ 32

-- Produces an empty plate and a stratified data file of given size
dataGeneration :: Int -> IO()
dataGeneration n = do
  saveZeros 1000
  saveArr "./Data/sparseArray3D" sparseArray3D

-- saveArr "GradArray" gradArray => "./Data/dataGradArray"
saveArr :: String -> ULattice -> IO()
saveArr file ary =
  writeFile ("./Data/"++file) $ aryToStr ary
  where aryToStr = unlines.(map show).elems

savePlate :: Lattice -> IO()
savePlate ary =
  writeFile "./Data/savedPlate" $ aryToStr ary
  where aryToStr = unlines.(map show).(U.toList)

saveZeros :: Int -> IO()
saveZeros n =
  let zeros = take (n^2) $ repeat (0.0::Double) in
  writeFile "./Data/emptyArray2D" $ aryToStr zeros
  where aryToStr = unlines.(map show)

sparseArray3D :: ULattice
sparseArray3D =
  let sparse = randomRs (1::Int, 1000) $ mkStdGen 32 in
  let spRandos = [ if r == 1 then t else 0.0 | (t, r) <- zip randos sparse] in
  let bounds = (0::Int, 10^9-1) in
  listArray bounds spRandos

-- takes a size and returns a cube.
stratifiedArray3D :: Int -> ULattice
stratifiedArray3D size =
  let grades = take size randos in
  let ary = foldr (++) [] $ map crossSection grades in
  listArray (1::Int, size^3) ary
  where
    crossSection = take (size^2) . repeat