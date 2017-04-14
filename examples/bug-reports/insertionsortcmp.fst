module InsertionSortCmp

open FStar.List.Tot

val sorted: #a:Type -> (a -> a -> Tot bool) -> list a -> Tot bool
let rec sorted #a f l = match l with
    | [] -> true
    | [x] -> true
    | x::y::xs -> f x y && sorted f (y::xs)

type permutation (#a:eqtype) (l1:list a) (l2:list a) =
    length l1 == length l2 /\ (forall n. mem n l1 == mem n l2)

type total_order (#a:eqtype) (f:a -> a -> Tot bool) =
    (forall a. f a a)                                         (* reflexivity   *)
    /\ (forall a1 a2. (f a1 a2 /\ f a2 a1)  ==> a1 == a2)       (* anti-symmetry *)
    /\ (forall a1 a2 a3. f a1 a2 /\ f a2 a3 ==> f a1 a3)        (* transitivity  *)
    /\ (forall a1 a2. f a1 a2 \/ f a2 a1)                       (* totality      *)

val insert : #a:eqtype -> f:(a -> a -> Tot bool){total_order f} -> i:a ->
             l:list a (* {sorted f l} *) ->
             Tot (r:list a {(*sorted f r /\*) permutation r (i::l)})
let rec insert #a f i l =
  match l with
  | [] -> [i]
  | hd::tl ->
     if f i hd then i::l
     else hd::(insert f i tl)

(* for some reason, sortedness was not intrinsically provable,
   but it is extrinsicly provable  *)
val insert_sorted : #a:eqtype -> f:(a -> a -> Tot bool){total_order f} -> i:a ->
                    l:list a {sorted f l} ->
                    Lemma (requires True) (ensures (sorted f (insert f i l)))
let rec insert_sorted #a f i l =
  match l with
  | [] -> ()
  | hd :: tl ->
     if f i hd then () else insert_sorted f i tl

(* An axiomatic proof of the cons case also succeeds *)
val insert_sorted_cons_false: #a:eqtype ->
  f:(a -> a -> Tot bool) {total_order f} ->
  i:a ->
  l:list a {sorted f l} ->
  hd:a ->
  tl:list a ->
  insert_tl:list a { sorted f insert_tl /\ permutation insert_tl (i::tl) /\
    (List.Tot.hd insert_tl == i \/ List.Tot.hd insert_tl == hd) } ->
  Lemma
  (requires (l == hd::tl /\ f i hd == false))
  (ensures (sorted f (hd::insert_tl)))
let insert_sorted_cons_false #a f i l hd tl insert_tl = ()
