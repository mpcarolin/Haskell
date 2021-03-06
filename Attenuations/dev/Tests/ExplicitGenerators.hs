module Tests.ExplicitGenerators where
import qualified Data.Vector.Unboxed as U  -- strict fast Arrays
import Test.Framework

-- Constants
tau = 2 * pi

-- Explicit Generators
distance = choose(1, 1000::Double)
interval = choose (0, 1::Double)
zeroToPi = choose (0, pi::Double)
zeroToTau = choose (0, tau::Double)
halfPiToPi = choose (pi/2, pi::Double)
zeroToHalfPi = choose (0, pi/2::Double)
squareInt = (^ 2) `fmap` (arbitrary :: Gen Int) `suchThat` (> 0)
cubeInt = (^ 3) `fmap` (arbitrary :: Gen Int) `suchThat` (> 0)
exitAngle x = choose((1+x)*pi/4, pi/2 + x*pi/4)
sign = oneof [return 1.0, return (-1.0)]
deviation = choose(1, 4::Double)

-- strange needs.
multiplesof20Int = (arbitrary :: Gen Int) `suchThat` cond
  where
    cond n = n > 0 && (mod n 20 == 0) && n < 1001

squareEvenInt = (^ 2) `fmap` (arbitrary :: Gen Int) `suchThat` cond
  where
    cond n = n > 0 && even n && n < 1001

-- Compound Generators
data TestExit = Vars (Double, Double) (Double, Double) deriving (Show, Eq)
data TestRay = Ray (Double, Double) (Double, Double) deriving (Show, Eq)
data TestCoords = Coords (Double, Double) deriving (Show, Eq)
data TestSignPair = Sigs (Double, Double) deriving (Show, Eq)
data TestDistance = Distance Double deriving (Show, Eq)
data TestAngle = Angle Double deriving (Show, Eq)
data StdDev = Dev Double deriving (Show, Eq)

instance Arbitrary StdDev where
  arbitrary = do
    σ <- deviation
    return $ Dev σ

instance Arbitrary TestSignPair where
  arbitrary = do
    s <- sign
    r <- sign
    return $ Sigs (s, r)

instance Arbitrary TestDistance where
  arbitrary = do
    d <- distance
    return $ Distance d

instance Arbitrary TestExit where
  arbitrary = do
    x <- interval
    z <- choose(0, 0.5) -- 0.65 good upto 1M tests.
    θ <- choose((1+x)*pi/4, pi/2)
    -- if θ is pi/4 => atan (sqrt 2) < φ < pi/2
    -- if θ is pi/2 => pi/4 < φ < pi/2
    let t θ = 2 - 4*θ/pi
    let var θ = atan (sqrt 2) * t θ + (1 - t θ)*pi/4
    φ <- choose((1+z)*var θ, pi/2)
    return $ Vars (x, z) (θ, φ)

instance Arbitrary TestAngle where
  arbitrary = do
    theta <- zeroToPi
    return (Angle theta)

instance Arbitrary TestCoords where
  arbitrary = do
    x <- interval
    z <- interval
    return $ Coords (x, z)

instance Arbitrary TestRay where
  arbitrary = do
    x <- interval
    z <- interval
    t <- zeroToPi
    p <- zeroToPi
    return $ Ray (x, z) (t, p)

instance (U.Unbox a, Arbitrary a) => Arbitrary (U.Vector a) where
  arbitrary = do
    ls <- arbitrary
    z <- resize 5 cubeInt -- limited for testing.
    return $ U.generate z ls

{--
  δ β      ρ         ρ'
ε_\|/_α   |/_κ    κ'_\|
--}
epsilonRegion x = choose (3*pi/4 + x*pi/4, pi) -- super-εδ-Condition
deltaRegion x = choose (pi/2, pi/2 + x*pi/4) -- sub-εδ-Condition

betaRegion  x = choose ((1+x) * pi/4, pi/2) -- super-αβ-Condition
alphaRegion x = choose (0, (1+x) * pi/4) -- sub-αβ-Condition

rhoRegion x = choose (pi/4, (1+x) * pi/4) -- super-ρκ-Condition
kappaRegion x = choose (0, (1-x) * pi/4) -- sub-ρκ-Condition

-- Tolerances
type DoubleCoords =  ((Double, Double), Double)
type IntegerCoords = ((Integer, Integer), Integer)

eBall :: Double -> Double -> Double -> Bool
eBall t a b = (< 1/10**t).abs $ a - b

eBalls :: Double -> (Double, Double) -> (Double, Double) -> Bool
eBalls t (a, b) (c, d) = eBall t a c && eBall t b d

tol :: Double -> Integer
tol d = round $ d * 10^12

mtol :: DoubleCoords -> IntegerCoords
mtol ((x,y), t) = ((tol x, tol y), tol t)