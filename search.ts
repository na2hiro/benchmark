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
	quant?: number;
}

export function minimax(game: Searchable, depth: number, verbose=false): BestMove{
	if(depth==0) return {bestmove: null, eval: game.evaluate(), quant:1};
	var ret: BestMove, func:(r1:BestMove, r2:BestMove)=>BestMove;
	if(game.positiveTurn()){
		ret={bestmove: null, eval:-Infinity, quant:0};
		func=function(r1, r2){return r1.eval>=r2.eval?r1:r2};
	}else{
		ret={bestmove: null, eval: Infinity, quant:0};
		func=function(r1, r2){return r1.eval<=r2.eval?r1:r2};
	}

	game.getMoves().forEach(move=>{
		game.doMove(move);
		if(verbose) console.log("do",move.to);
		var best=minimax(game, depth-1, verbose);
		if(verbose) console.log("eval",best.eval);
		best.bestmove=move;
		var newquant=best.quant+ret.quant;
		ret=func(ret, best);
		ret.quant=newquant;
		game.undoMove(move);
		if(verbose) console.log("undo",move.to);
		
	});
	//	console.log("eval", eval);
	return ret;
}
export function alphabeta(game: Searchable, depth: number, verbose=false, last: BestMove=null){
	if(depth==0) return {bestmove: null, eval: game.evaluate(), quant:1};
	var ret: BestMove, better:(r1:BestMove, r2:BestMove)=>BestMove;
	if(game.positiveTurn()){
		ret={bestmove: null, eval:-Infinity, quant:0};
		better=function(r1, r2){return r1.eval>=r2.eval?r1:r2};
	}else{
		ret={bestmove: null, eval: Infinity, quant:0};
		better=function(r1, r2){return r1.eval<=r2.eval?r1:r2};
	}
	var moves = game.getMoves();
	for(var i=0; i<moves.length; i++){
		var move = moves[i];
		if(verbose) console.log("do",move.to);
		game.doMove(move);
		var best=alphabeta(game, depth-1, verbose, ret.quant!=0?ret:null);
		if(verbose) console.log("eval",best.eval);
		if(last!=null && better(best, last).eval==best.eval){
			if(verbose)console.log("cut! undo", move.to);
			game.undoMove(move);
			return best;
		}
		best.bestmove=move;
		var newquant=best.quant+ret.quant;
		ret=better(ret, best);
		ret.quant=newquant;
		game.undoMove(move);
		if(verbose) console.log("undo",move.to);
	};
	//	console.log("eval", eval);
	return ret;

}

