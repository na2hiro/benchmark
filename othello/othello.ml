open List

let rec iterateWhile f x c = if c x then x::iterateWhile f (f x) c else []

let rec span f =
    function
        x::xs when f x -> 
            let ys,zs =
                span f xs in
            x::ys,zs
    | xs -> 
            [],xs
let id x = x
type ('a, 'b) either = Left of 'a | Right of 'b
type 'a option = None | Some of 'a
let opt n f mb = match mb with
| None -> n
| Some x->f x
let eith f g ei = match ei with
| Left x -> f x
| Right y -> g y

type color = Black | White
type piece = color option

type coord = int * int
type count = int * int
type othello = {
    mutable board: piece array array;
    mutable ply: int;
    mutable count: count;
}
type move = Move of coord * coord list | Pass

let showColor = function
    | Black->"o"
    | White->"x"

let initialBoard = let board = Array.make_matrix 8 8 None in
    board.(3).(4) <- Some Black;
    board.(4).(3) <- Some Black;
    board.(3).(3) <- Some White;
    board.(4).(4) <- Some White;
    board

let initialOthello = {board=initialBoard; ply=0; count=(2,2)}

let showBoard board =
    let g x = match x with
    | None->"."
    | Some x->showColor x in
    let f line = String.concat "" (Array.to_list (Array.map g line)) in
    String.concat "\n" (Array.to_list (Array.map f board))
let showCounts (x, y) = "("^string_of_int x^","^string_of_int y^")"
let showCoord (x, y) = "("^string_of_int x^","^string_of_int y^")"
let showOthello o =
    String.concat "\n"[showBoard o.board; string_of_int o.ply; showCounts o.count;""]

let showMove = function
    | Pass -> "pass"
    | Move (c, _) -> showCoord c

let around = [(1,1);(1,0);(1,-1);(0,1);(0,-1);(-1,1);(-1,0);(-1,-1)]
let onBoard (i,j) = 0<=i && i<8 && 0<=j && j<8
let inv = function
    | Black->White
    | White->Black

let turnColor o = if o.ply mod 2 == 0 then Black else White

let get board (x,y) = board.(x).(y)
let set board (x,y) p = board.(x).(y)<-p

let canPut ((x,y) as dest) color board = if (get board dest)!=None then [] else
    let ff (vi,vj) = 
        let enemy = inv color in
        let f c = onBoard c && get board c = Some enemy in
        let tak = span f (tl (iterateWhile (fun (i,j)->(i+vi, j+vj)) (x,y)onBoard))in
        let others = snd tak in
        if length others!=0 && (get board (hd others))=Some color then fst tak else [] in
    concat(map ff around)

let getMoves o =
    let range = [0;1;2;3;4;5;6;7] in
    let color = turnColor o in
    let f(x,y) =
        let canput=canPut(x,y)color o.board in
        if canput==[] then [] else [Move ((x,y), canput)] in
    let ret = concat (map (fun x->concat (map (fun y->f(x,y)) range)) range) in
    if length ret==0 then [Pass] else ret

let doMove move o = match move with
| Pass -> o.ply<-o.ply+1
| Move (put, changes) ->
        let color = turnColor o in
        let len = length changes in
        map (fun change->set o.board change (Some color)) (put::changes);
        let (cb,cw)=o.count in
        let newc = if color==Black 
            then (cb+len+1, cw-len) 
            else (cb-len, cw+len+1) in
        o.ply<-o.ply+1;
        o.count<-newc
let undoMove move o = match move with
| Pass -> o.ply<-o.ply-1
| Move (put, changes) ->
        let color = turnColor o in
        let len = length changes in
        set o.board put None;
        map (fun change->set o.board change (Some color)) changes;
        let (cb,cw)=o.count in
        let newc = if color==Black 
            then (cb+len, cw-len-1) 
            else (cb-len-1, cw+len) in
        o.ply<-o.ply-1;
        o.count<-newc
        

let gameEnd o = let (cb,cw)=o.count in cb+cw==64
let evaluate o = let (cb,cw)=o.count in
    (if gameEnd o then 100 else 1)*(cb-cw)

type eval = int
type bestmove = BestMove of move * eval * int
let showBestMove (BestMove (move, eval, quant)) = showMove move^","^string_of_int
eval^","^string_of_int quant

let printO othello = Printf.printf "%s\n" (showOthello othello)
let printM move = Printf.printf "%s\n" (showMove move)
let printBM bm = Printf.printf "%s\n" (showBestMove bm)

let rec minimax n game = match n with
| 0 -> BestMove (Pass, (evaluate game), 1)
| depth ->
        let f op (BestMove (mv1, ev1, q1)) (BestMove (mv2, ev2, q2)) =
            if op ev1 ev2 then BestMove (mv1, ev1, q1+q2) else BestMove (mv2, ev2,
            q1+q2) in
        let (op, initEval) = if turnColor game==Black
            then ((>=), -999999) else ((<=), 999999) in
        let g move =
            doMove move game;
            let BestMove(bmove, beval, bquant) = minimax (depth-1) game in
            undoMove move game;
            BestMove(move, beval, bquant) in
        let bms = map g (getMoves game) in 
        fold_right (f op) bms (BestMove (Pass, initEval, 0))

let rec alphabeta n last game = match n with
| 0 -> BestMove (Pass, (evaluate game), 1)
| depth ->
        let (op, initEval) = if turnColor game==Black
            then ((>=), -999999) else ((<=), 999999) in
        let better (BestMove(mv1, ev1, q1)) (BestMove (mv2,ev2,q2)) = if op ev1 ev2
            then BestMove(mv1, ev1, q1+q2) else BestMove(mv2, ev2, q1+q2) in
        let f bes move = match bes with
        | (Left _) as l -> l
        | (Right ret) ->
                doMove move game;
                let (BestMove (bmove, beval, bquant)) = alphabeta (depth-1)
                (Some ret) game in
                undoMove move game;
                let newbest = BestMove (move, beval, bquant) in
                let betterOne = better newbest ret in
                let sameEval (BestMove (_,e1,_))(BestMove (_,e2,_))=e1==e2 in
                let cut = opt false (fun l->sameEval (better newbest l) newbest)
                last in
                if cut then Left betterOne else Right betterOne in
        eith id id (fold_left f (Right (BestMove (Pass, initEval, 0))) (getMoves
        game))


let _ = printBM (alphabeta 10 None initialOthello)

