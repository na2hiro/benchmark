<?php
require_once("../search.php");
class Color{
	static $Black=0;
	static $White=1;
}

class Othello implements Searchable{
	private $board;
	private $around = array(array(1,1),array(1,0),array(1,-1),array(0,1),array(0,-1),array(-1,1),array(-1,0),array(-1,-1),);
	private $ply;
	private $counts;

	function initialize(){
		$this->board=array();
		for($i=0; $i<8; $i++){
			for($j=0; $j<8; $j++){
				$this->board[$i][]=null;
			}
		}
		$this->board[3][4] = $this->board[4][3] = Color::$Black;	
		$this->board[3][3] = $this->board[4][4] = Color::$White;	
		$this->ply = 0;
		$this->counts = array(2,2);
	}
	function canPut($i, $j, $c){
		if($this->board[$i][$j]!==null) return array();
		$ret=array();
		foreach($this->around as $xy){
			$nowx=$i+$xy[0];
			$nowy=$j+$xy[1];
			$rets=array();

			if(!$this->onBoard($nowx, $nowy) || $this->board[$nowx][$nowy]!==1-$c) continue;

			$rets[]=array($nowx, $nowy);
			while(true){
				$nowx+=$xy[0];
				$nowy+=$xy[1];
				if(!$this->onBoard($nowx, $nowy) || $this->board[$nowx][$nowy] === null) break;
				if($this->board[$nowx][$nowy]===$c){
					$ret=array_merge($ret, $rets);
					break;
				}else{
					$rets[]=array($nowx, $nowy);
				}
			}
		}
		return $ret;
	}
	function onBoard($i, $j){
		return 0<=$i && $i<8 && 0<=$j && $j<8;
	}
	function getMoves(){
		$ret=array();
		$color=$this->getTurnColor();
		for($i=0; $i<8; $i++){
			for($j=0; $j<8; $j++){
				$xys=$this->canPut($i, $j, $color);
				if(count($xys)>0) $ret[]=array("to"=>array($i, $j), "change"=>$xys);
			}
		}
		if(count($ret)==0) $ret[]=array("change"=>array());
		return $ret;
	}
	function doMove($move){
		if(isset($move["to"]) && $move["to"]!==null){
			$color=$this->getTurnColor();
			$this->board[$move["to"][0]][$move["to"][1]]=$color;
			foreach($move["change"] as $xy){
				$this->board[$xy[0]][$xy[1]]=$color;
			}
			$this->counts[$color]+=count($move["change"])+1;
			$this->counts[1-$color]-=count($move["change"]);
		}
		$this->ply++;
	}
	function undoMove($move){
		if(isset($move["to"]) && $move["to"]!==null){
			$color=$this->getTurnColor();
			$this->board[$move["to"][0]][$move["to"][1]]=null;
			foreach($move["change"] as $xy){
				$this->board[$xy[0]][$xy[1]]=$color;
			}
			$this->counts[1-$color]-=count($move["change"])+1;
			$this->counts[$color]+=count($move["change"]);
		}
		$this->ply--;
	}
	function getTurnColor(){
		return $this->positiveTurn() ? Color::$Black : Color::$White;
	}
	function positiveTurn(){
		return $this->ply%2==0;
	}
	function __toString(){
		$ret="";
		for($i=0; $i<8; $i++){
			for($j=0; $j<8; $j++){
				$ret.=$this->board[$i][$j]===Color::$Black?"o":($this->board[$i][$j]===Color::$White?"x":".");
			}
			$ret.="\n";
		}
		return $ret;
	}
	function evaluate(){
		return ($this->gameEnd()?100:1)*($this->counts[0]-$this->counts[1]);
	}
	function gameEnd(){
		return $this->counts[0]+$this->counts[1]==64;
	}
}
$o=new Othello();
$o->initialize();
/*$moves = $o->getMoves();
$o->doMove($moves[0]);
/*
echo $o;
$o->undoMove($moves[0]);
echo $o;
 */
print_r(alphabeta($o, 10, false));
