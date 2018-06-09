module RayTracer.Transport3D where
import RayTracer.FileToVector

type Coords = (XCoord, YCoord, ZCoord)
type EntryCoords = (XCoord, ZCoord)
type EntryAngles = (Angle, Angle)
type SegmentLength = Double
type XCoord = Double
type YCoord = Double
type ZCoord = Double
type Angle  = Double

-- displayTrace (0,0) (pi/4, pi/4)
displayTrace cs as = do
  ary <- fileToAry "./Tests/dataallOnes3D"
  let (_:ijkSeg) = transport cs as -- because the head is not necessary.
  let eval = take 30 [ (ijk, str) | (ijk, seg, str) <- takeWhile stopCond ijkSeg] -- just coords
  -- let eval = [ seg * (qArray 7 ijk ary) | (ijk, seg) <- takeWhile stopCond ijkSeg]
  putStr "evaluated total:\n\n"
  putStr.unlines.(map show) $ eval
  where
    stopCond ((x,y,z), s, str) = x<=7 && y<=7 && z <=7


{--
A start on incorporating the z and φ components.
The guess below cannot be correct. The z component
is a function of both φ and θ (a projective cone).
--}
xcrossings :: EntryCoords -> EntryAngles -> [Coords]
xcrossings (x, z) (θ, φ)
  | θ > pi/2 = [(ff x - k, -(frac x + k)*tan θ, zc z θ φ k) | k<-[0..]]
  | otherwise = [(ff x + k + 1, (1 - frac x + k)*tan θ, zc z θ φ k) | k<-[0..]]
  where
    zc z θ φ k | φ == 0 || φ == pi = z -- probably should get theta case too.
               | φ <= pi/2 = z + k / (tan φ * cos θ)
               | otherwise = z + k / (tan φ * cos θ) -- not sure here

ycrossings :: EntryCoords -> EntryAngles -> [Coords]
ycrossings (x, z) (θ, φ) = [ (x + k / tan θ, k, zc z θ φ k) | k <- [0..]]
  where
    zc z θ φ k | φ  == 0 || φ == pi = z -- probably should get theta case too.
               | φ <= pi/2 = z + k / (tan φ * sin θ)
               | otherwise = z - k / (tan φ * sin θ) -- not sure here

-- verify how x- and y- components may need initial values.
zcrossings :: EntryCoords -> EntryAngles -> [Coords]
zcrossings (x, z) (θ, φ)
  | θ > pi/2 = [(k * cos θ * tan φ, k * sin θ * tan φ, ff z - k) | k<-[0..]]
  | otherwise = [(k * cos θ * tan φ, k * sin θ * tan φ, ff z + k + 1) | k<-[0..]] -- not sure here

{--
This is going to need very very much work.
θ, φ cases individually.

--}
type IntCoords = (Int, Int, Int)
-- transport:: EntryCoords-> EntryAngles -> [(IntCoords, SegmentLength)]
transport (x, z) (θ, φ)
  | θ > pi/2 = f (xcs (x, z) (θ, φ))
                 (ycs (x, z) (θ, φ))
                 (zcs (x, z) (θ, φ))
                 (x, 0, z) -- pt
                 (floor x, 0, ceiling z) -- i j k, z offset by φ?
                 (negate 1) -- sig

  | otherwise = f (xcs (x, z) (θ, φ))
                  (ycs (x, z) (θ, φ))
                  (zcs (x, z) (θ, φ))
                  (x, 0, z)
                  (floor x, 0, floor z)
                  1
  where
    (xcs, ycs, zcs) = (xcrossings, ycrossings, zcrossings)

    -- xcs ycs zcs (p,q,r) (i,j,k) sig
    f ((xh,yh,zh): xcs) ((xv,yv,zv): ycs) ((xd,yd,zd): zcs) pt (i, j, k) sign
      | yh == minimum [yh, yv, yd] = -- x case
        ((i,j,k), segment pt (xh,yh,zh), "X") :
          f xcs
            ((xv,yv,zv): ycs)
            ((xd,yd,zd): zcs)
            (xh,yh,zh) -- pt
            (i+sign, j, k)
            sign

      | yd == minimum [yh, yv, yd]  = -- z case
        ((i,j,k), segment pt (xv,yv,zv), "Z") :
          f ((xh,yh,zh): xcs)
          ((xv,yv,zv): ycs)
          zcs
          (xd,yd,zd) -- pt
          (i, j, k+sign)
          sign

      | yv == minimum [yh, yv, yd] = -- y case
        ((i,j,k), segment pt (xv,yv,zv), "Y") :
          f ((xh,yh,zh): xcs)
            ycs
            ((xd,yd,zd): zcs)
            (xv,yv,zv) -- pt
            (i, j+1, k)
            sign

segment :: Coords -> Coords -> SegmentLength
segment (x1, y1, z1) (x2, y2, z2) =
  sqrt $ (x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2

cc, ff :: Double -> Double
cc = fromIntegral.ceiling
ff = fromIntegral.floor
frac = snd.properFraction