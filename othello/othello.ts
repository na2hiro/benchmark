/// <reference path="../search.ts" />
import Search = require("../search");

enum Color { Black=0, White=1 }
class Othello implements Search.Searchable {
	private board: Color[][];
	private around = [1,0,-1].map(x=>[1,0,-1].map(y=>[x,y])).reduce((prev, cur)=>prev.concat(cur), []).filter(xy=>xy[0]!=0||xy[1]!=0);
	private ply: number;
	private counts: number[];
	
	initialize() {
		this.board = [];
		for (var i = 0; i < 8; i++) {
			var arr = [];
			for (var j = 0; j < 8; j++) {
				arr.push(null);
			}
			this.board.push(arr);
		}
		this.board[3][4] = this.board[4][3] = Color.Black;
		this.board[3][3] = this.board[4][4] = Color.White;
		this.ply=0;
		this.counts=[2,2];
	}
	canPut(i: number, j: number, c: Color): number[][]{
		if (this.board[i][j] != null) return [];
		var ret: number[][]=[];
		this.around.forEach(xy=> {
			var nowx = i + xy[0];
			var nowy = j + xy[1];
			var rets:number[][] = [];

			if (!this.onBoard(nowx, nowy) || this.board[nowx][nowy] != 1-c) return;
			// teki
			rets.push([nowx, nowy]);
			while(true) {
				nowx += xy[0];
				nowy += xy[1];
				if (!this.onBoard(nowx, nowy) || this.board[nowx][nowy] == null) {
					return;
				}
				if (this.board[nowx][nowy] == c) {
					//mikata
					ret = ret.concat(rets);
					return;
				} else {
					//teki keizoku
					rets.push([nowx, nowy]);
				}
			}
		});
		return ret;
	}
	onBoard(i: number, j: number) {
		return 0 <= i && i < 8 && 0 <= j && j < 8;
	}
	getMoves(): Search.Move[]{
		var ret: Search.Move[]=[];
		var color = this.getTurnColor();
		for (var i = 0; i < 8; i++) {
			for (var j = 0; j < 8; j++) {
				var xys = this.canPut(i, j, color);
				if(xys.length>0){
					ret.push({to: [i, j], change: xys});
				}
			}
		}
		if(ret.length==0)ret.push({to: null, change:[]});
		return ret;
	}
	doMove(move: Search.Move){
		if(move.to!=null){
			var color=this.getTurnColor();
			this.board[move.to[0]][move.to[1]]=color;
			move.change.forEach(xy=>this.board[xy[0]][xy[1]]=color);
			this.counts[color]+=move.change.length+1;
			this.counts[1-color]-=move.change.length;
		}
		this.ply++;
	}
	undoMove(move: Search.Move){
		if(move.to!=null){
			var color=this.getTurnColor();
			this.board[move.to[0]][move.to[1]]=null;
			move.change.forEach(xy=>this.board[xy[0]][xy[1]]=color);
			this.counts[1-color]-=move.change.length+1;
			this.counts[color]+=move.change.length;
		}
		this.ply--;
	}
	getTurnColor(): Color{
		return this.positiveTurn() ? Color.Black : Color.White;
	}
	positiveTurn(){
		return this.ply%2==0;
	}
	toString(): string{
		var ret = "";
		for(var i=0; i<8; i++){
			for(var j=0; j<8; j++){
				ret+=this.board[i][j]==Color.Black?"o":(this.board[i][j]==Color.White?"x":".");
			}
			ret+="\n";
		}
		return ret;
	}
	evaluate(): number{
		var c = this.counts;
		if(this.gameEnd()) return (c[0]-c[1])*100;
		return c[0]-c[1]
	/*		+(this.board[0][0]==Color.Black?6:(this.board[0][0]==Color.White?-6:0))
			+(this.board[0][7]==Color.Black?6:(this.board[0][7]==Color.White?-6:0))
			+(this.board[7][0]==Color.Black?6:(this.board[7][0]==Color.White?-6:0))
			+(this.board[7][7]==Color.Black?6:(this.board[7][7]==Color.White?-6:0));
	*/}
	gameEnd(){
		return this.counts[0]+this.counts[1]==64;
	}
}

var o = new Othello();
o.initialize();
/*console.log(o.canPut(2,2, Color.Black));
console.log(o.canPut(2,3, Color.Black));
console.log(o.canPut(2,4, Color.Black));
var moves = o.getMoves();
console.log(o.toString(), o.count(), o.evaluate());
o.doMove(moves[0]);
console.log(o.toString(), o.count(), o.evaluate());
o.undoMove(moves[0]);
console.log(o.toString());
*/
//o.doMove(o.getMoves()[0]);
console.log(o.toString());

for(var i=10; i<=10; i++){
	var depth = i;
	console.log("********** depth = "+i+" **********");
//	console.time("minimax");
//	console.log(Search.minimax(o, depth, false));
//	console.timeEnd("minimax");
	console.time("alphabeta");
	console.log(Search.alphabeta(o, depth, false));
	console.timeEnd("alphabeta");
}/*/
var depth=7;
for(var i=0; i<70; i++){
	var best=Search.alphabeta(o, depth, false);
	o.doMove(best.bestmove);
	console.log(best);
	console.log(o.toString());
	if(o.gameEnd())break;
}*/
