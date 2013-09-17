package main
import fmt "fmt"

const(
	Black = 0
	White = 1
	BLANK = 2
)

func getAround()[8]Coord{
	return [8]Coord{{1,1},{1,0},{1,-1},{0,1},{0,-1},{-1,1},{-1,0},{-1,-1}} 
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
	for i:=0; i<70; i++{
		best:=alphabeta(&o, 7, false, nil)
		o.doMove(best.bestmove)
		fmt.Println(best)
		fmt.Println(o.toString())
		if o.gameEnd() {break}
	}
}

type Coord struct{
	x int8
	y int8
}
type Othello struct{
	board [8][8]int8
	ply int
	counts [2]int16
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
	this.counts=[2]int16{2,2}
}

func onBoard(i int8, j int8)bool{
	return 0 <= i && i < 8 && 0 <= j && j < 8
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
	c := this.getTurnColor()
	var i, j int8
	for i=0; i<8; i++{
		for j=0; j<8; j++{
			if this.board[i][j]!=BLANK {continue}
			rett := make([]Coord, 0)
			for _, xy := range getAround(){
				nowx := i+xy.x
				nowy := j+xy.y
				rets := []Coord{}
				if !onBoard(nowx, nowy)||this.board[nowx][nowy]!=1-c {continue}
				rets=append(rets, Coord{nowx, nowy})
				for true{
					nowx+=xy.x
					nowy+=xy.y
					if !onBoard(nowx, nowy) || this.board[nowx][nowy]==BLANK{break}
					if this.board[nowx][nowy]==c{
						rett=append(rett, rets...)
						break;
					}else{
						rets=append(rets, Coord{nowx, nowy})
					}
				}
			}
			if len(rett)>0{
				ret=append(ret, Move{to:&Coord{i, j}, change: rett})
			}
		}
	}
	if len(ret)==0{
		ret=append(ret, Move{change:[]Coord{}})
	}
	return ret
}
func (this *Othello) doMove(move Move){
	if move.to!=nil{
		color := this.getTurnColor()
		this.board[move.to.x][move.to.y]=color
		for _, xy := range move.change{
			this.board[xy.x][xy.y]=color
		}
		this.counts[color]+=int16(len(move.change))+1
		this.counts[1-color]-=int16(len(move.change))
	}
	this.ply++
}
func (this *Othello) undoMove(move Move){
	if move.to!=nil{
		color := this.getTurnColor()
		this.board[move.to.x][move.to.y]=BLANK
		for _, xy := range move.change{
			this.board[xy.x][xy.y]=color
		}
		this.counts[1-color]-=int16(len(move.change))+1
		this.counts[color]+=int16(len(move.change))
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
func (this *Othello) evaluate() int16{
	if this.gameEnd() {return 100*(this.counts[0]-this.counts[1])}
	return this.counts[0]-this.counts[1]
}
