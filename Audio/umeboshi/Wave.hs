module Wave (unpack, pack, makeWavFile) where
import qualified Data.Vector.Unboxed as U
import Data.Int (Int32)
import Data.WAVE

type VectSamples = U.Vector Int32

header = WAVEHeader 1 44100 16 Nothing

unpack :: WAVE -> [Int32]
unpack = (map head).waveSamples

pack :: VectSamples -> WAVE
pack xs = WAVE header $ map (:[]) $ U.toList xs

makeWavFile :: VectSamples -> IO ()
makeWavFile wav = putWAVEFile "temp.wav" $ pack wav
