-- module ContravariantPowerset where
import qualified Control.Monad as M
import Prelude hiding (fmap, Functor, Monad) 
import Data.Functor.Contravariant
import Data.List

{--
The idea is to learn to build a contravariant powerset
monad using the Contravariant library.
import Data.Function
import Data.Functor.Contravariant (Contravariant (..))
--}

data F a = F (a -> Int)

instance Contravariant F where
  contramap f (F g) = F (g . f)

--------

data List a = List [a] deriving (Show, Eq)
data Powerset a = P [List a] deriving (Show, Eq)

powerset xs = M.filterM (\x -> [True, False]) xs

instance Functor List where
  fmap f (List []) = List []
  fmap f (List xs) = List $ map f xs

class Functor f where
  fmap :: (Functor f, Eq b) => (a -> b) -> f a -> f b

instance Functor Powerset where
  fmap f (P []) = P []
  fmap f (P lists) = P $ map (fmap f) $ lists

incl :: a -> List a
incl x = List [x]

eta :: a -> Powerset a
eta x = P $ map List (powerset [x])

etaP :: a -> Powerset (Powerset a)
etaP = eta.eta

class Monad m where
  return :: a -> m a
  (>>=) :: Eq b => m a -> (a -> m b) -> m b

instance Monad Powerset where
  return = eta
  m >>= f = mu $ fmap f $ m

mu :: Eq a => Powerset (Powerset a) -> Powerset a
mu (P xs) = let list = unionFL xs in P (cc list)
            where cc (List [P xs]) = xs

unionL :: Eq a => List a -> List a -> List a
unionL (List x) (List y) = List $ union x y

unionFL :: Eq a => [List a] -> List a
unionFL = foldr unionL (List [])