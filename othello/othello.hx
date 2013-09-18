enum Color{
	Black;
	White;
}
class Coord{
	public var x: Int;
	public var y: Int;
	public function new(x: Int, y: Int){
		this.x=x;
		this.y=y;
	}
	public function toString(){
		return "("+this.x+","+this.y+")";
	}
}
class Othello implements Searchable{
	private var board: Array<Array<Color>>;
	private static var around = [[1,1],[1,0],[1,-1],[0,1],[0,-1],[-1,1],[-1,0],[-1,-1]];
	private var ply: Int;
	private var counts: Array<Int>;

	public function new(){}
	function initialize(): Void{
		this.board=[];
		for(i in 0...8){
			var arr=[];
			for(j in 0...8){
				arr.push(null);
			}
			this.board.push(arr);
		}
		this.board[3][4]=board[4][3]=Color.Black;
		this.board[3][3]=board[4][4]=Color.White;
		this.ply=0;
		this.counts=[2,2];
	}
	function canPut(i: Int, j: Int, c: Color): Array<Coord>{
		if(this.board[i][j]!=null) return [];
		var ret: Array<Coord>=[];
		for(x in 0...around.length){
			var xy = around[x];
			var nowx=i+xy[0];
			var nowy=j+xy[1];
			var rets: Array<Coord>=[];

			if(!this.onBoard(nowx, nowy) || this.board[nowx][nowy]==null || this.board[nowx][nowy]==c) continue;
			
			rets.push(new Coord(nowx,nowy));
			while(true){
				nowx+=xy[0];
				nowy+=xy[1];
				if(!this.onBoard(nowx, nowy) || this.board[nowx][nowy]==null){
					break;
				}
				if(this.board[nowx][nowy]==c){
					ret=ret.concat(rets);
					break;
				}else{
					rets.push(new Coord(nowx, nowy));
				}
			}
		}
		return ret;
	}
	function onBoard(i: Int, j: Int){
		return 0 <= i && i < 8 && 0 <= j && j < 8;
	}
	public function getMoves(): Array<Move>{
		var ret: Array<Move> = [];
		var color = this.getTurnColor();
		for(i in 0...8){
			for(j in 0...8){
				var xys = this.canPut(i, j, color);
				if(xys.length>0){
					ret.push({to: new Coord(i, j), change: xys});
				}
			}
		}
		if(ret.length==0)ret.push({to:null, change:[]});
		return ret;
	}
	function addCount(c: Color, n1: Int, n2: Int){
		switch(c){
			case Black:
				this.counts[0] = n1;
				this.counts[1] = n2;
			case White:
				this.counts[1] = n1;
				this.counts[0] = n2;
		}
	}
	public function doMove(move: Move): Void{
		if(move.to!=null){
			var color = this.getTurnColor();
			this.board[move.to.x][move.to.y]=color;
			for(i in 0...move.change.length){
				var xy=move.change[i];
				this.board[xy.x][xy.y]=color;
			}
			this.addCount(color, move.change.length+1, -move.change.length);
		}
		this.ply++;
	}
	public function undoMove(move: Move){
		if(move.to!=null){
			var color = this.getTurnColor();
			this.board[move.to.x][move.to.y]=null;
			for(i in 0...move.change.length){
				var xy=move.change[i];
				this.board[xy.x][xy.y]=color;
			}
			this.addCount(color, move.change.length, -move.change.length+1);
		}
		this.ply--;
	}
	function getTurnColor(): Color{
		return this.positiveTurn() ? Color.Black: Color.White;
	}
	public function positiveTurn(){
		return this.ply%2==0;
	}
	function toString(): String{
		var ret="";
		for(i in 0...8){
			for(j in 0...8){
				ret+=this.board[i][j]==Color.Black?"o":(this.board[i][j]==Color.White?"x":".");
			}
			ret+="\n";
		}
		return ret;
	}
	public function evaluate(): Int{
		return (this.gameEnd()?100:1)*(this.counts[0]-this.counts[1]);
	}
	function gameEnd(): Bool{
		return this.counts[0]+this.counts[1]==64;
	}

	static function showMoves(moves: Array<Move>){
		for(i in 0...moves.length){
			trace(moves[i].to.toString()+": ");
			for(j in 0...moves[i].change.length){
				trace(moves[i].change[j].toString());
			}
			trace("\n");
		}
	}
	static function main(){
		var o = new Othello();
		o.initialize();
		/*
		trace(o.toString());
		var moves = o.getMoves();
		trace(moves);
		o.doMove(moves[0]);
		trace(o.toString());
		o.undoMove(moves[0]);
		trace(o.toString());
		*/
		trace(Search.alphabeta(o, 10, false, null));
	}
}

extern typedef Move = {
	to: Coord,
	change: Array<Coord>
}
interface Searchable{
	function getMoves(): Array<Move>;
	function doMove(move: Move): Void;
	function undoMove(move: Move): Void;
	function evaluate(): Int;
	function positiveTurn(): Bool;
}

typedef BestMove = {
	bestmove: Move,
	eval: Int,
	quant: Int
}

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
