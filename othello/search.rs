pub trait Searchable<M> {
    fn get_moves(&self) -> Vec<M>;
    fn do_move(&mut self, mv: &M);
    fn undo_move(&mut self, mv: &M);
    fn evaluate(&self) -> i16;
    fn positive_turn(&self) -> bool;
}

#[derive(Debug, Clone)]
pub struct BestMove<M> {
    pub best_move: Option<M>,
    pub eval: i16,
    pub quantity: u32,
}

const INF: i16 = 32000;

pub fn minimax<M>(game: &mut Searchable<M>, depth: u8) -> BestMove<M> {
    if depth == 0 {
        return BestMove { best_move: None, eval: game.evaluate(), quantity: 1 }
    }
    let positive_turn = game.positive_turn();
    let mut best = BestMove {
        best_move: None,
        eval: if positive_turn { -INF } else { INF },
        quantity: 0
    };
    for mv in game.get_moves() {
        game.do_move(&mv);
        let mut sub_best = minimax(game, depth - 1);
        game.undo_move(&mv);

        sub_best.best_move = Some(mv);
        let new_quantity = best.quantity + sub_best.quantity;
        best = better(best, sub_best, positive_turn);
        best.quantity = new_quantity;
    }
    best
}

fn better<M>(best1: BestMove<M>, best2: BestMove<M>, positive_turn: bool) -> BestMove<M> {
    if is_better(&best1, &best2, positive_turn) { best1 } else { best2 }
}

fn is_better<M>(best: &BestMove<M>, another: &BestMove<M>, positive_turn: bool) -> bool {
    positive_turn == (best.eval >= another.eval)
}

pub fn alphabeta<M>(game: &mut Searchable<M>, depth: u8) -> BestMove<M> {
    alphabeta_inner(game, depth, &None)
}

fn alphabeta_inner<M>(game: &mut Searchable<M>, depth: u8, opt_last: &Option<&BestMove<M>>) -> BestMove<M> {
    if depth == 0 {
        return BestMove { best_move: None, eval: game.evaluate(), quantity: 1 }
    }
    let positive_turn = game.positive_turn();
    let mut best = BestMove {
        best_move: None,
        eval: if positive_turn { -INF } else { INF },
        quantity: 0
    };
    for mv in game.get_moves() {
        game.do_move(&mv);
        let mut sub_best = {
            let new_last = if best.quantity == 0 { None } else { Some(&best) };
            alphabeta_inner(game, depth - 1, &new_last)
        };
        game.undo_move(&mv);

        if let &Some(ref last) = opt_last {
            if is_better(&sub_best, &last, positive_turn) {
                sub_best.quantity += best.quantity;
                return sub_best;
            }
        }
        sub_best.best_move = Some(mv);
        let new_quantity = best.quantity + sub_best.quantity;
        best = better(best, sub_best, positive_turn);
        best.quantity = new_quantity;
    }
    best
}
