mod search;

use std::fmt;

fn main() {
    let mut othello = Othello::new();
    let best = search::alphabeta(&mut othello, 10);
    println!("done {:?}", best);
}

const DEBUG: bool = false;

#[derive(Debug, Copy, Clone, PartialEq)]
enum Color {
    Black,
    White,
}

impl Color {
    fn opposite(&self) -> Color {
        match self {
            &Color::Black => Color::White,
            &Color::White => Color::Black,
        }
    }
}

type Cell = Option<Color>;

#[derive(Debug, Clone)]
struct Coord {
    x: i8,
    y: i8,
}

impl Coord {
    fn new(x: i8, y: i8) -> Coord {
        Coord { x, y }
    }
    fn add(&self, other: &Coord) -> Coord {
        Coord {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

const AROUND: [Coord; 8] = [
    Coord { x: 1, y: 1 },
    Coord { x: 1, y: 0 },
    Coord { x: 1, y: -1 },
    Coord { x: 0, y: 1 },
    Coord { x: 0, y: -1 },
    Coord { x: -1, y: 1 },
    Coord { x: -1, y: 0 },
    Coord { x: -1, y: -1 },
];

#[derive(Debug)]
struct Move {
    to: Coord,
    changes: Vec<Coord>,
}

struct Othello {
    board: [[Cell; 8]; 8],
    ply: u32,
    counts: [i8; 2],
}

impl Othello {
    fn new() -> Othello {
        let mut board = [[None; 8]; 8];
        board[3][4] = Some(Color::Black);
        board[4][3] = Some(Color::Black);
        board[3][3] = Some(Color::White);
        board[4][4] = Some(Color::White);
        Othello {
            board: board,
            ply: 0,
            counts: [2, 2]
        }
    }

    fn get(&self, coord: &Coord) -> Cell {
        self.board[coord.x as usize][coord.y as usize]
    }

    fn set(&mut self, coord: &Coord, cell: Cell) {
        self.board[coord.x as usize][coord.y as usize] = cell;
    }

    fn positive_turn(&self) -> bool {
        self.ply % 2 == 0
    }

    fn get_turn_color(&self) -> Color {
        if self.positive_turn() { Color::Black } else { Color::White }
    }

    fn add_count(&mut self, color: &Color, count: i8) {
        let index = if let &Color::Black = color { 0 } else { 1 };
        self.counts[index] += count;
    }

    fn get_moves(&self) -> Vec<Move> {
        let turn = self.get_turn_color();
        let mut ret = Vec::new();
        for (x, &row) in self.board.iter().enumerate() {
            for (y, &piece) in row.iter().enumerate() {
                if let Some(_) = piece { continue; }
                let coord = Coord::new(x as i8, y as i8);
                let turnables = self.get_turnables(&coord, turn);
                if turnables.len() > 0 {
                    ret.push(Move {
                        to: coord,
                        changes: turnables,
                    });
                }
            }
        }
        ret
    }

    fn get_turnables(&self, coord: &Coord, turn: Color) -> Vec<Coord> {
        let mut ret: Vec<Coord> = Vec::new();
        for vec in AROUND.iter() {
            let mut now = coord.add(vec);
            let mut temp = Vec::new();
            while Othello::on_board(&now) {
                match self.get(&now) {
                    None => break,
                    Some(color) if color == turn => {
                        ret.append(&mut temp);
                        break;
                    }
                    _ => temp.push(now.clone())
                }
                now = now.add(vec)
            }
        }
        ret
    }

    fn do_move(&mut self, mv: &Move) {
        if DEBUG { println!("+ {:?} {}", &mv, &self) }
        let turn = self.get_turn_color();
        let opponent_turn = turn.opposite();
        let cell = Some(turn);
        self.set(&mv.to, cell);
        for change in &mv.changes {
            self.set(&change, cell);
        }
        self.add_count(&turn, mv.changes.len() as i8 + 1);
        self.add_count(&opponent_turn, -(mv.changes.len() as i8));
        self.ply += 1;
    }

    fn undo_move(&mut self, mv: &Move) {
        if DEBUG { println!("- {:?} {}", &mv, &self) }
        let opponent_turn = self.get_turn_color();
        let turn = opponent_turn.opposite();
        let cell = Some(opponent_turn);
        self.set(&mv.to, None);
        for change in &mv.changes {
            self.set(&change, cell);
        }
        self.add_count(&turn, -(mv.changes.len() as i8 + 1));
        self.add_count(&opponent_turn, mv.changes.len() as i8);
        self.ply -= 1;
    }

    fn evaluate(&self) -> i16 {
        (self.counts[0] - self.counts[1]) as i16
    }


    fn on_board(coord: &Coord) -> bool {
        0 <= coord.x && coord.x < 8 && 0 <= coord.y && coord.y < 8
    }
}

impl search::Searchable<Move> for Othello {
    fn get_moves(&self) -> Vec<Move> {
        self.get_moves()
    }
    fn do_move(&mut self, mv: &Move) {
        self.do_move(mv)
    }
    fn undo_move(&mut self, mv: &Move) {
        self.undo_move(mv)
    }
    fn evaluate(&self) -> i16 {
        self.evaluate()
    }
    fn positive_turn(&self) -> bool {
        self.positive_turn()
    }
}

impl fmt::Display for Othello {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut ret = "".to_string();
        for (_, &row) in self.board.iter().enumerate() {
            ret += "\n";
            for (_, &piece) in row.iter().enumerate() {
                ret += match piece {
                    None => ".",
                    Some(Color::Black) => "o",
                    Some(_) => "x",
                }
            }
        }
        write!(f, "{}", ret)
    }
}