use std::vec::Vec;

#[derive(Copy, Clone, Debug)]
enum Op {
    Add(usize, usize, usize),
    Sub(usize, usize, usize),
    Mul(usize, usize, usize),
    Div(usize, usize, usize),
    If(Box<Op>, Box<Op>),
    ElseJmp(Box<Op>),
    Exit(i32),
    Val(usize)
//     U8(u8),
//     U32(u32),
//     U64(u64),
//     I8(i8),
//     I64(I32),
//     I64(I64),
//     F64(f32),
//     F64(f64),
}

enum MathOp {
    Add, Sub, Mul, Div
}

fn main() {
    // Little test program
    let mut ops = vec![
	Op::Add(5, 6, 7),
	Op::Sub(7, 5, 5),
	Op::Mul(7, 7, 7),
	Op::Div(7, 5, 6),
	Op::Exit(1),
	Op::Val(15),
	Op::Val(15),
	Op::Val(0)
    ];

    //let mut _stack = Vec::new();
    let mut index = 0;
    while index != ops.len() {
	match ops[index] {
	    Op::Add(n1, n2, out) => {
		ops[out] = Op::Val(run_math_op(ops[n1], ops[n2], MathOp::Add));
		index += 1;
	    },
	    Op::Sub(n1, n2, out) => {
		ops[out] = Op::Val(run_math_op(ops[n1], ops[n2], MathOp::Sub));
		index += 1;
	    },
	    Op::Mul(n1, n2, out) => {
		ops[out] = Op::Val(run_math_op(ops[n1], ops[n2], MathOp::Mul));
		index += 1;
	    },
	    Op::Div(n1, n2, out) => {
		ops[out] = Op::Val(run_math_op(ops[n1], ops[n2], MathOp::Div));
		index += 1;
	    },
	    Op::Exit(code) => {
		println!("{:?}", ops);
		std::process::exit(code);
	    },
	    Op::Val(_) => {
		index += 1;
	    }
	    _ => println!("Not implemented yet!")
	}
    }
}

fn run_math_op(n1: Op, n2: Op, op: MathOp) -> usize {
    return match (n1, n2) {
	(Op::Val(v1), Op::Val(v2)) => {
	    match op {
		MathOp::Add => v1 + v2,
		MathOp::Sub => v1 - v2,
		MathOp::Mul => v1 * v2,
		MathOp::Div => v1 / v2
	    }
	},
	_ => {
	    println!("Error: Trying to access memory location that's not a value");
	    std::process::exit(1);
	}
    };
} 
