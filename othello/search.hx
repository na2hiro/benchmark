class Search{
	public static function minimax(game: Searchable, depth: Int, verbose: Bool): BestMove{
		if(depth==0) return {bestmove: null, eval: game.evaluate(), quant: 1};
		var ret: BestMove, func: BestMove->BestMove->BestMove;
		if(game.positiveTurn()){
			ret={bestmove: null, eval: -30000, quant: 0};
			func=function(r1: BestMove, r2: BestMove){return r1.eval>=r2.eval?r1:r2;}
		}else{
			ret={bestmove: null, eval: 30000, quant: 0};
			func=function(r1: BestMove, r2: BestMove){return r1.eval<=r2.eval?r1:r2;}
		}
		var moves=game.getMoves();
		for(i in 0...moves.length){
			var move=moves[i];
			game.doMove(move);
			if(verbose) trace("do", move.to);
			var best = minimax(game, depth-1, verbose);
			if(verbose) trace("eval", best.eval);
			best.bestmove = move;
			var newquant=best.quant+ret.quant;
			ret=func(ret, best);
			ret.quant=newquant;
			game.undoMove(move);
			if(verbose) trace("undo", move.to);
		}
		return ret;
	}
	public static function alphabeta(game: Searchable, depth: Int, verbose: Bool, last: BestMove): BestMove{
		if(depth==0) return {bestmove: null, eval: game.evaluate(), quant: 1};
		var ret: BestMove, func: BestMove->BestMove->BestMove;
		if(game.positiveTurn()){
			ret={bestmove: null, eval: -30000, quant: 0};
			func=function(r1: BestMove, r2: BestMove){return r1.eval>=r2.eval?r1:r2;}
		}else{
			ret={bestmove: null, eval: 30000, quant: 0};
			func=function(r1: BestMove, r2: BestMove){return r1.eval<=r2.eval?r1:r2;}
		}
		var moves=game.getMoves();
		for(i in 0...moves.length){
			var move=moves[i];
			game.doMove(move);
			if(verbose) trace("do", move.to);
			var best = alphabeta(game, depth-1, verbose, ret.quant!=0?ret:null);
			if(verbose) trace("eval", best.eval);
			if(last!=null && func(best, last).eval==best.eval){
				game.undoMove(move);
				if(verbose) trace("cut! undo", move.to);
				return best;
			}
			best.bestmove = move;
			var newquant=best.quant+ret.quant;
			ret=func(ret, best);
			ret.quant=newquant;
			game.undoMove(move);
			if(verbose) trace("undo", move.to);
		}
		return ret;
	}
}
