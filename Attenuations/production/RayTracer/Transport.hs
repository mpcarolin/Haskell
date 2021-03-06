module RayTracer.Transport (transport) where
import RayTracer.Crossings

type SegmentLength = Double
type IntCoords = (Int, Int, Int)

segment :: Coords -> Coords -> SegmentLength
segment (x1, y1, z1) (x2, y2, z2) =
  sqrt $ (x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2

transport:: EntryCoords-> EntryAngles -> [(IntCoords, SegmentLength)]
transport (x, z) (θ, φ) =
    f (xcrossings (x, z) (θ, φ))
      (ycrossings (x, z) (θ, φ))
      (zcrossings (x, z) (θ, φ))
      (x, 0, z) -- pt
      (floor x, 0, floor z) -- i j k, z offset by φ?
      (orient θ, orient φ) -- sig
  where
    orient τ | τ > pi/2 = -1
             | otherwise = 1

    -- xcs ycs zcs (p,q,r) (i,j,k) sig
    f ((xh,yh,zh): xcs) ((xv,yv,zv): ycs) ((xd,yd,zd): zcs) pt (i, j, k) (sθ, sφ)
      | yh == minimum [yh, yv, yd] = -- x case
        ((i,j,k), segment pt (xh,yh,zh)) :
          f xcs ((xv,yv,zv): ycs) ((xd,yd,zd): zcs)
          (xh,yh,zh) (i+sθ, j, k) (sθ, sφ)

      | yd == minimum [yh, yv, yd] = -- z case
        ((i,j,k), segment pt (xd,yd,zd)) :
          f ((xh,yh,zh): xcs) ((xv,yv,zv): ycs) zcs
          (xd,yd,zd) (i, j, k+sφ) (sθ, sφ)

      | yv == minimum [yh, yv, yd] = -- y case
        ((i,j,k), segment pt (xv,yv,zv)) :
          f ((xh,yh,zh): xcs) ycs ((xd,yd,zd): zcs)
            (xv,yv,zv) (i, j+1, k) (sθ, sφ)
