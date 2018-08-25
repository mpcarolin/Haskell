module Filters.BandPass where
import qualified Data.Vector.Unboxed as U
import Data.Int (Int32)
import System.Random
import Data.WAVE
import Wave

{--
http://www.analog.com/media/en/technical-documentation/dsp-book/dsp_book_Ch16.pdf
--}

randos :: VectSamples
randos = (U.fromList).(take 22050) $ rs
  where rs = randomRs (minBound, maxBound::Int32) $ mkStdGen 23

type SamplesR = U.Vector Double
type VectSamples = U.Vector Int32
type CutOffFreq = Double

(mm, mm') = (100::Int, 100::Double)

blackman v j m = (* v) $ 0.42 - 0.5*cos(2*pi*j/m) + 0.08*cos(4*pi*j/m)
hamming v j m  = (* v) $ 0.54 - 0.46*cos(2*pi*j/m)

hh :: CutOffFreq -> SamplesR -- kernel
hh fc = normalize $ U.generate (mm+1) (g.fromIntegral)
  where
    normalize h = U.map (/ (U.sum h)) h

    g j | j == mm'/ 2 = blackman (2*pi*fc/44100) j mm'
        | otherwise =
          let val = sin(2*pi*(fc/44100) * (j-mm'/2)) / (j-mm'/2) in
          blackman val j mm'
          -- hamming val j mm'

spectralInv :: SamplesR -> SamplesR
spectralInv ss = U.map negate ss

mixBands :: SamplesR -> SamplesR -> SamplesR
mixBands ss tt = U.zipWith (+) ss tt -- may need normalized

-- needs q as well as freq
bandPass :: CutOffFreq -> VectSamples -> VectSamples -- q about 352.8
bandPass freq samples = -- Convolve the input signal & filter kernel
  let (low, hi) = (freq - 100, freq + 100) in
  let xx = (U.map fromIntegral samples)::SamplesR in
  let padx = (U.++) (U.replicate mm (0::Double)) xx in
  let lp = U.generate (U.length xx) (f padx (hh low)) in
  let hp = spectralInv $ U.generate (U.length xx) (f padx (hh hi)) in
  U.map floor $ U.drop mm $ spectralInv.mixBands lp $ hp
  where
    f x h j = sum [(U.!) x (j+mm-i) * (U.!) h i | i<-[0..mm]]

test =
  let qs = [200, 400, 600, 1000, 2000, 5000, 10000] in
  let them = [bandPass] <*> qs <*> [randos] in
  makeWavFile $ U.concat them

testBandPass = do
  w <- getWAVEFile "blow.wav"
  let them = [bandPass] <*> [200, 400, 600, 1000] <*> [unpack w]
  makeWavFile $ U.concat them
