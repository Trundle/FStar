module Hello

open FStar.IO

//
// Vector with explicit length in its type
type vector (a:Type) : nat -> Type =
   | VNil :  vector a 0
   | VCons : hd:a -> #n:nat -> tl:vector a n -> vector a (n + 1)

val head : #a:Type -> #n:pos -> vector a n -> Tot a
let head #a #n v = match v with
  | VCons x _ -> x

val nth : n:nat -> #m:nat{m > n} -> vector 'a m -> Tot 'a
let rec nth n #m (VCons x #m' xs) =
  if n = 0
  then x
  else nth (n-1) #m' xs

val append: #a:Type -> #n1:nat -> #n2:nat -> l:vector a n1 -> vector a n2 ->  Tot (vector a (n1 + n2))
let rec append #a #n1 #n2 v1 v2 =
  match v1 with
    | VNil -> v2
    | VCons hd tl -> VCons hd (append tl v2)


//
// Let the fun begin

let spam : vector int 1 = VCons 1337 VNil
let double_spam = append spam spam
let main =
  print_string "Hello F*!\n";
  print_string ("Head of spam is: " ^ (string_of_int (head spam)) ^ "\n");
  print_string ("2nd element of spam :: spam is: " ^ (string_of_int (nth 1 double_spam)) ^ "\n");
  print_string "…and now some useful information about the heap used by V8:";
  V8.print_v8_heap_statistics ()
