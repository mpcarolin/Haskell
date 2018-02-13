{--
In this module, I aim to extend lists of numbers to the number class
by considering the 0th index to be the 0th place value of a number.
of course, this really only works for single digit list values.
an inclusion method is likely a good idea.

satisfactory methods for Num Class: + - * abs signum fromInteger

1) Given listify how do we write an inclusion methods
2) How do we write Num methods?
3) can we generalize the binary operations?
4) What about negative numbers?
--}

module ListsAsNumbers where

listify :: Integer -> [Integer]
listify 0 = []
listify n = (listify (div n 10)) ++ [mod n 10]

-- incl :: Integer -> NumList
-- eval :: NumList -> Integer

listOp :: (a -> a -> a) -> [a] -> [a] -> [a]
listOp bin [] ys = ys
listOp bin xs [] = xs
listOp bin (x:xs) (y:ys) = bin x y : listOp bin xs ys

data NumList = N [Integer] deriving (Show, Eq)

nl = N [1,2,3]
ml = N [4,5,6]

instance Num NumList where
  (+) (N xs) (N ys) = N $ listOp (+) xs ys
  (-) (N xs) (N ys) = N $ listOp (-) xs ys
  (*) (N xs) (N ys) = N $ listOp (*) xs ys
  signum (N xs) = N $ map signum xs
  abs (N xs) = N $ map abs xs
  fromInteger x = N $ listify x

f :: Integer -> NumList
f x = fromInteger x + (N [1,2,3])
