module RayTracer.HelpersTransport3D (cheapTrans, cheapSums, cheapXs, cheapYs, cheapZs,
                                     transportStr, displayTrace) where
import RayTracer.Crossings

type IntCoords = (Int, Int, Int)
type SegmentLength = Double


-- displayTrace (0,0) (pi/4, pi/4)
displayTrace cs as = do
  let ijkSeg = transportStr cs as
  let eval = take 10 [ (ijk, str) | (ijk, seg, str) <- takeWhile stopCond ijkSeg]
  putStr "evaluated total:\n\n"
  putStr.unlines.(map show) $ eval
  where
    stopCond ((x,y,z), s, str) = x<=7 && y<=7 && z <=7

cheapTrans (x, z) (t, p) = do
  let ijkSeg = take 10 $ transportStr (x, z) (t, p)
  putStr "evaluated total:\n\n"
  putStr.unlines.(map show) $ ijkSeg

cheapZs (x, z) (t, p) = do
  let ijkSeg = take 10 $ zcrossings (x, z) (t, p)
  putStr "evaluated total:\n\n"
  putStr.unlines.(map show) $ ijkSeg

cheapXs (x, z) (t, p) = do
  let ijkSeg = take 10 $ xcrossings (x, z) (t, p)
  putStr "evaluated total:\n\n"
  putStr.unlines.(map show) $ ijkSeg

cheapYs (x, z) (t, p) = do
  let ijkSeg = take 10 $ ycrossings (x, z) (t, p)
  putStr "evaluated total:\n\n"
  putStr.unlines.(map show) $ ijkSeg

cheapSums (x,z) (t,p) = do
  let ijkSeg = transportStr (x,z) (t,p)
  let eval = [ seg | (ijk, seg, str) <- takeWhile stopCond ijkSeg]
  putStr "evaluated totals:\n"
  putStr.unlines.(map show) $ eval
  putStr "\nevaluated total:\n"
  putStr.show $ sum eval
  putStr "\n"
  where
    stopCond ((x,y,z), s, str) = x<=7 && y<=7 && z <=7
{--
This is going to need very very much work.
θ, φ cases individually.
--}

transportStr :: EntryCoords-> EntryAngles -> [(IntCoords, SegmentLength, String)]
transportStr (x, z) (θ, φ)
  | θ > pi/2 && φ > pi/2 =
                 f (xcs (x, z) (θ, φ))
                 (ycs (x, z) (θ, φ))
                 (zcs (x, z) (θ, φ))
                 (x, 0, z) -- pt
                 (floor x, 0, floor z) -- i j k, z offset by φ?
                 (negate 1, negate 1) -- sig
  | θ > pi/2 && φ <= pi/2 =
                 f (xcs (x, z) (θ, φ))
                 (ycs (x, z) (θ, φ))
                 (zcs (x, z) (θ, φ))
                 (x, 0, z) -- pt
                 (floor x, 0, floor z) -- i j k, z offset by φ?
                 (negate 1, 1) -- sig
  | θ <= pi/2 && φ <= pi/2 =
                 f (xcs (x, z) (θ, φ))
                 (ycs (x, z) (θ, φ))
                 (zcs (x, z) (θ, φ))
                 (x, 0, z)
                 (floor x, 0, floor z)
                 (1, 1)
  | θ <= pi/2 && φ > pi/2 =
                 f (xcs (x, z) (θ, φ))
                 (ycs (x, z) (θ, φ))
                 (zcs (x, z) (θ, φ))
                 (x, 0, z) -- pt
                 (floor x, 0, floor z)
                 (1, negate 1)
  where
    (xcs, ycs, zcs) = (xcrossings, ycrossings, zcrossings)

    -- order of the following methods matters.
    -- xcs ycs zcs (p,q,r) (i,j,k) sig
    f ((xh,yh,zh): xcs) ((xv,yv,zv): ycs) ((xd,yd,zd): zcs) pt (i, j, k) (sθ, sφ)
      | yh == minimum [yh, yv, yd] = -- x case
        ((i,j,k), segment pt (xh,yh,zh), "X") :
          f xcs ((xv,yv,zv): ycs) ((xd,yd,zd): zcs)
          (xh,yh,zh) -- pt
          (i+sθ, j, k)
          (sθ, sφ)

      | yd == minimum [yh, yv, yd]  = -- z case
        ((i,j,k), segment pt (xd,yd,zd), "Z") :
          f ((xh,yh,zh): xcs) ((xv,yv,zv): ycs) zcs
          (xd,yd,zd) -- pt
          (i, j, k+sφ)
          (sθ, sφ)

      | yv == minimum [yh, yv, yd] = -- y case
        ((i,j,k), segment pt (xv,yv,zv), "Y") :
          f ((xh,yh,zh): xcs) ycs ((xd,yd,zd): zcs)
            (xv,yv,zv) -- pt
            (i, j+1, k)
            (sθ, sφ)

segment :: Coords -> Coords -> SegmentLength
segment (x1, y1, z1) (x2, y2, z2) =
  sqrt $ (x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2