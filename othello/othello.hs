import Data.Vector as V ((//), (!), replicate, Vector)
import Data.List(intercalate)

data Color = Black | White deriving(Eq)
instance Show Color where
    show Black = "o"
    show White = "x"

type Coord = (Int,Int) 

type Board = Vector (Maybe Color)
type Ply = Int
type Counts = (Int,Int)
data Othello = Othello !Board Ply Counts
data Move = Move Coord [Coord] | Pass deriving(Show)

instance Show Othello where
    show (Othello board ply counts)=showBoard board++"\nply:"++show ply++",counts:"++show counts

toI (x,y) = x+y*9

size :: (Coord,Coord)
size = ((0,0),(7,7))
initialBoard :: Board
initialBoard = V.replicate 81 Nothing // [(toI(3,3),Just White),(toI(4,4),Just White),(toI(3,4),Just Black),(toI(4,3),Just Black)]

initialOthello :: Othello
initialOthello= Othello initialBoard 0 (2,2)

showBoard :: Board->String
showBoard b = Data.List.intercalate"\n"[concat[maybe "." show (b!toI(x,y))|y<-[y1..y2]]|x<-[x1..x2]]
    where ((x1,y1),(x2,y2))=size

inv :: Color->Color
inv Black = White
inv White = Black

around :: [Coord]
around = [(1,1),(1,0),(1,-1),(0,1),(0,-1),(-1,1),(-1,0),(-1,-1)]

onBoard :: Coord->Bool
onBoard (i,j) = 0<=i && i<8 && 0<=j && j<8

canPut :: Coord->Color->Board->[Coord]
canPut dest@(x,y) color board = if board!toI dest/=Nothing then [] else concat$ do
    (vi,vj)<-around
    let tak = span f$ tail$ iterate (\(i,j)->(i+vi,j+vj)) (x,y)
    let other = head (snd tak)
    return$ if onBoard other && (board!toI other)==Just color then fst tak else []
  where enemy = inv color
        f c = onBoard c && board!toI c == Just enemy

getMoves :: Othello->[Move]
getMoves o@(Othello board _ _) = if null ret then [Pass] else ret
    where color = turnColor o
          ret = do
                  x<-[0..7]
                  y<-[0..7]
                  let canput = canPut (x,y) color board
                  if canput==[] then [] else [Move (x,y) canput]

turnColor :: Othello->Color
turnColor (Othello _ ply _) = if rem ply 2==0 then Black else White

doMove :: Move->Othello->Othello
doMove Pass (Othello board p c) = Othello board (p+1) c
doMove (Move put@(x,y) changes) o@(Othello board p (cb,cw)) = (Othello newboard (p+1) newc)
  where color=turnColor o
        newboard = board // zip (map toI (put:changes)) (repeat$ Just color)
        len = length changes;
        newc = if color==Black
                 then (cb+len+1, cw-len)
                 else (cb-len, cw+len+1)

evaluate :: Othello->Int
evaluate o@(Othello _ _ (cb,cw)) = (if gameEnd o then 100 else 1)*(cb-cw)

gameEnd :: Othello->Bool
gameEnd (Othello _ _ (cb,cw)) = cb+cw==64

type Eval = Int
data BestMove = BestMove Move Eval Int deriving(Show)

minimax :: Int->Othello->BestMove
minimax 0 game = BestMove Pass (evaluate game) 1
minimax depth game = foldr (f op) (BestMove Pass initEval 0) bms
    where (op, initEval) = if turnColor game==Black then ((>=), minBound) else ((<=), maxBound)
          bms = do
                  move<-getMoves game
                  let next = doMove move game
                  let (BestMove bmove beval bquant) = minimax (depth-1) next
                  return$ BestMove move beval bquant
          f op (BestMove mv1 ev1 q1) (BestMove mv2 ev2 q2) = if ev1 `op` ev2 
                                                               then BestMove mv1 ev1 (q1+q2)
                                                               else BestMove mv2 ev2 (q1+q2)

alphabeta :: Int->Maybe BestMove->Othello->BestMove
alphabeta 0 _ game = BestMove Pass (evaluate game) 1
alphabeta depth last game = either id id$ foldl (flip f) (Right (BestMove Pass initEval 0)) moves
    where (op, initEval) = if turnColor game==Black then ((>=), minBound) else ((<=), maxBound)
          moves = getMoves game
          f :: Move->Either BestMove BestMove->Either BestMove BestMove
          f _ l@(Left b) = l
          f move (Right ret) = if cut then Left betterOne else Right betterOne 
            where next = doMove move game
                  best@(BestMove bmove beval bquant) = alphabeta (depth-1) (Just ret) next
                  newbest = BestMove move beval bquant
                  betterOne = better newbest ret
                  cut = maybe False (\l->better newbest l`sameEval` newbest) last
                  sameEval (BestMove _ e1 _) (BestMove _ e2 _) = e1==e2
          better (BestMove mv1 ev1 q1) (BestMove mv2 ev2 q2) = if ev1 `op` ev2 
                                                                 then BestMove mv1 ev1 (q1+q2)
                                                                 else BestMove mv2 ev2 (q1+q2)

main = print$ alphabeta 9 Nothing initialOthello
