<?php
define("Inf",100000);
interface Searchable{
	function getMoves();
	function doMove($move);
	function undoMove($move);
	function evaluate();
	function positiveTurn();
}
function minimax(Searchable $game, $depth, $verbose=false){
	if($depth==0) return array("eval"=>$game->evaluate(), "quant"=>1);
	if($game->positiveTurn()){
		$ret=array("eval"=>-Inf, "quant"=>0);
		$func=function($r1, $r2){return $r1["eval"]>=$r2["eval"]?$r1:$r2;};
	}else{
		$ret=array("eval"=>Inf, "quant"=>0);
		$func=function($r1, $r2){return $r1["eval"]<=$r2["eval"]?$r1:$r2;};
	}
	foreach($game->getMoves() as $move){
		$game->doMove($move);
		if($verbose) {echo "do", $move["to"][0], $move["to"][1], "\n";}
		$best = minimax($game, $depth-1, $verbose);
		if($verbose) {echo "eval"; print_r($best["eval"]);}
		$best["bestmove"] = $move;
		$newquant=$best["quant"]+$ret["quant"];
		$ret=$func($ret, $best);
		$ret["quant"]=$newquant;
		$game->undoMove($move);
		if($verbose) {echo "undo", $move["to"][0], $move["to"][1], "\n";}
	}
	return $ret;
}
function alphabeta(Searchable $game, $depth, $verbose=false, $last=null){
	if($depth==0) return array("eval"=>$game->evaluate(), "quant"=>1);
	if($game->positiveTurn()){
		$ret=array("eval"=>-Inf, "quant"=>0);
		$func=function($r1, $r2){return $r1["eval"]>=$r2["eval"]?$r1:$r2;};
	}else{
		$ret=array("eval"=>Inf, "quant"=>0);
		$func=function($r1, $r2){return $r1["eval"]<=$r2["eval"]?$r1:$r2;};
	}
	foreach($game->getMoves() as $move){
		$game->doMove($move);
		if($verbose) {echo "do", $move["to"][0], $move["to"][1], "\n";}
		$best = alphabeta($game, $depth-1, $verbose, $ret["quant"]!==0?$ret:null);
		if($verbose) {echo "eval"; print_r($best["eval"]);}
		if($last!==null){
			$a=$func($best, $last);
			if($a["eval"]===$best["eval"]){
				if($verbose) {echo "cut! undo", $move["to"][0], $move["to"][1], "\n";}
				$game->undoMove($move);
				return $best;
			}
		}
		$best["bestmove"] = $move;
		$newquant=$best["quant"]+$ret["quant"];
		$ret=$func($ret, $best);
		$ret["quant"]=$newquant;
		$game->undoMove($move);
		if($verbose) {echo "undo", $move["to"][0], $move["to"][1], "\n";}
	}
	return $ret;
}
