import Debug.Trace(trace)
import Data.Array

data Color = Black | White deriving(Show, Eq)

type Coord = (Int,Int) 

type Board = Array Coord (Maybe Color)
type Ply = Int
type Counts = (Int,Int)
data Othello = Othello Board Ply Counts deriving(Show)
data Move = Move Coord [Coord] deriving(Show)

size :: (Coord,Coord)
size = ((0,0),(7,7))
initialBoard :: Board
initialBoard = array size (zip (range size)$ repeat Nothing) // [((3,3),Just White),((4,4),Just White),((3,4),Just Black),((4,3),Just Black)]

initialOthello :: Othello
initialOthello= Othello initialBoard 0 (2,2)

inv :: Color->Color
inv Black = White
inv White = Black

around :: [Coord]
around = [(1,1),(1,0),(1,-1),(0,1),(0,-1),(-1,1),(-1,0),(-1,-1)]

onBoard :: Coord->Bool
onBoard (i,j) = 0<=i && i<8 && 0<=j && j<8

canPut :: Coord->Color->Board->[Coord]
canPut (x,y) color board = concat$ do
    (vi,vj)<-around
    let tak = span f$ tail$ iterate (\(i,j)->(i+vi,j+vj)) (x,y)
    let dest = head (snd tak)
    return$ if onBoard dest && (board!dest)==Just color then fst tak else []
  where enemy = inv color
        f c = onBoard c && board!c == Just enemy

getMoves :: Color->Board->[Move]
getMoves color board = do
    x<-[0..7]
    y<-[0..7]
    let canput = canPut (x,y) color board
    if canput==[] then [] else [Move (x,y) canput]
