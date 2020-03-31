use std::vec::Vec;

#[derive(Copy, Clone, Debug)]
enum Code {
    Op(Op),
    Label(Label),
    Type(Type)
}

#[derive(Copy, Clone, Debug)]
enum Op {
    Add(Type, Type, Type),
    Sub(Type, Type, Type),
    Mul(Type, Type, Type),
    Div(Type, Type, Type),
    If(Type, Label),
    Exit(i32),
}

#[derive(Copy, Clone, Debug)]
enum Label {
    Else(Type),
    Func(Type)
}

#[derive(Copy, Clone, Debug)]
enum Type {
    Mem(usize),
    Num(Num),
    Char(char),
}

#[derive(Copy, Clone, Debug)]
enum Num {
    Int(i32),
    Double(f64)
}

#[derive(Copy, Clone, Debug)]
enum MathOp {
    Add, Sub, Mul, Div
}

fn main() {
    // Little test program
    let mut ops = vec![
	Code::Op(Op::Add(Type::Num(Num::Int(15)), Type::Num(Num::Int(10)), Type::Mem(5))),
	Code::Op(Op::Sub(Type::Num(Num::Int(15)), Type::Num(Num::Int(10)), Type::Mem(6))),
	Code::Op(Op::Mul(Type::Num(Num::Int(15)), Type::Num(Num::Int(10)), Type::Mem(7))),
	Code::Op(Op::Div(Type::Num(Num::Int(15)), Type::Num(Num::Int(10)), Type::Mem(8))),
	Code::Op(Op::Exit(1)),
	Code::Type(Type::Num(Num::Int(0))),
	Code::Type(Type::Num(Num::Int(0))),
	Code::Type(Type::Num(Num::Int(0))),
	Code::Type(Type::Num(Num::Int(0))),
    ];

    //let mut _stack = Vec::new();
    let mut index = 0;
    while index != ops.len() {
	match ops[index] {
	    Code::Op(Op::Add(Type::Num(n1), Type::Num(n2), Type::Mem(out))) => {
		ops[out] = run_math_op(n1, n2, MathOp::Add);
		index += 1;
	    },
	    Code::Op(Op::Sub(Type::Num(n1), Type::Num(n2), Type::Mem(out))) => {
		ops[out] = run_math_op(n1, n2, MathOp::Sub);
		index += 1;
	    },
	    Code::Op(Op::Mul(Type::Num(n1), Type::Num(n2), Type::Mem(out))) => {
		ops[out] = run_math_op(n1, n2, MathOp::Mul);
		index += 1;
	    },
	    Code::Op(Op::Div(Type::Num(n1), Type::Num(n2), Type::Mem(out))) => {
		ops[out] = run_math_op(n1, n2, MathOp::Div);
		index += 1;
	    },
	    Code::Op(Op::Exit(code)) => {
		println!("{:?}", ops);
		std::process::exit(code);
	    },
	    _ => println!("Not implemented yet!")
	}
    }
}


fn run_math_op(n1: Num, n2: Num, op: MathOp) -> Code {
    let float_op = |v1, v2| match op {
	MathOp::Add => Code::Type(Type::Num(Num::Double(v1 + v2))),
	MathOp::Sub => Code::Type(Type::Num(Num::Double(v1 - v2))),
	MathOp::Mul => Code::Type(Type::Num(Num::Double(v1 * v2))),
	MathOp::Div => Code::Type(Type::Num(Num::Double(v1 / v2))),
    };

    return match (n1, n2) {
	(Num::Int(v1), Num::Int(v2)) => {
	    match op {
		MathOp::Add => Code::Type(Type::Num(Num::Int(v1 + v2))),
		MathOp::Sub => Code::Type(Type::Num(Num::Int(v1 - v2))),
		MathOp::Mul => Code::Type(Type::Num(Num::Int(v1 * v2))),
		MathOp::Div => Code::Type(Type::Num(Num::Int(v1 / v2))),
	    }
	},
	(Num::Int(v1), Num::Double(v2)) => float_op(v1 as f64, v2),
	(Num::Double(v1), Num::Int(v2)) => float_op(v1, v2 as f64),
	(Num::Double(v1), Num::Double(v2)) => float_op(v1, v2),
    };
} 
