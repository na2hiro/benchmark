import Debug.Trace(trace)
import Data.Array
import Data.List(intercalate)

data Color = Black | White deriving(Eq)
instance Show Color where
    show Black = "o"
    show White = "x"

type Coord = (Int,Int) 

type Board = Array Coord (Maybe Color)
type Ply = Int
type Counts = (Int,Int)
data Othello = Othello Board Ply Counts
data Move = Move Coord [Coord] | Pass deriving(Show)

instance Show Othello where
    show (Othello board ply counts)=showBoard board++"\nply:"++show ply++",counts:"++show counts

size :: (Coord,Coord)
size = ((0,0),(7,7))
initialBoard :: Board
initialBoard = array size (zip (range size)$ repeat Nothing) // [((3,3),Just White),((4,4),Just White),((3,4),Just Black),((4,3),Just Black)]

initialOthello :: Othello
initialOthello= Othello initialBoard 0 (2,2)

showBoard :: Board->String
showBoard b = Data.List.intercalate"\n"[concat[maybe "." show (b!(x,y))|y<-range (y1,y2)]|x<-range (x1,x2)]
    where ((x1,y1),(x2,y2))=size

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
getMoves color board = if null ret then [Pass] else ret
    where ret = do
                  x<-[0..7]
                  y<-[0..7]
                  let canput = canPut (x,y) color board
                      if canput==[] then [] else [Move (x,y) canput]

turnColor :: Othello->Color
turnColor (Othello _ ply _) = if rem ply 2==0 then Black else White

doMove :: Move->Othello->Othello
doMove Pass (Othello board p c) = Othello board (p+1) c
doMove (Move put@(x,y) changes) o@(Othello board p c) = (Othello newboard (p+1) c)
  where color=turnColor o
        newboard = board // zip (put:changes) (repeat$ Just color)

evaluate :: Othello->Int
evaluate o@(Othello _ _ (cb,cw)) = (if gameEnd o then 100 else 1)*(cb-cw)

gameEnd :: Othello->Bool
gameEnd (Othello _ _ (cb,cw)) = cb+cw==64
