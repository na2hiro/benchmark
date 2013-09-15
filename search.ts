export interface Searchable {
	getMoves(): Move[];
	doMove(Move);
	undoMove(Move);
	evaluate(): number;
	positiveTurn(): boolean;
}

export interface Move {
	to: number[];
	change: number[][];
}
export interface BestMove{
	bestmove: Move;
	eval: number;
}

export function minimax(game: Searchable, depth: number): BestMove{
	if(depth==0) return {bestmove: null, eval: game.evaluate()};
	var ret: BestMove, func:(r1:BestMove, r2:BestMove)=>BestMove;
	if(game.positiveTurn()){
		ret={bestmove: null, eval:-Infinity};
		func=function(r1, r2){return r1.eval>=r2.eval?r1:r2};
	}else{
		ret={bestmove: null, eval: Infinity};
		func=function(r1, r2){return r1.eval<=r2.eval?r1:r2};
	}

	game.getMoves().forEach(move=>{
			game.doMove(move);
			var best=minimax(game, depth-1);
			best.bestmove=move;
			ret=func(ret, best);
			game.undoMove(move);
			});
	//	console.log("eval", eval);
	return ret;
}
export function alphabeta(game: Searchable, depth: number){

}

