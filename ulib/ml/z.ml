type t = Big_int.big_int

let of_int : int -> t = Big_int.big_int_of_int
let (~$) = of_int

let to_int : t -> int = Big_int.int_of_big_int

let to_string : t -> string = Big_int.string_of_big_int
