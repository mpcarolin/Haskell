module ExampleTree where
import DiagonalTrees

{--
freeTree defaults to 1 in it's first node.
this ensures that all nodes along a path
contribute to the length of the accumulated
string.
--}

data Flag = Zero | One | Two | Full deriving (Show, Eq)

type Traversal a = Zipper (a, Int, Flag)

freeTree :: Tree (Integer, Int, Flag)
freeTree = tree (1, 1, One)
  where
    tree (n, h, flag) =
      Node (n, h, flag) (tree (1+n*10, h+1, One))
                        (tree ( n*10, h+1, One))
                        (tree (2+n*10, h+1, One))

getFlag :: Traversal a -> Flag
getFlag (Node (n, h, flag) l c r, bs) = flag

getHeight :: Traversal a -> Int
getHeight (Node (n, height, flag) l c r, bs) = height

getVal :: Traversal a -> a
getVal (Node (n, height, flag) l c r, bs) = n 

setFlag :: Flag -> Traversal a -> Traversal a
setFlag flag (Node (n, h, f) l c r, bs) = (Node (n, h, flag) l c r, bs)
