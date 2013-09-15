package main
import fmt "fmt"

const(
	Black = 0
	White = 1
	BLANK = 2
)

func getAround()[8][2]int8{
	return [8][2]int8{{1,1},{1,0},{1,-1},{0,1},{0,-1},{-1,1},{-1,0},{-1,-1}} 
}
func main(){
	fmt.Println("Hello, World!", getAround())
	o := Othello{}
	o.initialize()
	/*
	m := o.getMoves()[0]
	o.doMove(m)
	fmt.Println(o.toString())
*//*
	fmt.Println(alphabeta(&o, 10, false, nil))
	*/
	var depth=7
	for i:=0; i<70; i++{
		best:=alphabeta(&o, depth, false, nil)
		o.doMove(best.bestmove)
		fmt.Println(best)
		fmt.Println(o.toString())
		if o.gameEnd() {break}
	}
}


type Othello struct{
	board [8][8]int8
	ply int
	counts [2]int
}

func (this *Othello) initialize(){
	for i:=0; i<8; i++{
		for j:=0; j<8; j++{
			this.board[i][j]=BLANK
		}
	}
	this.board[3][4] = Black; this.board[4][3] = Black
	this.board[3][3] = White; this.board[4][4] = White
	this.ply=0
	this.counts=[2]int{2,2}
}

func onBoard(i int8, j int8)bool{
	return 0 <= i && i < 8 && 0 <= j && j < 8
}

func (this *Othello) canPut(i int8, j int8, c int8) [][]int8{
	if this.board[i][j]!=BLANK {return [][]int8{}};
	ret := make([][]int8, 0)
	for _, xy := range getAround(){
		nowx := i+xy[0]
		nowy := j+xy[1]
		rets := [][]int8{}
		if !onBoard(nowx, nowy)||this.board[nowx][nowy]==BLANK||this.board[nowx][nowy]==c {continue}
		rets=append(rets, []int8{nowx, nowy})
		for true{
			nowx+=xy[0]
			nowy+=xy[1]
			if !onBoard(nowx, nowy) || this.board[nowx][nowy]==BLANK{break}
			if this.board[nowx][nowy]==c{
				ret=append(ret, rets...)
				break;
			}else{
				rets=append(rets, []int8{nowx, nowy})
			}
		}
	}
	return ret
}
func (this *Othello) positiveTurn() bool{
	return this.ply%2==0
}
func (this *Othello) getTurnColor() int8{
	if this.positiveTurn(){return Black}
	return White
}
func (this *Othello) getMoves() []Move{
	ret := []Move{}
	color := this.getTurnColor()
	var i, j int8
	for i=0; i<8; i++{
		for j=0; j<8; j++{
			xys := this.canPut(i, j, color)
			if len(xys)>0{
				ret=append(ret, Move{to:[]int8{i, j}, change: xys})
			}
		}
	}
	if len(ret)==0{
		ret=append(ret, Move{change:[][]int8{}})
	}
	return ret
}
func (this *Othello) doMove(move Move){
	if move.to!=nil{
		color := this.getTurnColor()
		this.board[move.to[0]][move.to[1]]=color
		for _, xy := range move.change{
			this.board[xy[0]][xy[1]]=color
		}
		this.counts[color]+=len(move.change)+1
		this.counts[1-color]-=len(move.change)
	}
	this.ply++
}
func (this *Othello) undoMove(move Move){
	if move.to!=nil{
		color := this.getTurnColor()
		this.board[move.to[0]][move.to[1]]=BLANK
		for _, xy := range move.change{
			this.board[xy[0]][xy[1]]=color
		}
		this.counts[1-color]-=len(move.change)+1
		this.counts[color]+=len(move.change)
	}
	this.ply--
}
func (this *Othello) toString() string{
	ret := ""
	for i:=0; i<8; i++{
		for j:=0; j<8; j++{
			switch this.board[i][j]{
				case Black: ret+="o"
				case White: ret+="x"
				default: ret+="."
			}
		}
		ret+="\n"
	}
	return ret
}
func (this *Othello) gameEnd() bool{ return this.counts[0]+this.counts[1]==64}
func (this *Othello) evaluate() int{
	if this.gameEnd() {return 100*(this.counts[0]-this.counts[1])}
	return this.counts[0]-this.counts[1]
}
