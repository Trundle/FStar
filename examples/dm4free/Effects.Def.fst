(* This module defines 4 monads arranged in a partial order

       stexn
        ^ ^
       /   \       
      st   exn 
       \   /
        v v 
       exnst

   Proving the monad laws for each point and the morphism laws for
   each edge.
*)
module Effects.Def
open FStar.FunctionalExtensionality //proving the laws requires feq

//A generic template for proving the monad laws, via some equivalence relation eq_m
let eq_m (m:Type -> Type) = eq:(a:Type -> m a -> m a -> Type){forall a x y. eq a x y ==> x==y}
val monad_laws_via_eq: m:(Type -> Type) 
         -> eq:eq_m m
	 -> return:(a:Type -> x:a -> Tot (m a))
	 ->   bind:(a:Type -> b:Type -> m a -> (a -> Tot (m b)) -> Tot (m b)) 
	 ->   Lemma (requires (forall (a:Type) (f:m a). eq a (bind a a f (return a)) f) 
			   /\ (forall (a:Type) (b:Type) (x:a) (f:a -> Tot (m b)). eq b (bind a b (return a x) f) (f x)) 
			   /\ (forall (a:Type) (b:Type) (c:Type) (f:m a) (g:(a -> Tot (m b))) (h:(b -> Tot (m c))). 
			             eq c (bind a c f (fun x -> bind b c (g x) h)) (bind b c (bind a b f g) h)))
		   (ensures  (forall (a:Type) (f:m a). bind a a f (return a) == f)                               //right unit
			   /\ (forall (a:Type) (b:Type) (x:a) (f:a -> Tot (m b)). bind a b (return a x) f == f x)  //left unit
			   /\ (forall (a:Type) (b:Type) (c:Type) (f:m a) (g:(a -> Tot (m b))) (h:(b -> Tot (m c))). //associativity
			             bind a c f (fun x -> bind b c (g x) h) == bind b c (bind a b f g) h))
let monad_laws_via_eq m eq return bind = ()

//A generic template for proving the monad morphism laws, via some equivalence relation eq_m
val morphism_laws_via_eq: m:(Type -> Type) 
			-> n:(Type -> Type) 
			-> eq_n:eq_m n
			-> return_m:(a:Type -> x:a -> Tot (m a))
			-> bind_m:(a:Type -> b:Type -> m a -> (a -> Tot (m b)) -> Tot (m b)) 
			-> return_n:(a:Type -> x:a -> Tot (n a))
			-> bind_n:(a:Type -> b:Type -> n a -> (a -> Tot (n b)) -> Tot (n b)) 
			-> lift:(a:Type -> m a -> Tot (n a))
			-> Lemma (requires (forall (a:Type) (x:a). eq_n a (lift a (return_m a x)) (return_n a x))
					/\ (forall (a:Type) (b:Type) (f:m a) (g: a -> Tot (m b)). 
					      eq_n b (lift b (bind_m a b f g)) (bind_n a b (lift a f) (fun x -> lift b (g x)))))
			        (ensures  (forall (a:Type) (x:a). lift a (return_m a x) == return_n a x)                          //lift-unit
					/\ (forall (a:Type) (b:Type) (f:m a) (g: a -> Tot (m b)).
					      lift b (bind_m a b f g) == bind_n a b (lift a f) (fun x -> lift b (g x))))         //lift-bind
#set-options "--initial_fuel 0 --max_fuel 0 --initial_ifuel 0 --max_ifuel 0 --z3rlimit 20"
let morphism_laws_via_eq m n eqn return_n bind_m return_n bind_n lift = ()
#reset-options

(* ******************************************************************************)
(* Effect (st a) : A state monad over an abstract state type s                  *)
(* ******************************************************************************)
assume type s : Type //an abstract type of the state

let st (a:Type) = s -> Tot (a * s)

let eq_st (a:Type) (x:st a) (y:st a) = feq x y //extensional equality on st

let return_st  (a:Type) (x:a)
  : st a = fun s -> (x, s)
  
let bind_st (a:Type) (b:Type) (f:st a) (g: a -> Tot (st b))
  : st b 
  = fun s0 -> let x, s1 = f s0 in 
           g x s1

//Two actions: get and put
let get (u:unit) : st s = fun s -> s, s
let put (s:s) : st unit = fun _ -> (),s

