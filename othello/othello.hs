import Debug.Trace(trace)

data Color = Black | White deriving(Show, Eq)

type Coord = (Int,Int) 

type Board = [[Maybe Color]]
type Ply = Int
data Othello = Othello {getBoard:: Board, getPly:: Ply} deriving(Show)
data Move = Move Coord [Coord] deriving(Show)

initialBoard :: Board
initialBoard = no3++surroundNo3 [Just White,Just Black]:surroundNo3 [Just Black,Just White]:no3
  where surroundNo3 x = replicate 3 Nothing ++ x ++ replicate 3 Nothing
        no3 = replicate 3 (replicate 8 Nothing)

initialOthello :: Othello
initialOthello= Othello {getBoard=initialBoard, getPly=0}

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
    let dest@(nx,ny) = head (snd tak)
    return$ if onBoard dest && (board!!nx!!ny)==Just color then fst tak else []
  where enemy = inv color
        f c@(x,y) = onBoard c && (board!!x!!y)==Just enemy

getMoves :: Color->Board->[Move]
getMoves color board = do
    x<-[0..7]
    y<-[0..7]
    let canput = canPut (x,y) color board
    if canput==[] then [] else [Move (x,y) canput]
