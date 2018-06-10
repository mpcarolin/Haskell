module Tests.ExplicitGenerators where
import qualified Data.Vector.Unboxed as U  -- strict fast Arrays
import Test.Framework

-- Constants
tau = 2 * pi

-- Explicit Generators
interval = choose (0, 1::Double)
zeroToPi = choose (0, pi::Double)
zeroToTau = choose (0, tau::Double)
halfPiToPi = choose (pi/2, pi::Double)
zeroToHalfPi = choose (0, pi/2::Double)
squareInt = (^ 2) `fmap` (arbitrary :: Gen Int) `suchThat` (> 0)

-- Compound Generators
data TestRay = Ray (Double, Double) (Double, Double) deriving (Show, Eq)
data TestCoords = CS (Double, Double) deriving (Show, Eq)
data TestAngle = Angle Double deriving (Show, Eq)

instance Arbitrary TestAngle where
  arbitrary = do
    theta <- zeroToPi
    return (Angle theta)

instance Arbitrary TestCoords where
  arbitrary = do
    x <- interval
    z <- interval
    return $ CS (x, z)

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
    z <- squareInt
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

tol :: Double -> Integer
tol d = round $ d * 10^12

mtol :: DoubleCoords -> IntegerCoords
mtol ((x,y), t) = ((tol x, tol y), tol t)