let st_laws = monad_laws_via_eq st eq_st return_st bind_st

(* ******************************************************************************)
(* Effect (ex a) : A state monad over an abstract state type s                  *)
(* ******************************************************************************)
let ex (a:Type) = unit -> Tot (option a)

let eq_ex (a:Type) (x:ex a) (y:ex a) = feq x y //extensional equality on ex

let return_ex (a:Type) (x:a) 
  : ex a 
  = fun _ -> Some x
  
let bind_ex (a:Type) (b:Type) (f:ex a) (g: a -> Tot (ex b)) 
  : ex b 
  = fun _ -> match f () with 
          | None -> None
   	  | Some x -> g x ()

//one action: raise
let raise_ (#a:Type) 
  : ex a
  = fun () -> None

//and a handler
let handle (#a:Type) (f:ex a) (g:unit -> Tot a) 
  : Tot a 
  = match f () with 
    | None -> g()
    | Some x -> x

let ex_laws = monad_laws_via_eq ex eq_ex return_ex bind_ex

(* ******************************************************************************)
(* Effect (stexn a) : A combined monad, exceptions over state                   *)
(* ******************************************************************************)
let stexn (a:Type) = s -> Tot (option a * s)

let eq_stexn (a:Type) (x:stexn a) (y:stexn a) = feq x y

let return_stexn (a:Type) (x:a) 
  : stexn a 
  = fun s -> Some x, s
  
let bind_stexn (a:Type) (b:Type) (f:stexn a) (g: a -> Tot (stexn b)) 
  : stexn b 
  = fun s0 -> match f s0 with 
           | None, s1 -> None, s1
  	   | Some x, s1 -> g x s1

let stexn_laws = monad_laws_via_eq stexn eq_stexn return_stexn bind_stexn

(* ******************************************************************************)
(* Effect (exnst a) : A combined monad, state over exceptions                   *)
(* ******************************************************************************)
let exnst (a:Type) = s -> Tot (option (a * s))

let eq_exnst (a:Type) (x:exnst a) (y:exnst a) = feq x y

let return_exnst (a:Type) (x:a) 
  : exnst a 
  = fun s -> Some (x, s)
  
let bind_exnst (a:Type) (b:Type) (f:exnst a) (g: a -> Tot (exnst b)) 
  : exnst b 
  = fun s0 -> match f s0 with 
           | None -> None
           | Some (x, s1) -> g x s1

let exnst_laws = monad_laws_via_eq exnst eq_exnst return_exnst bind_exnst

(* ******************************************************************************)
(* Morphism: st -> stexn                                                        *)
(* ******************************************************************************)
let lift_st_stexn (a:Type) (f:st a) 
  : stexn a 
  = fun s0 -> let x, s1 = f s0 in Some x, s1

let morphism_lift_st_exn =
  morphism_laws_via_eq st stexn eq_stexn
		       return_st bind_st 
		       return_stexn bind_stexn 
		       lift_st_stexn

(* ******************************************************************************)
(* Morphism: exn -> stexn                                                       *)
(* ******************************************************************************)
let lift_ex_stexn (a:Type) (f:ex a) 
  : stexn a 
  = fun s0 -> f (), s0

let morphism_lift_ex_stexn = 
  morphism_laws_via_eq ex stexn eq_stexn
		       return_ex bind_ex 
		       return_stexn bind_stexn 
		       lift_ex_stexn

(* ******************************************************************************)
(* Morphism: st -> exnst                                                        *)
(* ******************************************************************************)
let lift_st_exnst (a:Type) (f:st a) 
  : exnst a 
  = fun s0 -> Some (f s0)

let morphism_lift_st_exnst = 
  morphism_laws_via_eq st exnst eq_exnst
		       return_st bind_st 
		       return_exnst bind_exnst 
		       lift_st_exnst

(* ******************************************************************************)
(* Morphism: ex -> exnst                                                        *)
(* ******************************************************************************)
let lift_ex_exnst (a:Type) (f:ex a) 
  : exnst a 
  = fun s0 -> match f () with 
           | None -> None
	   | Some x -> Some (x, s0)

let morphism_lift_ex_exnst = 
  morphism_laws_via_eq ex exnst eq_exnst
		       return_ex bind_ex 
		       return_exnst bind_exnst 
		       lift_ex_exnst
