module FStar.HyperStack
open FStar.HyperHeap
module M  = FStar.Map
module HH = FStar.HyperHeap

let is_in (r:rid) (h:HH.t) = h `Map.contains` r

let is_stack_region r = color r > 0
let is_eternal_color c = c <= 0
let is_eternal_region r  = is_eternal_color (color r)

type sid = r:rid{is_stack_region r} //stack region ids

let is_above r1 r2      = r1 `includes` r2
let is_just_below r1 r2 = r1 `extends`  r2
let is_below r1 r2      = r2 `is_above` r1
let is_strictly_below r1 r2 = r1 `is_below` r2 && r1<>r2
let is_strictly_above r1 r2 = r1 `is_above` r2 && r1<>r2

let downward_closed (h:HH.t) = 
  forall (r:rid). r `is_in` h  //for any region in the memory
        ==> (r=HH.root    //either is the root
	    \/ (forall (s:rid). r `is_above` s  //or, any region beneath it
			  /\ s `is_in` h   //that is also in the memory
		     ==> (is_stack_region r = is_stack_region s))) //must be of the same flavor as itself

let is_tip (tip:HH.rid) (h:HH.t) = 
  (is_stack_region tip \/ tip=HH.root)                                  //the tip is a stack region, or the root
  /\ tip `is_in` h                                                      //the tip is active
  /\ (forall (r:sid). r `is_in` h <==> r `is_above` tip)                      //any other sid activation is a above (or equal to) the tip

let hh = h:HH.t{HH.root `is_in` h /\ HH.map_invariant h /\ downward_closed h}        //the memory itself, always contains the root region, and the parent of any active region is active

noeq type mem =
  | HS : h:hh
       -> tip:rid{tip `is_tip` h}                                                   //the id of the current top-most region
       -> mem

let empty_mem (m:HH.t) = 
  let empty_map = Map.restrict (Set.empty) m in 
  let h = Map.upd empty_map HH.root Heap.emp in 
  let tip = HH.root in 
  HS h tip
 
let test0 (m:mem) (r:rid{r `is_above` m.tip}) = 
    assert (r `is_in` m.h)

let test1 (m:mem) (r:rid{r `is_above` m.tip}) = 
    assert (r=HH.root \/ is_stack_region r)

let test2 (m:mem) (r:sid{m.tip `is_above` r /\ m.tip <> r}) =  
   assert (~ (r `is_in` m.h))

let dc_elim (h:HH.t{downward_closed h}) (r:rid{r `is_in` h /\ r <> HH.root}) (s:rid)
  : Lemma (r `is_above` s /\ s `is_in` h ==> is_stack_region r = is_stack_region s)
  = ()	  

let test3 (m:mem) (r:rid{r <> HH.root /\ is_eternal_region r /\ m.tip `is_above` r /\ is_stack_region m.tip})
  : Lemma (~ (r `is_in` m.h))
  = root_has_color_zero()

let test4 (m:mem) (r:rid{r <> HH.root /\ is_eternal_region r /\ r `is_above` m.tip /\ is_stack_region m.tip})
  : Lemma (~ (r `is_in` m.h))
  = ()

let eternal_region_does_not_overlap_with_tip (m:mem) (r:rid{is_eternal_region r /\ not (HH.disjoint r m.tip) /\ r<>HH.root /\ is_stack_region m.tip})
  : Lemma (requires True)
	  (ensures (~ (r `is_in` m.h)))
  = root_has_color_zero()

let poppable m = m.tip <> HH.root

