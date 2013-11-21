//package Search
package main
import fmt "fmt"

const(INF=32000)

type Searchable interface{
	getMoves() []Move
	doMove(m Move)
	undoMove(m Move)
	evaluate() int16
	positiveTurn() bool
}

type Move struct{
	to *Coord
	change []Coord
}

type BestMove struct{
	bestmove Move
	eval int16
	quant uint32
}

func minimax(game Searchable, depth uint8, verbose bool) *BestMove{
	if depth==0{
		return &BestMove{eval: game.evaluate(), quant:1}
	}
	var ret *BestMove
	var fun func(r1 *BestMove, r2 *BestMove) *BestMove
	if game.positiveTurn(){
		ret=&BestMove{eval:-INF, quant:0}
		fun = func(r1 *BestMove, r2 *BestMove)*BestMove{if r1.eval>=r2.eval{return r1}else{return r2}}
	}else{
		ret=&BestMove{eval:INF, quant:0}
		fun = func(r1 *BestMove, r2 *BestMove)*BestMove{if r1.eval<=r2.eval{return r1}else{return r2}}
	}
	for _, move := range game.getMoves(){
		game.doMove(move)
		if verbose{fmt.Println("do", move.to)}
		best := minimax(game, depth-1, verbose)
		if verbose{fmt.Println("eval", best.eval)}
		best.bestmove=move
		newquant := best.quant+ret.quant
		ret=fun(ret, best)
		ret.quant=newquant
		game.undoMove(move)
		if verbose {fmt.Println("undo", move.to)}
	}
	return ret
}
func f1(r1 *BestMove, r2 *BestMove)bool{return r1.eval>=r2.eval}
func f2(r1 *BestMove, r2 *BestMove)bool{return r1.eval<=r2.eval}
func alphabeta(game Searchable, depth uint8, verbose bool, last *BestMove) *BestMove{
	if depth==0{
		return &BestMove{eval: game.evaluate(), quant:1}
	}
	var ret *BestMove
	if game.positiveTurn(){
		ret=&BestMove{eval:-INF, quant:0}
		for _, move := range game.getMoves(){
			game.doMove(move)
			if verbose{fmt.Println("do", move.to)}
			var newlast *BestMove
			if ret.quant!=0 {newlast=ret}
			best := alphabeta(game, depth-1, verbose, newlast)
			if verbose{fmt.Println("eval", best.eval)}
			if last!=nil && f1(best, last){
				if verbose{fmt.Println("cut! undo", move.to)}
				best.quant += ret.quant
				game.undoMove(move)
				return best
			}
			best.bestmove=move
			newquant := best.quant+ret.quant
			if !f1(ret, best){ret=best}
			ret.quant=newquant
			game.undoMove(move)
			if verbose {fmt.Println("undo", move.to)}
		}
	}else{
		ret=&BestMove{eval:INF, quant:0}
		for _, move := range game.getMoves(){
			game.doMove(move)
			if verbose{fmt.Println("do", move.to)}
			var newlast *BestMove
			if ret.quant!=0 {newlast=ret}
			best := alphabeta(game, depth-1, verbose, newlast)
			if verbose{fmt.Println("eval", best.eval)}
			if last!=nil && f2(best, last){
				if verbose{fmt.Println("cut! undo", move.to)}
				best.quant += ret.quant
				game.undoMove(move)
				return best
			}
			best.bestmove=move
			newquant := best.quant+ret.quant
			if !f2(ret, best){ret=best}
			ret.quant=newquant
			game.undoMove(move)
			if verbose {fmt.Println("undo", move.to)}
		}
	}
	return ret
}
