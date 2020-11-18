#[derive(Clone, Debug)]
enum Code<'a> {
    O(Op),
    L(Label<'a>),
    T(Type),
}

#[derive(Clone, Debug)]
enum Op {
    Add(Type, Type, Type),
    Sub(Type, Type, Type),
    Mul(Type, Type, Type),
    Div(Type, Type, Type),
    // Cond, else branch. All ifs must have an else.
    If(Type, Type),
    Delete(Type),
    Exit(i32),
}

#[derive(Clone, Debug)]
enum Label<'a> {
    OrElse(Type),
    Func(&'a str),
    Let(&'a str, Type),
}

#[derive(Copy, Clone, Debug)]
enum Type {
    Mem(usize),
    Num(Number),
    Char(char),
}

#[derive(Copy, Clone, Debug)]
enum Number {
    Int(i32),
    Double(f64),
}

#[derive(Copy, Clone, Debug)]
enum MathOp {
    AddOp,
    SubOp,
    MulOp,
    DivOp,
}

trait ToEnum {
    fn to_type(&self) -> Type;
    fn to_code(&self) -> Code {
        Code::T(self.to_type())
    }
}

impl ToEnum for i32 {
    fn to_type(&self) -> Type {
        Type::Num(Number::Int(*self))
    }
}

impl ToEnum for f64 {
    fn to_type(&self) -> Type {
        Type::Num(Number::Double(*self))
    }
}

impl ToEnum for usize {
    fn to_type(&self) -> Type {
        Type::Mem(*self)
    }
}

macro_rules! add {
    ($x:expr, $y:expr, $z:expr) => {
        Code::O(Op::Add(
            ToEnum::to_type(&$x),
            ToEnum::to_type(&$y),
            Type::Mem($z),
        ))
    };
}

macro_rules! sub {
    ($x:expr, $y:expr, $z:expr) => {
        Code::O(Op::Sub(
            ToEnum::to_type(&$x),
            ToEnum::to_type(&$y),
            Type::Mem($z),
        ))
    };
}

macro_rules! mul {
    ($x:expr, $y:expr, $z:expr) => {
        Code::O(Op::Mul(
            ToEnum::to_type(&$x),
            ToEnum::to_type(&$y),
            Type::Mem($z),
        ))
    };
}

macro_rules! div {
    ($x:expr, $y:expr, $z:expr) => {
        Code::O(Op::Div(
            ToEnum::to_type(&$x),
            ToEnum::to_type(&$y),
            Type::Mem($z),
        ))
    };
}

macro_rules! exit {
    ($x:expr) => {
        Code::O(Op::Exit($x))
    };
}

macro_rules! int {
    ($n: expr) => {
        Code::T(Type::Num(Number::Int($n)))
    };
}

macro_rules! ifThen {
    ($if: expr, $else: expr) => {
        Code::O(Op::If(ToEnum::to_type(&$if), Type::Mem($else)))
    };
}

macro_rules! orElse {
    ($end: expr) => {
        Code::L(Label::OrElse(Type::Mem($end)))
    };
}

fn main() {
    // Little test program
    let mut ops = vec![
        ifThen!(1, 2),
        add!(15, 10, 5),
        orElse!(3),
        sub!(15, 10, 5),
        exit!(1),
        int!(0),
    ];

    let exitCode = exec(ops);
    println!("System terminated with exit code {:?}", exitCode);
}

fn exec(mut ops: Vec<Code>) -> i32 {
    use Code::*;
    use MathOp::*;
    use Op::*;
    use Type::*;
    use Label::*;

    let mut ifStack = 0;
    let mut exitCode = 0;
    let mut index = 0;
    while index != ops.len() {
        match &ops[index].clone() {
            O(Add(Num(n1), Num(n2), Mem(out))) => {
                ops[*out] = run_math_op(*n1, *n2, AddOp);
                index += 1;
            }
            O(Sub(Num(n1), Num(n2), Mem(out))) => {
                ops[*out] = run_math_op(*n1, *n2, SubOp);
                index += 1;
            }
            O(Mul(Num(n1), Num(n2), Mem(out))) => {
                ops[*out] = run_math_op(*n1, *n2, MulOp);
                index += 1;
            }
            O(Div(Num(n1), Num(n2), Mem(out))) => {
                ops[*out] = run_math_op(*n1, *n2, DivOp);
                index += 1;
            }
            O(If(cond, Mem(orElse))) => {
		match ops[*orElse] {
		    L(OrElse(_)) => {},
		    _ => {
			println!("Error: Illegal memory address. Must jump to a valid else point.");
			std::process::exit(3);
		    }
		};
		
		if is_true(*cond) {
		    ifStack += 1;
		    index += 1;
		}
		else {
		    index = *orElse;
		}
            }
            L(OrElse(Mem(i))) => {
		if ifStack == 0 {
		    index += 1;
		}
		else {
		    ifStack -= 1;
		    index = *i;
		}
	    }
            O(Exit(code)) => {
                println!("{:?}", ops);
                std::process::exit(*code);
            }
            _ => {
                println!("Not implemented yet!");
                std::process::exit(2);
            }
        }
    }

    exitCode
}

fn is_true(cond: Type) -> bool {
    0 != match cond {
        Type::Num(Number::Int(n)) => n,
        _ => 1,
    }
}

fn run_math_op<'a>(n1: Number, n2: Number, op: MathOp) -> Code<'a> {
    use Code::*;
    use MathOp::*;
    use Number::*;
    use Type::*;

    let float_op = |v1, v2| match op {
        AddOp => T(Num(Double(v1 + v2))),
        SubOp => T(Num(Double(v1 - v2))),
        MulOp => T(Num(Double(v1 * v2))),
        DivOp => T(Num(Double(v1 / v2))),
    };

    return match (n1, n2) {
        (Int(v1), Int(v2)) => match op {
            AddOp => T(Num(Int(v1 + v2))),
            SubOp => T(Num(Int(v1 - v2))),
            MulOp => T(Num(Int(v1 * v2))),
            DivOp => T(Num(Int(v1 / v2))),
        },
        (Int(v1), Double(v2)) => float_op(v1 as f64, v2),
        (Double(v1), Int(v2)) => float_op(v1, v2 as f64),
        (Double(v1), Double(v2)) => float_op(v1, v2),
    };
}