let remove_elt (#a:eqtype) (s:Set.set a) (x:a) = Set.intersect s (Set.complement (Set.singleton x))

let popped m0 m1 =
  poppable m0
  /\ HH.parent m0.tip = m1.tip
  /\ Set.equal (Map.domain m1.h) (remove_elt (Map.domain m0.h) m0.tip)
  /\ Map.equal m1.h (Map.restrict (Map.domain m1.h) m0.h)

let pop (m0:mem{poppable m0}) : GTot mem =
  root_has_color_zero();
  let dom = remove_elt (Map.domain m0.h) m0.tip in
  let h0 = m0.h in
  let h1 = Map.restrict dom m0.h in
  let tip0 = m0.tip in
  let tip1 = HH.parent tip0 in
  assert (forall (r:sid). Map.contains h1 r ==>
  	    (forall (s:sid). includes s r ==> Map.contains h1 s));
  HS h1 tip1

//A (reference a) may reside in the stack or heap, and may be manually managed
unopteq type reference (a:Type) =
  | MkRef : id:rid -> mm:bool -> ref:HH.rref id a -> reference a

//adding (not s.mm) to stackref and ref so as to keep their semantics as is
let stackref (a:Type) = s:reference a { is_stack_region s.id && not s.mm }
let ref (a:Type) = s:reference a{is_eternal_region s.id && not s.mm}

let mmstackref (a:Type) = s:reference a {is_stack_region s.id && s.mm }
let mmref (a:Type) = s:reference a{is_eternal_region s.id && s.mm}

(*
 * The Map.contains conjunct is necessary to prove that upd
 * returns a valid mem. In particular, without Map.contains,
 * we cannot prove the eternal regions invariant that all
 * included regions of a region are also in the map.
 *)
let live_region (m:mem) (i:rid) =
  (is_eternal_region i \/ i `is_above` m.tip)
  /\ Map.contains m.h i

(*
 * AR: adding a weaker version of live_region that could be
 * used in the precondition of read.
 *)
let weak_live_region (m:mem) (i:rid) =
  is_eternal_region i \/ i `is_above` m.tip

let contains (#a:Type) (m:mem) (s:reference a) =
  live_region m s.id
  /\ HH.contains_ref s.ref m.h

private val weak_live_region_implies_eternal_or_in_map: r:rid -> m:mem -> Lemma
  (requires (weak_live_region m r))
  (ensures (is_eternal_region r \/ Map.contains m.h r))
let weak_live_region_implies_eternal_or_in_map r m = ()

(*
 * AR: corresponding to weak_live_region above.
 * Replacing HH.contains_ref with weak_contains_ref under mm flag.
 * If the reference is manually managed, we must prove Heap.contains
 * before reading the ref.
 *)
let weak_contains (#a:Type) (m:mem) (s:reference a) =
  weak_live_region m s.id /\
  (if s.mm then HH.weak_contains_ref s.ref m.h else True)

let upd (#a:Type) (m:mem) (s:reference a{live_region m s.id}) (v:a)
  : GTot mem
  = HS (m.h.[s.ref] <- v) m.tip

(*
 * AR: why is this not enforcing live_region ?
 *)
let sel (#a:Type) (m:mem) (s:reference a)
  : GTot a
  = m.h.[s.ref]

let equal_domains (m0:mem) (m1:mem) =
  m0.tip = m1.tip
  /\ Set.equal (Map.domain m0.h) (Map.domain m1.h)
  /\ (forall r. Map.contains m0.h r ==> TSet.equal (Heap.domain (Map.sel m0.h r)) (Heap.domain (Map.sel m1.h r)))

let lemma_equal_domains_trans (m0:mem) (m1:mem) (m2:mem) : Lemma
  (requires (equal_domains m0 m1 /\ equal_domains m1 m2))
  (ensures  (equal_domains m0 m2))
  [SMTPat (equal_domains m0 m1); SMTPat (equal_domains m1 m2)]
  = ()

let equal_stack_domains (m0:mem) (m1:mem) =
  m0.tip = m1.tip
  /\ (forall r. (is_stack_region r /\ r `is_above` m0.tip) ==> TSet.equal (Heap.domain (Map.sel m0.h r)) (Heap.domain (Map.sel m1.h r)))

let lemma_equal_stack_domains_trans (m0:mem) (m1:mem) (m2:mem) : Lemma
  (requires (equal_stack_domains m0 m1 /\ equal_stack_domains m1 m2))
  (ensures  (equal_stack_domains m0 m2))
  [SMTPat (equal_stack_domains m0 m1); SMTPat (equal_stack_domains m1 m2)]
  = ()

let modifies (s:Set.set rid) (m0:mem) (m1:mem) =
  HH.modifies_just s m0.h m1.h
  /\ m0.tip=m1.tip

let modifies_transitively (s:Set.set rid) (m0:mem) (m1:mem) =
  HH.modifies s m0.h m1.h
  /\ m0.tip=m1.tip

let heap_only (m0:mem) =
  m0.tip = HH.root

let top_frame (m:mem) = Map.sel m.h m.tip
  
let fresh_frame (m0:mem) (m1:mem) =
  not (Map.contains m0.h m1.tip)
  /\ HH.parent m1.tip = m0.tip
  /\ m1.h == Map.upd m0.h m1.tip Heap.emp

let modifies_drop_tip (m0:mem) (m1:mem) (m2:mem) (s:Set.set rid)
    : Lemma (fresh_frame m0 m1 /\
	     modifies_transitively (Set.union s (Set.singleton m1.tip)) m1 m2 ==> 
	     modifies_transitively s m0 (pop m2))
    = ()

let lemma_pop_is_popped (m0:mem{poppable m0})
  : Lemma (popped m0 (pop m0))
  = let m1 = pop m0 in
    assert (Set.equal (Map.domain m1.h) (remove_elt (Map.domain m0.h) m0.tip))

type s_ref (i:rid) (a:Type) = s:reference a{s.id = i}

let frameOf #a (s:reference a) = s.id

let as_ref #a (x:reference a)  : GTot (Heap.ref a) = HH.as_ref #a #x.id x.ref
let as_aref #a (x:reference a) : GTot Heap.aref = Heap.Ref (HH.as_ref #a #x.id x.ref)
let modifies_one id h0 h1 = HH.modifies_one id h0.h h1.h
let modifies_ref (id:rid) (s:TSet.set Heap.aref) (h0:mem) (h1:mem) =
  HH.modifies_rref id s h0.h h1.h /\ h1.tip=h0.tip

let lemma_upd_1 #a (h:mem) (x:reference a) (v:a) : Lemma
  (requires (contains h x))
  (ensures (contains h x
	    /\ modifies_one (frameOf x) h (upd h x v)
	    /\ modifies_ref (frameOf x) (TSet.singleton (as_aref x)) h (upd h x v)
	    /\ sel (upd h x v) x == v ))
  [SMTPat (upd h x v); SMTPatT (contains h x)]
  = ()

let lemma_upd_2 #a (h:mem) (x:reference a) (v:a) : Lemma
  (requires (~(contains h x) /\ frameOf x = h.tip))
  (ensures (~(contains h x)
	    /\ frameOf x = h.tip
	    /\ modifies_one h.tip h (upd h x v)
	    /\ modifies_ref h.tip TSet.empty h (upd h x v)
	    /\ sel (upd h x v) x == v ))
  [SMTPat (upd h x v); SMTPatT (~(contains h x))]
  = ()

val lemma_live_1: #a:Type ->  #a':Type -> h:mem -> x:reference a -> x':reference a' -> Lemma
  (requires (contains h x /\ ~(contains h x')))
  (ensures  (x.id <> x'.id \/ ~ (as_ref x === as_ref x')))
  [SMTPat (contains h x); SMTPat (~(contains h x'))]
let lemma_live_1 #a #a' h x x' = ()

let above_tip_is_live (#a:Type) (m:mem) (x:reference a) : Lemma
  (requires (x.id `is_above` m.tip))
  (ensures (x.id `is_in` m.h))
  = ()

(*
 * AR: relating contains and weak_contains.
 *)
let contains_implies_weak_contains (#a:Type) (h:mem) (x:reference a) :Lemma
  (requires (True))
  (ensures (contains h x ==> weak_contains h x))
  [SMTPatOr [[SMTPat (contains h x)]; [SMTPat (weak_contains h x)]] ]
  = ()

noeq type some_ref =
| Ref : #a:Type0 -> reference a -> some_ref

let some_refs = list some_ref

let rec regions_of_some_refs (rs:some_refs) : Tot (Set.set rid) = 
  match rs with
  | [] -> Set.empty
  | (Ref r)::tl -> Set.union (Set.singleton r.id) (regions_of_some_refs tl)

let rec refs_in_region (r:rid) (rs:some_refs) : GTot (TSet.set Heap.aref) =
  match rs with
  | [] -> TSet.empty
  | (Ref x)::tl ->
    TSet.union (if x.id=r then TSet.singleton (as_aref x) else TSet.empty)
               (refs_in_region r tl)

unfold let mods (rs:some_refs) h0 h1 =
    modifies (normalize_term (regions_of_some_refs rs)) h0 h1
  /\ (forall (r:rid). modifies_ref r (normalize_term (refs_in_region r rs)) h0 h1)

////////////////////////////////////////////////////////////////////////////////
let eternal_disjoint_from_tip (h:mem{is_stack_region h.tip})
			      (r:rid{is_eternal_region r /\
				     r<>HH.root /\
				     r `is_in` h.h})
   : Lemma (HH.disjoint h.tip r)
   = ()
   
////////////////////////////////////////////////////////////////////////////////
#set-options "--initial_fuel 0 --max_fuel 0"
let f (a:Type0) (b:Type0) (x:reference a) (x':reference a) 
			  (y:reference b) (z:reference nat) 
			  (h0:mem) (h1:mem) = 
  assume (h0 `contains` x);
  assume (h0 `contains` x');  
  assume (~ (as_ref x == as_ref x'));
  assume (x.id == x'.id);
  assume (x.id <> y.id);
  assume (x.id <> z.id);
  assume (mods [Ref x; Ref y; Ref z] h0 h1);
 //--------------------------------------------------------------------------------
  assert (modifies (Set.union (Set.singleton x.id)
			      (Set.union (Set.singleton y.id)
					 (Set.singleton z.id))) h0 h1);
  assert (sel h0 x' == sel h1 x');
  assert (modifies_ref x.id (TSet.singleton (as_aref x)) h0 h1)

(* let f2 (a:Type0) (b:Type0) (x:reference a) (y:reference b) *)
(* 			   (h0:mem) (h1:mem) =  *)
(*   assume (HH.disjoint (frameOf x) (frameOf y)); *)
(*   assume (mods [Ref x; Ref y] h0 h1); *)
(*  //-------------------------------------------------------------------------------- *)
(*   assert (modifies_ref x.id (TSet.singleton (as_aref x)) h0 h1) *)

(* let rec modifies_some_refs (i:some_refs) (rs:some_refs) (h0:mem) (h1:mem) : GTot Type0 = *)
(*   match i with *)
(*   | [] -> True *)
(*   | Ref x::tl -> *)
(*     let r = x.id in *)
(*     (modifies_ref r (normalize_term (refs_in_region r rs)) h0 h1 /\ *)
(*      modifies_some_refs tl rs h0 h1) *)

(* unfold let mods_2 (rs:some_refs) h0 h1 = *)
(*     modifies (normalize_term (regions_of_some_refs rs)) h0 h1 *)
(*   /\ modifies_some_refs rs rs h0 h1 *)

(* #reset-options "--log_queries --initial_fuel 0 --max_fuel 0 --initial_ifuel 0 --max_ifuel 0" *)
(* #set-options "--debug FStar.HyperStack --debug_level print_normalized_terms" *)
(* let f3 (a:Type0) (b:Type0) (x:reference a) *)
(* 			   (h0:mem) (h1:mem) =  *)
(*   assume (mods_2 [Ref x] h0 h1); *)
(*  //-------------------------------------------------------------------------------- *)
(*   assert (modifies_ref x.id (TSet.singleton (as_aref x)) h0 h1) *)

unopteq type object : Type =
| Object:
    (ty: Type) ->
    (r: reference ty) ->
    object

unfold
let objects_disjoint (o1 o2: object): Tot Type0 =
  frameOf (Object?.r o1) <> frameOf (Object?.r o2) \/
  (
    frameOf (Object?.r o1) == frameOf (Object?.r o2) /\
    ~ (as_ref (Object?.r o1) === as_ref (Object?.r o2))
  )

unfold
let object_live (m: mem) (o: object): Tot Type0 =
  contains m (Object?.r o)

unfold
let object_contains = object_live

unfold
let object_preserved (o: object) (m m': mem): Tot Type0 =
  (object_live m o ==> (object_live m' o /\ sel m' (Object?.r o) == sel m (Object?.r o)))

let class': Modifies.class' u#0 u#1 mem 0 object =
  Modifies.Class
    (* heap  *)                 mem
    (* level *)                 0
    (* carrier *)               object
    (* disjoint *)              objects_disjoint
    (* live *)                  object_live
    (* contains *)              object_contains
    (* preserved *)             object_preserved
    (* ancestor_count *)        (fun x -> 0)
    (* ancestor_types *)        (fun x y -> false_elim ())
    (* ancestor_class_levels *) (fun x y -> false_elim ())
    (* ancestor_classes *)      (fun x y -> false_elim ())
    (* ancestor_objects *)      (fun x y -> false_elim ())

abstract
let class_invariant
  ()
: Lemma
  (requires True)
  (ensures (Modifies.class_invariant class' class'))
  [SMTPat (Modifies.class_invariant class' class')]
= let s: Modifies.class_invariant_body u#0 u#1 class' class' = {
    Modifies.preserved_refl =  (fun _ _ -> ());
    Modifies.preserved_trans = (fun _ _ _ _ -> ());
    Modifies.preserved_ancestors_preserved = begin
      let g
        (x: object)
	(h: mem)
	(h' : mem)
	(s: squash (Modifies.Class?.ancestor_count class' x > 0))
	(f: (
	  (i: nat { i < Modifies.Class?.ancestor_count class' x } ) ->
	  Lemma
	  (Modifies.Class?.preserved (Modifies.Class?.ancestor_classes class' x i) (Modifies.ancestor_objects class' x i) h h')
	))
      : Lemma
	(ensures (Modifies.Class?.preserved class' x h h'))
      = ()
      in
      g
    end;
    Modifies.class_disjoint_sym = (fun _ _ -> ());
    Modifies.level_0_class_eq_root = ();
    Modifies.level_0_fresh_disjoint = (fun _ _ _ _ -> ());
    Modifies.preserved_live = (fun _ _ _ -> ());
    Modifies.preserved_contains = (fun _ _ _ -> ());
    Modifies.live_contains = (fun _ _ -> ());
    Modifies.ancestors_contains = begin
      let g
	(h: mem)
	(o: object)
	(s: squash (Modifies.Class?.ancestor_count class' o > 0))
	(f: (
	  (i: nat {i < Modifies.Class?.ancestor_count class' o } ) ->
	  Lemma
	  (Modifies.Class?.contains (Modifies.Class?.ancestor_classes class' o i) h (Modifies.ancestor_objects class' o i))
	))
      : Lemma
	(ensures (Modifies.Class?.contains class' h o))
      = ()
      in
      g
    end;
    Modifies.live_ancestors = (fun _ _ _ -> ());
  }
  in
  (Modifies.class_invariant_intro s)

let class: Modifies.class class' 0 object = class'

let class_eq
  ()
: Lemma
  (requires True)
  (ensures (class == class'))
  [SMTPatOr [[SMTPat class]; [SMTPat class']]]
= ()

let singleton
  (#t: Type)
  (r: reference t)
: Tot (TSet.set (Modifies.object class))
= Modifies.singleton class (Object t r)

assume val whole_region (r: rid): Tot (TSet.set (Modifies.object class))

assume val mem_whole_region
  (r: rid)
  (o: Modifies.object class)
: Lemma
  (requires True)
  (ensures (TSet.mem o (whole_region r) <==> (
    Modifies.Object?.ty o == object /\
    Modifies.Object?.level o == 0 /\
    Modifies.Object?.class o == class' /\ (
    let (o': object) = Modifies.Object?.obj o in (frameOf (Object?.r o') == r)
  ))))
  [SMTPat (TSet.mem o (whole_region r))]

let singleton_subset_whole_region
  (#t: Type)
  (reg: rid)
  (ref: reference t)
: Lemma
  (requires (frameOf ref == reg))
  (ensures (singleton ref `TSet.subset` whole_region reg))
  [SMTPatOr [[SMTPatT (frameOf ref == reg)]; [SMTPat (singleton ref `TSet.subset` whole_region reg)]]]
= ()

let singleton_inter_whole_region
  (#t: Type)
  (reg: rid)
  (ref: reference t)
: Lemma
  (requires (~ (frameOf ref == reg)))
  (ensures ((singleton ref `TSet.intersect` whole_region reg) `TSet.subset` TSet.empty))
  [SMTPatOr [[SMTPatT (~ (frameOf ref == reg))]; [SMTPat (singleton ref `TSet.intersect` whole_region reg)]]]
= ()

private let test
  (#t1 #t2: Type)
  (reg: rid)
  (r1: reference t1)
  (r2: reference t2)
  (h1 h2 h3: mem)
: Lemma
  (requires (Modifies.modifies u#0 u#1 (singleton r1) h1 h2 /\ Modifies.modifies u#0 u#1 (singleton r2) h2 h3 /\ frameOf r1 == reg /\ frameOf r2 == reg))
  (ensures (Modifies.modifies u#0 u#1 (whole_region reg) h1 h3))
= ()
