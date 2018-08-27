{--
http://www.analog.com/media/en/technical-documentation/dsp-book/dsp_book_Ch16.pdf
--}
module Filters.BandPass where
import qualified Data.Vector.Unboxed as U
import Data.Int (Int32)

type SamplesR = U.Vector Double
type VectSamples = U.Vector Int32
type CutOffFreq = Double
type Q = Double

-- Todo: Q ought be a function of mm where mm = 4/BW
(mm, mm') = (100::Int, 100::Double)

blackman j m = 0.42 - 0.5*cos(2*pi*j/m) + 0.08*cos(4*pi*j/m)
hamming j m  = 0.54 - 0.46*cos(2*pi*j/m)
sinc f j m | j == m/2 = 2*pi*f/44100
           | otherwise = sin(2*pi*f/44100 * (j-m/2)) / (j-m/2)

hh :: CutOffFreq -> SamplesR -- kernel
hh fc = normalize $ U.generate (mm+1) (g.fromIntegral)
  where
    normalize h = U.map (/ (U.sum h)) h
    g j = (sinc fc j mm') * blackman j mm'

specInv :: SamplesR -> SamplesR
specInv ss = U.map negate ss

mixBands :: SamplesR -> SamplesR -> SamplesR
mixBands ss tt = U.zipWith (+) ss tt -- may need normalized

bandPass :: Q -> CutOffFreq -> VectSamples -> VectSamples
bandPass q freq samples =
  let (low, hi) = (freq - q/2, freq + q/2)
      xx = (U.map fromIntegral samples)::SamplesR
      padx = (U.++) (U.replicate mm (0::Double)) xx
      lp = U.generate (U.length xx) (f padx (hh low))
      hp = specInv $ U.generate (U.length xx) (f padx (hh hi))
  in U.map floor $ U.drop mm $ specInv.mixBands lp $ hp
  where
    f x h j = sum [(U.!) x (j+mm-i) * (U.!) h i | i<-[0..mm]]
