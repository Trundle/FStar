// with: --include ulib --include ulib/hyperstack

module FStar.Pointer

module DM = FStar.DependentMap
module HH = FStar.HyperHeap
module HS = FStar.HyperStackNG
module HST = FStar.ST

type array (length: UInt32.t) (t: Type) = (s: Seq.seq t {Seq.length s == UInt32.v length})

noeq private type step: (from: Type) -> (to: Type) -> Tot Type =
  | StepField:
    (key: eqtype) ->
    (value: ((k: key) -> Tot Type)) ->
    (fd: key) ->
    step (DM.t key value) (value fd)
  | StepCell:
    (length: UInt32.t) ->
    (value: Type) ->
    (index: UInt32.t { UInt32.v index < UInt32.v length } ) ->
    step (array length value) value

noeq private type path (from: Type) : (to: Type) -> Tot Type =
  | PathBase:
    path from from
  | PathStep:
    (through: Type) ->
    (to: Type) ->
    (p: path from through) ->
    (s: step through to) ->
    path from to

private let rec path_sel
  (#from: Type)
  (#to: Type)
  (m: from)
  (p: path from to)
: Tot to
= match p with
  | PathBase -> m
  | PathStep through' to' p' s ->
    let (m': through') = path_sel m p' in
    begin match s with
    | StepField key value fd ->
      let (m': DM.t key value) = m' in
      DM.sel m' fd
    | StepCell length value i -> Seq.index m' (UInt32.v i) 
    end

private let rec path_upd
  (#from: Type)
  (#to: Type)
  (m: from)
  (p: path from to)
  (v: to)
: Tot from
= match p with
  | PathBase -> v
  | PathStep through' to' p' st ->
    let (s: through') = path_sel m p' in
    let (s': through') = match st with
    | StepField key value fd ->
      let (s: DM.t key value) = s in
      DM.upd s fd v
    | StepCell length value i ->
      Seq.upd s (UInt32.v i) v
    in
    path_upd m p' s'

private let rec path_sel_upd_same
  (#from: Type)
  (#to: Type)
  (m: from)
  (p: path from to)
  (v: to)
: Lemma
  (requires True)
  (ensures (path_sel (path_upd m p v) p == v))
  [SMTPat (path_sel (path_upd m p v) p)]
= match p with
  | PathBase -> ()
  | PathStep through' to' p' st ->
    let (s: through') = path_sel m p' in
    let (s': through') = match st with
    | StepField key value fd ->
      let (s: DM.t key value) = s in
      let _ = DM.sel_upd_same s fd v in
      DM.upd s fd v
    | StepCell length value i ->
      let s' = Seq.upd s (UInt32.v i) v in
      Seq.lemma_index_upd1 s (UInt32.v i) v;
      s'
    in
    path_sel_upd_same m p' s'

private let rec path_concat
  (#from: Type)
  (#through: Type)
  (#to: Type)
  (p: path from through)
  (q: path through to)
: Pure (path from to)
  (requires True)
  (ensures (fun _ -> True))
  (decreases q)
= match q with
  | PathBase -> p
  | PathStep through' to' q' st -> PathStep through' to' (path_concat p q') st

private let path_concat_base_r
  (#from: Type)
  (#to: Type)
  (p: path from to)
: Lemma
  (ensures (path_concat p PathBase == p))
= ()

private let rec path_concat_base_l
  (#from: Type)
  (#to: Type)
  (p: path from to)
: Lemma
  (requires True)
  (ensures (path_concat PathBase p == p))
  [SMTPat (path_concat PathBase p)]
= match p with
  | PathBase -> ()
  | PathStep _ _ p' _ -> path_concat_base_l p'

private let rec path_concat_assoc
  (#t0 #t1 #t2 #t3: Type)
  (p01: path t0 t1)
  (p12: path t1 t2)
  (p23: path t2 t3)
: Lemma
  (requires True)
  (ensures (path_concat (path_concat p01 p12) p23 == path_concat p01 (path_concat p12 p23)))
  (decreases p23)
= match p23 with
  | PathBase -> ()
  | PathStep _ _ p23' _ -> path_concat_assoc p01 p12 p23'

private let rec path_sel_concat
  (#from: Type)
  (#through: Type)
  (#to: Type)
  (m: from)
  (p: path from through)
  (q: path through to)
: Lemma
  (requires True)
  (ensures (path_sel m (path_concat p q) == path_sel (path_sel m p) q))
  (decreases q)
  [SMTPat (path_sel m (path_concat p q))]
= match q with
  | PathBase -> ()
  | PathStep _ _ q' _ -> path_sel_concat m p q'

private let rec path_upd_concat
  (#from: Type)
  (#through: Type)
  (#to: Type)
  (m: from)
  (p: path from through)
  (q: path through to)
  (v: to)
: Lemma
  (requires True)
  (ensures (path_upd m (path_concat p q) v == path_upd m p (path_upd (path_sel m p) q v)))
  (decreases q)
  [SMTPat (path_upd m (path_concat p q) v)]
= match q with
  | PathBase -> ()
  | PathStep through' to' q' st ->
    let (s: through') = path_sel m (path_concat p q') in
    let (s': through') = match st with
    | StepField key value fd ->
      let (s:DM.t key value) = s in
      DM.upd s fd v
    | StepCell length value i ->
      Seq.upd s (UInt32.v i) v
    in
    path_upd_concat m p q' s'

// TODO: rename as: prefix_of; use infix notation (p1 `prefix_of` p2)
private let rec path_includes
  (#from: Type)
  (#to1 #to2: Type)
  (p1: path from to1)
  (p2: path from to2)
: Ghost Type0
  (requires True)
  (ensures (fun _ -> True))
  (decreases p2)
= (to1 == to2 /\ p1 == p2) \/ (match p2 with
  | PathBase -> False
  | PathStep _ _ p2' _ ->
    path_includes p1 p2'
  )

private let rec path_includes_base
  (#from: Type)
  (#to: Type)
  (p: path from to)
: Lemma
  (requires True)
  (ensures (path_includes (PathBase #from) p))
  [SMTPat (path_includes PathBase p)]
= match p with
  | PathBase -> ()
  | PathStep _ _ p2' _ -> path_includes_base p2'

private let path_includes_refl
  (#from #to: Type)
  (p: path from to)
: Lemma
  (requires True)
  (ensures (path_includes p p))
  [SMTPat (path_includes p p)]
= ()

private let path_includes_step_r
  (#from #through #to: Type)
  (p: path from through)
  (s: step through to)
: Lemma
  (requires True)
  (ensures (path_includes p (PathStep through to p s)))
  [SMTPat (path_includes p (PathStep through to p s))]
= ()

private let rec path_includes_trans
  (#from #to1 #to2 #to3: Type)
  (p1: path from to1)
  (p2: path from to2)
  (p3: path from to3  {path_includes p1 p2 /\ path_includes p2 p3})
: Lemma
  (requires True)
  (ensures (path_includes p1 p3))
  (decreases p3)
= FStar.Classical.or_elim
    #(to2 == to3 /\ p2 == p3)
    #(match p3 with
      | PathBase -> False
      | PathStep _ _ p3' _ ->
	path_includes p2 p3')
    #(fun _ -> path_includes p1 p3)
    (fun _ -> ())
    (fun _ -> match p3 with
      | PathBase -> assert False
      | PathStep _ _ p3' _ ->
	path_includes_trans p1 p2 p3'
    )

private let rec path_includes_ind
  (#from: Type)
  (x: (#to1: Type) ->
      (#to2: Type) ->
      (p1: path from to1) ->
      (p2: path from to2 {path_includes p1 p2} ) ->
      GTot Type0)
  (h_step:
    (#through: Type) ->
    (#to: Type) ->
    (p: path from through) ->
    (s: step through to { path_includes p (PathStep through to p s) } ) ->
    Lemma (x p (PathStep through to p s)))
  (h_refl:
    (#to: Type) ->
    (p: path from to {path_includes p p}) ->
    Lemma (x p p))
  (h_trans:
    (#to1: Type) ->
    (#to2: Type) ->
    (#to3: Type) ->
    (p1: path from to1) ->
    (p2: path from to2) ->
    (p3: path from to3 {path_includes p1 p2 /\ path_includes p2 p3 /\ path_includes p1 p3 /\ x p1 p2 /\ x p2 p3}) ->
    Lemma (x p1 p3))
  (#to1: Type)
  (#to2: Type)
  (p1: path from to1)
  (p2: path from to2 {path_includes p1 p2})
: Lemma
  (requires True)
  (ensures (x p1 p2))
  (decreases p2)
= FStar.Classical.or_elim
    #(to1 == to2 /\ p1 == p2)
    #(match p2 with
      | PathBase -> False
      | PathStep _ _  p' _ -> path_includes p1 p')
    #(fun _ -> x p1 p2)
    (fun _ -> h_refl p1)
    (fun _ -> match p2 with
     | PathBase -> assert False
     | PathStep _ _  p2' st ->
       let _ = path_includes_ind x h_step h_refl h_trans p1 p2' in
       let _ = path_includes_step_r p2' st in
       let _ = h_step p2' st in
       h_trans p1 p2' p2
    )

private let rec path_length
  (#from #to: Type)
  (p: path from to)
: Tot nat
= match p with
  | PathBase -> 0
  | PathStep _ _ p' _ -> 1 + path_length p'

private let path_includes_length
  (#from: Type)
  (#to1 #to2: Type)
  (p1: path from to1)
  (p2: path from to2 {path_includes p1 p2})
: Lemma
  (ensures (path_length p1 <= path_length p2))
= path_includes_ind
    (fun #to1_ #to2_ p1_ p2_ -> path_length p1_ <= path_length p2_)
    (fun #through #to p st -> ())
    (fun #to p -> ())
    (fun #to1_ #to2_ #to3_ p1_ p2_ p3_ -> ())
    p1 p2

private let path_includes_step_l
  (#from: Type)
  (#through: Type)
  (#to: Type)
  (p: path from through)
  (s: step through to)
: Lemma
  (requires True)
  (ensures (~ (path_includes (PathStep through to p s) p)))
  [SMTPat (path_includes (PathStep through to p s) p)]
= assert (path_length (PathStep through to p s) > path_length p);
  FStar.Classical.forall_intro (path_includes_length #from #to #through (PathStep through to p s))

private let rec path_includes_concat
  (#from: Type)
  (#through: Type)
  (#to: Type)
  (p: path from through)
  (q: path through to)
: Lemma
  (requires True)
  (ensures (path_includes p (path_concat p q)))
  (decreases q)
  [SMTPat (path_includes p (path_concat p q))]
= match q with
  | PathBase -> ()
  | PathStep _ _ q' _ -> path_includes_concat p q'

private let path_includes_exists_concat
  (#from #through: Type)
  (p: path from through)
  (#to: Type)
  (q: path from to { path_includes p q } )
: Lemma
  (ensures (exists (r: path through to) . q == path_concat p r))
= path_includes_ind
    (fun #to1_ #to2_ p1_ p2_ -> exists r . p2_ == path_concat p1_ r)
    (fun #through #to_ p s -> FStar.Classical.exists_intro (fun r -> PathStep through to_ p s == path_concat p r) (PathStep through to_ PathBase s))
    (fun #to p -> FStar.Classical.exists_intro (fun r -> p == path_concat p r) PathBase)
    (fun #to1_ #to2_ #to3_ p1_ p2_ p3_ ->
      FStar.Classical.exists_elim  (exists r . p3_ == path_concat p1_ r) #_ #(fun r12 -> p2_ == path_concat p1_ r12) () (fun r12 ->
	FStar.Classical.exists_elim (exists r . p3_ == path_concat p1_ r) #_ #(fun r23 -> p3_ == path_concat p2_ r23) () (fun r23 ->
	  path_concat_assoc p1_ r12 r23;
	  FStar.Classical.exists_intro (fun r -> p3_ == path_concat p1_ r) (path_concat r12 r23)
	)
      )
    )
    p q
  
let step_disjoint
  (#from: Type)
  (#to1 #to2: Type)
  (s1: step from to1)
  (s2: step from to2)
: GTot Type0
= match s1 with
  | StepField key1 value1 fd1 ->
    begin match s2 with
    | StepField key2 value2 fd2 ->
      key1 == key2 /\ value1 == value2 /\ fd1 <> fd2
    | _ -> False
    end
  | StepCell length1 value1 i1 ->
    begin match s2 with
    | StepCell length2 value2 i2 -> length1 == length2 /\ value1 == value2 /\ UInt32.v i1 <> UInt32.v i2
    | _ -> False
    end

let step_disjoint_sym
  (#from: Type)
  (#to1 #to2: Type)
  (s1: step from to1)
  (s2: step from to2)
: Lemma
  (requires (step_disjoint s1 s2))
  (ensures (step_disjoint s2 s1))
= ()

noeq private type path_disjoint_t (#from: Type):
  (#to1: Type) ->
  (#to2: Type) ->
  (p1: path from to1) ->
  (p2: path from to2) ->
  Type
= | PathDisjointStep:
    (#through: Type) ->
    (#to1: Type) ->
    (#to2: Type) ->
    (p: path from through) ->
    (s1: step through to1) ->
    (s2: step through to2 { step_disjoint s1 s2 } ) ->
    path_disjoint_t (PathStep through to1 p s1) (PathStep through to2 p s2)
  | PathDisjointIncludes:
    (#to1: Type) ->
    (#to2: Type) ->
    (p1: path from to1) ->
    (p2: path from to2) ->
    (#to1': Type) ->
    (#to2': Type) ->
    (p1': path from to1' {path_includes p1 p1'}) ->
    (p2': path from to2' {path_includes p2 p2'}) ->
    path_disjoint_t p1 p2 ->
    path_disjoint_t p1' p2'

private let rec path_disjoint_t_rect
  (#from: Type)
  (x:
    (#value1: Type) ->
    (#value2: Type) ->
    (p1: path from value1) ->
    (p2: path from value2) ->
    (h: path_disjoint_t p1 p2) ->
    GTot Type)
  (h_step:
    (#through: Type) ->
    (#to1: Type) ->
    (#to2: Type) ->
    (p: path from through) ->
    (s1: step through to1) ->
    (s2: step through to2 { step_disjoint s1 s2 } ) ->
    (h: path_disjoint_t (PathStep through to1 p s1) (PathStep through to2 p s2)) ->
    GTot (x (PathStep through to1 p s1) (PathStep through to2 p s2) h))
  (h_includes:
    (#value1: Type) ->
    (#value2: Type) ->
    (p1: path from value1) ->
    (p2: path from value2) ->
    (#value1': Type) ->
    (#value2': Type) ->
    (p1': path from value1' {path_includes p1 p1'}) ->
    (p2': path from value2' {path_includes p2 p2'}) ->
    (h: path_disjoint_t p1 p2) ->
    (h': path_disjoint_t p1' p2') ->
    (ihx: x p1 p2 h) ->
    GTot (x p1' p2' h'))
  (#value1: Type)
  (#value2: Type)
  (p1: path from value1)
  (p2: path from value2)
  (h: path_disjoint_t p1 p2)
: Ghost (x p1 p2 h)
  (requires True)
  (ensures (fun _ -> True))
  (decreases h)
= match h with
  | PathDisjointStep p s1 s2 -> h_step p s1 s2 h
  | PathDisjointIncludes p1_ p2_ p1' p2' h_ -> h_includes p1_ p2_ p1' p2' h_ h (path_disjoint_t_rect x h_step h_includes p1_ p2_ h_)
  
private let path_disjoint
  (#from: Type)
  (#value1: Type)
  (#value2: Type)
  (p1: path from value1)
  (p2: path from value2)
: GTot Type0
= squash (path_disjoint_t p1 p2)

abstract let path_disjoint_ind
  (#from: Type)
  (x:
    (#value1: Type) ->
    (#value2: Type) ->
    (p1: path from value1) ->
    (p2: path from value2 {path_disjoint p1 p2} ) ->
    GTot Type0)
  (h_step:
    (#through: Type) ->
    (#to1: Type) ->
    (#to2: Type) ->
    (p: path from through) ->
    (s1: step through to1) ->
    (s2: step through to2 { step_disjoint s1 s2 /\ path_disjoint (PathStep through to1 p s1) (PathStep through to2 p s2) } ) ->
    Lemma (x (PathStep through to1 p s1) (PathStep through to2 p s2) ))
  (h_includes:
    (#value1: Type) ->
    (#value2: Type) ->
    (p1: path from value1) ->
    (p2: path from value2) ->
    (#value1': Type) ->
    (#value2': Type) ->
    (p1': path from value1' {path_includes p1 p1'}) ->
    (p2': path from value2' {path_includes p2 p2' /\ path_disjoint p1 p2 /\ path_disjoint p1' p2' /\ x p1 p2}) ->
    Lemma (x p1' p2'))
  (#value1: Type)
  (#value2: Type)
  (p1: path from value1)
  (p2: path from value2 { path_disjoint p1 p2 } )
: Lemma (x p1 p2)
= let h : squash (path_disjoint_t p1 p2) = FStar.Squash.join_squash () in
  FStar.Squash.bind_squash h (fun (h: path_disjoint_t p1 p2) ->
   path_disjoint_t_rect
     (fun #v1 #v2 p1 p2 h -> let _ = FStar.Squash.return_squash h in squash (x p1 p2))
     (fun #through #to1 #to2 p s1 s2 h -> let _ = FStar.Squash.return_squash h in h_step p s1 s2)
     (fun #v1 #v2 p1 p2 #v1' #v2' p1' p2' h h' hx ->
       let _ = FStar.Squash.return_squash h in
       let _ = FStar.Squash.return_squash h' in
       let _ = FStar.Squash.return_squash hx in
       h_includes p1 p2 p1' p2')
     p1 p2 h)

private let path_disjoint_step
  (#from: Type)
  (#through: Type)
  (#to1: Type)
  (#to2: Type)
  (p: path from through)
  (s1: step through to1)
  (s2: step through to2 { step_disjoint s1 s2 } ) 
: Lemma
  (requires True)
  (ensures (path_disjoint (PathStep through to1 p s1) (PathStep through to2 p s2)))
  [SMTPat (path_disjoint (PathStep through to1 p s1) (PathStep through to2 p s2))]
= FStar.Squash.return_squash (PathDisjointStep p s1 s2)

private let path_disjoint_includes
  (#from: Type)
  (#to1: Type)
  (#to2: Type)
  (p1: path from to1)
  (p2: path from to2)
  (#to1': Type)
  (#to2': Type)
  (p1': path from to1')
  (p2': path from to2' {path_disjoint p1 p2 /\ path_includes p1 p1' /\ path_includes p2 p2'} )
: Lemma
  (ensures (path_disjoint p1' p2'))
= let h : squash (path_disjoint_t p1 p2) = FStar.Squash.join_squash () in
  FStar.Squash.bind_squash h (fun h -> FStar.Squash.return_squash (PathDisjointIncludes p1 p2 p1' p2' h))

let rec path_disjoint_sym
  (#from: Type)
  (#value1: Type)
  (#value2: Type)
  (p1: path from value1)
  (p2: path from value2)
: Lemma
  (requires (path_disjoint p1 p2))
  (ensures (path_disjoint p2 p1))
= path_disjoint_ind
  (fun #v1 #v2 p1 p2 -> path_disjoint p2 p1)
  (fun #through #to1 #to2 p s1 s2 -> path_disjoint_step p s2 s1)
  (fun #v1 #v2 p1 p2 #v1' #v2' p1' p2' -> path_disjoint_includes p2 p1 p2' p1')
  p1 p2

private let path_sel_upd_other
  (#from: Type)
  (#to1 #to2: Type)
  (p1: path from to1)
  (p2: path from to2 {path_disjoint p1 p2})
: Lemma
  (ensures (forall (m: from) (v: to1) . path_sel (path_upd m p1 v) p2 == path_sel m p2))
= path_disjoint_ind
  (fun #v1 #v2 p1_ p2_ -> forall (m: from) (v: v1) . path_sel (path_upd m p1_ v) p2_ == path_sel m p2_)
  (fun #through #to1_ #to2_ p s1 s2 -> 
      FStar.Classical.forall_intro' #_ #(fun m -> forall  (v: to1_) . path_sel (path_upd m (PathStep through to1_ p s1) v) (PathStep through to2_ p s2) == path_sel m (PathStep through to2_ p s2)) (fun m ->
	  FStar.Classical.forall_intro' #_ #(fun v -> path_sel (path_upd m (PathStep through to1_ p s1) v) (PathStep through to2_ p s2) == path_sel m (PathStep through to2_ p s2)) (fun v ->
	  match s1 with
	  | StepField key1 value1 fd1 ->
	    let (StepField _ _ fd2) = s2 in
	    let (s: DM.t key1 value1) = path_sel m p in
	    path_sel_upd_same m p (DM.upd s fd1 v);
	    DM.sel_upd_other s fd1 v fd2
	  | StepCell length1 value1 i1 ->
	    let (StepCell _ _ i2) = s2 in
	    path_sel_upd_same m p (Seq.upd (path_sel m p) (UInt32.v i1) v);
	    Seq.lemma_index_upd2 (path_sel m p) (UInt32.v i1) v (UInt32.v i2)
      )))
  (fun #v1 #v2 p1 p2 #v1' #v2' p1' p2' ->
    let h1: squash (exists r1 . p1' == path_concat p1 r1) = path_includes_exists_concat p1 p1' in
    let h2: squash (exists r2 . p2' == path_concat p2 r2) = path_includes_exists_concat p2 p2' in
    FStar.Classical.forall_intro' #_ #(fun (m: from) -> forall v . path_sel (path_upd m p1' v) p2' == path_sel m p2') (fun (m: from) ->
      FStar.Classical.forall_intro' #_ #(fun (v: v1') -> path_sel (path_upd m p1' v) p2' == path_sel m p2') (fun (v: v1') ->
      FStar.Classical.exists_elim (path_sel (path_upd m p1' v) p2' == path_sel m p2') h1 (fun r1 ->
	FStar.Classical.exists_elim (path_sel (path_upd m p1' v) p2' == path_sel m p2') h2 (fun r2 ->
	  path_upd_concat m p1 r1 v;
	  path_sel_concat m p2 r2
	  )))))
  p1 p2

private let path_sel_upd_other'
  (#from: Type)
  (#to1 #to2: Type)
  (p1: path from to1)
  (p2: path from to2 {path_disjoint p1 p2})
  (m: from)
  (v: to1)
: Lemma
  (requires True)
  (ensures (path_sel (path_upd m p1 v) p2 == path_sel m p2))
  [SMTPat (path_sel (path_upd m p1 v) p2)]
= path_sel_upd_other p1 p2

(** Pointers to data of type t *)

noeq private type _pointer : Type -> Tot Type =
  | Pointer:
    (#from: Type) ->
    (content: HS.reference from ) ->
    (#to: Type) ->
    (p: path from to) ->
    _pointer to
abstract let pointer (t: Type): Tot Type =
  _pointer t

abstract let as_aref (#t: Type) (p: pointer t): GTot Heap.aref =
  HS.as_aref (Pointer?.content p)

private let _field
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: pointer (DM.t key value))
  (fd: key)
: Tot (pointer (value fd))
= let (Pointer #from content p') = p in
  let p' : path from (DM.t key value) = p' in
  let p'' : path from (value fd) = PathStep _ _ p' (StepField _ _ fd) in
  Pointer content p''

private let _cell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Tot (pointer value)
= let (Pointer #from content p') = p in
  let p' : path from (array length value) = p' in
  let p'' : path from value = PathStep _ _ p' (StepCell _ _ i) in
  Pointer content p''

abstract let contains
  (#value: Type)
  (h: HS.mem)
  (p: pointer value)
: GTot Type0
= HS.contains h (Pointer?.content p)

abstract let live
  (#value: Type)
  (h: HS.mem)
  (p: pointer value)
: GTot Type0
= HS.contains h (Pointer?.content p)

abstract let live_contains
  (#value: Type)
  (h: HS.mem)
  (p: pointer value)
: Lemma
  (requires (live h p))
  (ensures (contains h p))
  [SMTPatT (live h p)]
= () 

abstract let gread
  (#value: Type)
  (h: HS.mem)
  (p: pointer value) 
: GTot value
= let (Pointer content p') = p in
  path_sel (HS.sel h content) p'

abstract let frameOf 
  (#value: Type)
  (p: pointer value)
: Tot HH.rid
= HS.frameOf (Pointer?.content p)

abstract let disjoint_roots_intro_pointer_vs_pointer
  (#value1 value2: Type)
  (h: HS.mem)
  (p1: pointer value1)
  (p2: pointer value2)
: Lemma
  (requires (contains h p1 /\ (~ (contains h p2))))
  (ensures (frameOf p1 <> frameOf p2 \/ as_aref p1 =!= as_aref p2))
= HS.lemma_live_1 h (Pointer?.content p1) (Pointer?.content p2)

abstract let disjoint_roots_intro_pointer_vs_reference
  (#value1 value2: Type)
  (h: HS.mem)
  (p1: pointer value1)
  (p2: HS.reference value2)
: Lemma
  (requires (contains h p1 /\ (~ (HS.contains h p2))))
  (ensures (frameOf p1 <> p2.HS.id \/ as_aref p1 =!= HS.as_aref p2))
= HS.lemma_live_1 h (Pointer?.content p1) p2

abstract let disjoint_roots_intro_reference_vs_pointer
  (#value1 value2: Type)
  (h: HS.mem)
  (p1: HS.reference value1)
  (p2: pointer value2)
: Lemma
  (requires (HS.contains h p1 /\ (~ (contains h p2))))
  (ensures (p1.HS.id <> frameOf p2 \/ HS.as_aref p1 =!= as_aref p2))
= HS.lemma_live_1 h p1 (Pointer?.content p2)

let memory_managed
  (#value: Type)
  (p: pointer value)
: GTot bool
= (Pointer?.content p).HS.mm

abstract let recall
  (#value: Type)
  (p: pointer value {HS.is_eternal_region (frameOf p) && not (memory_managed p)})
: HST.Stack unit
  (requires (fun m -> True))
  (ensures (fun m0 _ m1 -> m0 == m1 /\ live m1 p))
= HST.recall (Pointer?.content p)

(* Equality predicate on struct contents, without quantifiers *)
let equal_values #a h (b:pointer a) h' (b':pointer a) : GTot Type0 =
  live h b /\ live h' b' /\ gread h b == gread h' b'

abstract let includes
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2)
: GTot Type0
= Pointer?.from p1 == Pointer?.from p2 /\ Pointer?.content p1 == Pointer?.content p2 /\ path_includes (Pointer?.p p1) (Pointer?.p p2)

#reset-options "--z3rlimit 16"

abstract let gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: pointer (DM.t key value))
  (fd: key)
: GTot (p' : pointer (value fd) { includes p p' } )
= _field p fd

abstract let as_aref_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: (pointer (DM.t key value)))
  (fd: key)
: Lemma
  (requires True)
  (ensures (as_aref (gfield p fd) == as_aref p))
  [SMTPat (as_aref (gfield p fd))]
= ()

abstract let contains_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (h: HS.mem)
  (p: (pointer (DM.t key value)))
  (fd: key)
: Lemma
  (requires True)
  (ensures (contains h (gfield p fd) <==> contains h p))
  [SMTPat (contains h (gfield p fd))]
= ()

abstract let live_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (h: HS.mem)
  (p: pointer (DM.t key value))
  (fd: key)
: Lemma
  (requires True)
  (ensures (live h (gfield p fd) <==> live h p))
  [SMTPat (live h (gfield p fd))]
= ()

abstract let gread_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (h: HS.mem)
  (p: pointer (DM.t key value))
  (fd: key)
: Lemma
  (requires True)
  (ensures (gread h (gfield p fd) == DM.sel (gread h p) fd))
  [SMTPat (gread h (gfield p fd))]
= ()

abstract let frameOf_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: pointer (DM.t key value))
  (fd: key)
: Lemma
  (requires True)
  (ensures (frameOf (gfield p fd) == frameOf p))
  [SMTPat (frameOf (gfield p fd))]
= ()

abstract let memory_managed_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: pointer (DM.t key value))
  (fd: key)
: Lemma
  (requires True)
  (ensures (memory_managed (gfield p fd) <==> memory_managed p))
  [SMTPat (memory_managed (gfield p fd))]
= ()

abstract let includes_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: pointer (DM.t key value))
  (fd: key)
: Lemma
  (requires True)
  (ensures (includes p (gfield p fd)))
  [SMTPat (includes p (gfield p fd))]
= ()

abstract let gcell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Tot (pointer value)
= _cell p i

abstract let as_aref_gcell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Lemma
  (requires True)
  (ensures (as_aref (gcell p i) == as_aref p))
  [SMTPat (as_aref (gcell p i))]
= ()

abstract let contains_gcell
  (#length: UInt32.t)
  (#value: Type)
  (h: HS.mem)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Lemma
  (requires True)
  (ensures (contains h (gcell p i) <==> contains h p))
  [SMTPat (contains h (gcell p i))]
= ()

abstract let live_gcell
  (#length: UInt32.t)
  (#value: Type)
  (h: HS.mem)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Lemma
  (requires True)
  (ensures (live h (gcell p i) <==> live h p))
  [SMTPat (live h (gcell p i))]
= ()

abstract let gread_gcell
  (#length: UInt32.t)
  (#value: Type)
  (h: HS.mem)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Lemma
  (requires True)
  (ensures (gread h (gcell p i) == Seq.index (gread h p) (UInt32.v i)))
  [SMTPat (gread h (gcell p i))]
= ()

abstract let frameOf_gcell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Lemma
  (requires True)
  (ensures (frameOf (gcell p i) == frameOf p))
  [SMTPat (frameOf (gcell p i))]
= ()

abstract let memory_managed_gcell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Lemma
  (requires True)
  (ensures (memory_managed (gcell p i) == memory_managed p))
  [SMTPat (memory_managed (gcell p i))]
= ()

abstract let includes_gcell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
: Lemma
  (requires True)
  (ensures (includes p (gcell p i)))
  [SMTPat (includes p (gcell p i))]
= ()

abstract let includes_refl
  (#value: Type)
  (p: pointer value)
: Lemma
  (requires True)
  (ensures (includes p p))
  [SMTPat (includes p p)]
= ()

abstract let includes_trans
  (#value1 #value2 #value3: Type)
  (p1: pointer value1)
  (p2: pointer value2)
  (p3: pointer value3)
: Lemma
  (requires (includes p1 p2 /\ includes p2 p3))
  (ensures (includes p1 p3))
  [SMTPatT (includes p1 p2); SMTPatT (includes p2 p3)]
= path_includes_trans (Pointer?.p p1) (Pointer?.p p2) (Pointer?.p p3)

abstract let includes_ind
  (x: (#value1: Type) ->
      (#value2: Type) ->
      (p1: pointer value1) ->
      (p2: pointer value2 {includes p1 p2} ) ->
      GTot Type0)
  (h_field:
    (#key: eqtype) ->
    (#value: (key -> Tot Type)) ->
    (p: pointer (DM.t key value)) ->
    (fd: key {includes p (gfield p fd)}) ->
    Lemma (x p (gfield p fd)))
  (h_cell:
    (#length: UInt32.t) ->
    (#value: Type) ->
    (p: pointer (array length value)) ->
    (i: UInt32.t {UInt32.v i < UInt32.v length /\ includes p (gcell p i)}) ->
    Lemma (x p (gcell p i)))
  (h_refl:
    (#value: Type) ->
    (p: pointer value {includes p p}) ->
    Lemma (x p p))
  (h_trans:
    (#value1: Type) ->
    (#value2: Type) ->
    (#value3: Type) ->
    (p1: pointer value1) ->
    (p2: pointer value2) ->
    (p3: pointer value3 {includes p1 p2 /\ includes p2 p3 /\ includes p1 p3 /\ x p1 p2 /\ x p2 p3}) ->
    Lemma (x p1 p3))
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2 {includes p1 p2})
: Lemma (x p1 p2)
= let from : Type = Pointer?.from p1 in
  let content : HS.reference from = Pointer?.content p1 in
  path_includes_ind
    (fun #to1 #to2 p1_ p2_ -> x (Pointer content p1_) (Pointer content p2_))
    (fun #through #to p s ->
      match s with
      | StepField key value fd -> let (pt: pointer (DM.t key value)) = (Pointer content p) in h_field pt fd
      | StepCell length value i -> let (pt: pointer (array length value)) = (Pointer content p) in h_cell pt i
    )
    (fun #to p -> h_refl (Pointer content p))
    (fun #to1 #to2 #to3 p1_ p2_ p3_ -> h_trans (Pointer content p1_) (Pointer content p2_) (Pointer content p3_))
    (Pointer?.p p1)
    (Pointer?.p p2)

let contains_includes
  (#value1: Type)
  (#value2: Type)
  (h: HS.mem)
  (p1: pointer value1)
  (p2: pointer value2)
: Lemma
  (requires (includes p1 p2))
  (contains h p1 <==> contains h p2)
  [SMTPatT (contains h p2); SMTPatT (includes p1 p2)]
= includes_ind
  (fun #v1 #v2 p1 p2 -> contains h p1 <==> contains h p2)
  (fun #k #v p fd -> contains_gfield h p fd)
  (fun #length #value p i -> contains_gcell h p i)
  (fun #v p -> ())
  (fun #v1 #v2 #v3 p1 p2 p3 -> ())
  p1 p2

let live_includes
  (#value1: Type)
  (#value2: Type)
  (h: HS.mem)
  (p1: pointer value1)
  (p2: pointer value2)
: Lemma
  (requires (includes p1 p2))
  (ensures (live h p1 <==> live h p2))
  [SMTPatT (live h p2); SMTPatT (includes p1 p2)]
= includes_ind
  (fun #v1 #v2 p1 p2 -> live h p1 <==> live h p2)
  (fun #k #v p fd -> live_gfield h p fd)
  (fun #length #value p i -> live_gcell h p i)  
  (fun #v p -> ())
  (fun #v1 #v2 #v3 p1 p2 p3 -> ())
  p1 p2

abstract let disjoint
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2)
: GTot Type0
= (frameOf p1 <> frameOf p2 \/ as_aref p1 =!= as_aref p2) \/ // disjoint references; see HS.lemma_live_1
  (Pointer?.from p1 == Pointer?.from p2 /\ Pointer?.content p1 == Pointer?.content p2 /\ path_disjoint (Pointer?.p p1) (Pointer?.p p2))

abstract let disjoint_root
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2)
: Lemma
  (requires (frameOf p1 <> frameOf p2 \/ as_aref p1 =!= as_aref p2))
  (ensures (disjoint p1 p2))
= ()

abstract let disjoint_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: pointer (DM.t key value))
  (fd1: key)
  (fd2: key)
: Lemma
  (requires (fd1 <> fd2))
  (ensures (disjoint (gfield p fd1) (gfield p fd2)))
  [SMTPat (disjoint (gfield p fd1) (gfield p fd2))]
= ()

abstract let disjoint_gcell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i1: UInt32.t {UInt32.v i1 < UInt32.v length})
  (i2: UInt32.t {UInt32.v i2 < UInt32.v length})  
: Lemma
  (requires (UInt32.v i1 <> UInt32.v i2))
  (ensures (disjoint (gcell p i1) (gcell p i2)))
  [SMTPat (disjoint (gcell p i1) (gcell p i2))]
= ()

abstract let disjoint_includes
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2)
  (#value1': Type)
  (#value2': Type)
  (p1': pointer value1')
  (p2': pointer value2')
: Lemma
  (requires (includes p1 p1' /\ includes p2 p2' /\ disjoint p1 p2))
  (ensures (disjoint p1' p2'))
= FStar.Classical.or_elim
    #(frameOf p1 <> frameOf p2 \/ as_aref p1 =!= as_aref p2)
    #(Pointer?.from p1 == Pointer?.from p2 /\ Pointer?.content p1 == Pointer?.content p2 /\ path_disjoint (Pointer?.p p1) (Pointer?.p p2))
    #(fun _ -> disjoint p1' p2')
    (fun h -> ())
    (fun _ -> path_disjoint_includes (Pointer?.p p1) (Pointer?.p p2) (Pointer?.p p1') (Pointer?.p p2'))

abstract let disjoint_ind
  (x:
    (#value1: Type) ->
    (#value2: Type) ->
    (p1: pointer value1) ->
    (p2: pointer value2 {disjoint p1 p2} ) ->
    GTot Type0)
  (h_root:
    (#value1: Type) ->
    (#value2: Type) ->
    (p1: pointer value1) ->
    (p2: pointer value2 { frameOf p1 <> frameOf p2 \/ as_aref p1 =!= as_aref p2 } ) ->
    Lemma (x p1 p2))
  (h_field:
    (#key: eqtype) ->
    (#value: (key -> Tot Type)) ->
    (p: pointer (DM.t key value)) ->
    (fd1: key) ->
    (fd2: key { fd1 <> fd2 /\ disjoint (gfield p fd1) (gfield p fd2) } ) ->
    Lemma (x (gfield p fd1) (gfield p fd2)))
  (h_cell:
    (#length: UInt32.t) ->
    (#value: Type) ->
    (p: pointer (array length value)) ->
    (i1: UInt32.t {UInt32.v i1 < UInt32.v length}) ->
    (i2: UInt32.t {UInt32.v i2 < UInt32.v length /\ UInt32.v i1 <> UInt32.v i2 /\ disjoint (gcell p i1) (gcell p i2) }) ->
    Lemma (x (gcell p i1) (gcell p i2))
  )
  (h_includes:
    (#value1: Type) ->
    (#value2: Type) ->
    (p1: pointer value1) ->
    (p2: pointer value2) ->
    (#value1': Type) ->
    (#value2': Type) ->
    (p1': pointer value1' {includes p1 p1'}) ->
    (p2': pointer value2' {includes p2 p2' /\ disjoint p1 p2 /\ disjoint p1' p2' /\ x p1 p2}) ->
    Lemma (x p1' p2'))
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2 { disjoint p1 p2 } )
: Lemma (x p1 p2)
= FStar.Classical.or_elim
    #(frameOf p1 <> frameOf p2 \/ as_aref p1 =!= as_aref p2)
    #(Pointer?.from p1 == Pointer?.from p2 /\ Pointer?.content p1 == Pointer?.content p2 /\ path_disjoint (Pointer?.p p1) (Pointer?.p p2))
    #(fun _ -> x p1 p2)
    (fun _ ->
      h_root p1 p2)
    (fun _ ->
      let from: Type = Pointer?.from p1 in
      let (content1: HS.reference from ) = Pointer?.content p1 in
      let (content2: HS.reference from ) = Pointer?.content p2 in
      assert (content1 == content2);
      path_disjoint_ind
	(fun #v1 #v2 p1_ p2_ -> x (Pointer content1 p1_) (Pointer content1 p2_))
	(fun #through #to1 #to2 p s1 s2 ->
	   match s1 with
	   | StepField ke va fd1 ->
	     let (StepField _ _ fd2) = s2 in
	     h_field #ke #va (Pointer content1 p) fd1 fd2
	   | StepCell le va i1 ->
	     let (StepCell _ _ i2) = s2 in
	     h_cell #le #va (Pointer content1 p) i1 i2
	)
	(fun #v1 #v2 p1_ p2_ #v1' #v2' p1' p2' -> h_includes (Pointer content1 p1_) (Pointer content1 p2_) (Pointer content1 p1') (Pointer content1 p2'))
	(Pointer?.p p1)
	(Pointer?.p p2);
       assert (x p1 p2)
     )

let disjoint_sym
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2)
: Lemma
  (requires (disjoint p1 p2))
  (ensures (disjoint p2 p1))
= disjoint_ind
  (fun #v1 #v2 p1 p2 -> disjoint p2 p1)
  (fun #v1 #v2 p1 p2 -> disjoint_root p2 p1)
  (fun #k #v p fd1 fd2 -> disjoint_gfield p fd2 fd1)
  (fun #le #va p i1 i2 -> disjoint_gcell p i2 i1)
  (fun #v1 #v2 p1 p2 #v1' #v2' p1' p2' -> disjoint_includes p2 p1 p2' p1')
  p1 p2

let disjoint_sym'
  (#value1: Type)
  (#value2: Type)
  (p1: pointer value1)
  (p2: pointer value2)
: Lemma
  (requires True)
  (ensures (disjoint p1 p2 <==> disjoint p2 p1))
  [SMTPat (disjoint p1 p2)]
= FStar.Classical.move_requires (disjoint_sym #value1 #value2 p1) p2;
  FStar.Classical.move_requires (disjoint_sym #value2 #value1 p2) p1

let disjoint_includes_l #a #as #a' (x: pointer a) (subx:pointer as) (y:pointer a') : Lemma
  (requires (includes x subx /\ disjoint x y))
  (ensures  (disjoint subx y))
  [SMTPatT (disjoint subx y); SMTPatT (includes x subx)]
  = disjoint_includes x y subx y

let disjoint_includes_l_swap #a #as #a' (x:pointer a) (subx:pointer as) (y:pointer a') : Lemma
  (requires (includes x subx /\ disjoint x y))
  (ensures  (disjoint y subx))
  [SMTPatT (disjoint y subx); SMTPatT (includes x subx)]
  = ()

(*
let disjoint_includes_r #a #as #a' (x: pointer a) (subx:pointer as) (y:pointer a') : Lemma
  (requires (includes x subx /\ disjoint y x))
  (ensures  (disjoint y subx))
  [SMTPat (disjoint y subx); SMTPatT (includes x subx)]
  = disjoint_includes x y subx y
*)

let live_disjoint
  (#value1: Type)
  (#value2: Type)
  (h: HS.mem)
  (p1: pointer value1)
  (p2: pointer value2)
: Lemma
  (requires (live h p1 /\ ~ (contains h p2)))
  (ensures (disjoint p1 p2))
  [SMTPatT (disjoint p1 p2); SMTPatT (live h p1)]
= live_contains h p1;
  disjoint_root p1 p2


(* Specialized clauses for small numbers of pointers *)
let modifies_ptr_0 rid h h' =
  HS.modifies_ref rid !{} h h'
  /\ (forall (#tt:Type) (bb:pointer tt). (frameOf bb = rid /\ live h bb) ==> equal_values h bb h' bb)

let modifies_ptr_1 (#t:Type) rid (b:pointer t) h h' = //would be good to drop the rid argument on these, since they can be computed from the pointers
  HS.modifies_ref rid (TSet.singleton (as_aref b)) h h'
  /\ (forall (#tt:Type) (bb:pointer tt). (frameOf bb = rid /\ live h bb /\ disjoint b bb) ==> equal_values h bb h' bb)

let modifies_ptr_0_0 rid h0 h1 h2 :
  Lemma (requires (modifies_ptr_0 rid h0 h1 /\ modifies_ptr_0 rid h1 h2))
	(ensures (modifies_ptr_0 rid h0 h2))
	[SMTPatT (modifies_ptr_0 rid h0 h1); SMTPatT (modifies_ptr_0 rid h1 h2)]
 = ()

(* Modifies clauses that do not change the shape of the HyperStack (h1.tip = h0.tip) *)
(* NB: those clauses are made abstract in order to make verification faster
   Lemmas follow to allow the programmer to make use of the real definition
   of those predicates in a general setting *)
abstract let modifies_0 h0 h1 =
  HS.modifies_one h0.HS.tip h0 h1
  /\ modifies_ptr_0 h0.HS.tip h0 h1
  /\ h0.HS.tip=h1.HS.tip

(* This one is very generic: it says
 * - some references have changed in the frame of b, but
 * - among all pointers in this frame, b is the only one that changed. *)
abstract let modifies_1 (#a:Type) (b:pointer a) h0 h1 =
  let rid = frameOf b in
  HS.modifies_one rid h0 h1 /\ modifies_ptr_1 rid b h0 h1

(* Lemmas introducing the 'modifies' predicates *)
let modifies_0_intro h0 h1 : Lemma
  (requires (HS.modifies_one h0.HS.tip h0 h1
  /\ modifies_ptr_0 h0.HS.tip h0 h1
  /\ h0.HS.tip=h1.HS.tip))
  (ensures  (modifies_0 h0 h1))
  = ()

let modifies_1_intro (#a:Type) (b:pointer a) h0 h1 : Lemma
  (requires (let rid = frameOf b in
  HS.modifies_one rid h0 h1 /\ modifies_ptr_1 rid b h0 h1))
  (ensures  (modifies_1 b h0 h1))
  = ()

(* Lemmas revealing the content of the specialized modifies clauses in order to
   be able to generalize them if needs be. *)
let  modifies_0_reveal h0 h1 : Lemma
  (requires (modifies_0 h0 h1))
  (ensures  (HS.modifies_one h0.HS.tip h0 h1 /\ modifies_ptr_0 h0.HS.tip h0 h1 /\ h0.HS.tip=h1.HS.tip))
  = ()

let modifies_1_reveal (#a:Type) (b:pointer a) h0 h1 : Lemma
  (requires (modifies_1 b h0 h1))
  (ensures  (let rid = frameOf b in HS.modifies_one rid h0 h1 /\ modifies_ptr_1 rid b h0 h1))
  = ()

(* STStack effect specific lemmas *)
let lemma_ststack_1 (#a:Type) (b:pointer a) h0 h1 h2 h3 : Lemma
  (requires (live h0 b /\ HS.fresh_frame h0 h1 /\ modifies_1 b h1 h2 /\ HS.popped h2 h3))
  (ensures  (modifies_1 b h0 h3))
  [SMTPatT (modifies_1 b h1 h2); SMTPatT (HS.fresh_frame h0 h1); SMTPatT (HS.popped h2 h3)]
  = ()

(** Transitivity lemmas *)
let modifies_0_trans h0 h1 h2 : Lemma
  (requires (modifies_0 h0 h1 /\ modifies_0 h1 h2))
  (ensures  (modifies_0 h0 h2))
  [SMTPatT (modifies_0 h0 h1); SMTPatT (modifies_0 h1 h2)]
  = ()

let modifies_1_trans (#a:Type) (b:pointer a) h0 h1 h2 : Lemma
  (requires (modifies_1 b h0 h1 /\ modifies_1 b h1 h2))
  (ensures (modifies_1 b h0 h2))
  [SMTPatT (modifies_1 b h0 h1); SMTPatT (modifies_1 b h1 h2)]
  = ()

(* Specific modifies clause lemmas *)
val modifies_0_0: h0:HS.mem -> h1:HS.mem -> h2:HS.mem -> Lemma
  (requires (modifies_0 h0 h1 /\ modifies_0 h1 h2))
  (ensures  (modifies_0 h0 h2))
  [SMTPatT (modifies_0 h0 h1); SMTPatT (modifies_0 h1 h2)]
let modifies_0_0 h0 h1 h2 = ()

let modifies_0_1 (#a:Type) (b:pointer a) h0 h1 h2 : Lemma
  (requires (~(contains h0 b) /\ modifies_0 h0 h1 /\ live h1 b /\ modifies_1 b h1 h2))
  (ensures  (modifies_0 h0 h2))
  [SMTPatT (modifies_0 h0 h1); SMTPatT (modifies_1 b h1 h2)]
  = ()

(** Concrete allocators, getters and setters *)

abstract let screate
  (#value:Type)
  (s: value)
: StackInline (pointer value)
  (requires (fun h -> True))
  (ensures (fun (h0:HS.mem) b h1 ->
       ~(contains h0 b)
     /\ live h1 b
     /\ frameOf b = h0.HS.tip
     /\ modifies_0 h0 h1
     /\ Map.domain h1.HS.h == Map.domain h0.HS.h
     /\ gread h1 b == s))
= let content: HS.reference value =
     HST.salloc s
  in
  Pointer content PathBase

// TODO: move to HyperStack?
private let domain_upd (#a:Type) (h:HS.mem) (x:HS.reference a{HS.live_region h x.HS.id}) (v:a) : Lemma
  (requires True)
  (ensures  (Map.domain h.HS.h == Map.domain (HS.upd h x v).HS.h))
  = let m = h.HS.h in
    let m' = Map.upd m x.HS.id (Heap.upd (Map.sel m x.HS.id) (HH.as_ref x.HS.ref) v) in
    Set.lemma_equal_intro (Map.domain m) (Map.domain m')

abstract let ecreate
  (#t:Type)
  (r:HH.rid)
  (s: t)
: ST (pointer t)
  (requires (fun h -> HS.is_eternal_region r))
  (ensures (fun (h0:HS.mem) b h1 -> ~(contains h0 b)
    /\ live h1 b
    /\ Map.domain h1.HS.h == Map.domain h0.HS.h
    /\ h1.HS.tip = h0.HS.tip
    /\ HS.modifies (Set.singleton r) h0 h1
    /\ HS.modifies_ref r TSet.empty h0 h1
    /\ gread h1 b == s
    /\ ~(memory_managed b)))
= let h0 = HST.get() in
  let content: HS.reference t = ralloc r s in
  let b = Pointer content PathBase in
  let h1 = HST.get() in
  domain_upd h0 content s;
  b

abstract let field
 (#key: eqtype)
 (#value: (key -> Tot Type))
 (p: pointer (DM.t key value))
 (fd: key)
: ST (pointer (value fd))
  (requires (fun h -> live h p))
  (ensures (fun h0 p' h1 -> h0 == h1 /\ p' == gfield p fd))
= _field p fd

abstract let cell
 (#length: UInt32.t)
 (#value: Type)
 (p: pointer (array length value))
 (i: UInt32.t {UInt32.v i < UInt32.v length})
: ST (pointer value)
  (requires (fun h -> live h p))
  (ensures (fun h0 p' h1 -> h0 == h1 /\ p' == gcell p i))
= _cell p i

abstract let read
 (#value: Type)
 (p: pointer value)
: ST value
  (requires (fun h -> live h p))
  (ensures (fun h0 v h1 -> live h0 p /\ h0 == h1 /\ v == gread h0 p))
= let (Pointer content p') = p in
  path_sel (!content) p'

private val hs_upd_path_upd: #a:Type -> b:pointer a -> z:a
  -> h0:HS.mem -> Lemma
  (requires (live h0 b))
  (ensures (live h0 b /\
    modifies_1 b h0  (HS.upd h0 (Pointer?.content b) (path_upd (HS.sel h0 (Pointer?.content b)) (Pointer?.p b) z))))
  [SMTPat (HS.upd h0 (Pointer?.content b) (path_upd (HS.sel h0 (Pointer?.content b)) (Pointer?.p b) z))]
let hs_upd_path_upd #a b z h0 = ()

abstract val write: #a:Type -> b:pointer a -> z:a -> Stack unit
  (requires (fun h -> live h b))
  (ensures (fun h0 _ h1 -> live h0 b /\ live h1 b
    /\ modifies_1 b h0 h1
    /\ gread h1 b == z ))
let write #a b z =
  let s0 = !b.content in
  let s = path_upd s0 (Pointer?.p b) z in
  b.content := s

(** Lemmas and patterns *)

let modifies_one_trans_1 (#a:Type) (b:pointer a) (h0:HS.mem) (h1:HS.mem) (h2:HS.mem): Lemma
  (requires (HS.modifies_one (frameOf b) h0 h1 /\ HS.modifies_one (frameOf b) h1 h2))
  (ensures (HS.modifies_one (frameOf b) h0 h2))
  [SMTPatT (HS.modifies_one (frameOf b) h0 h1); SMTPatT (HS.modifies_one (frameOf b) h1 h2)]
  = ()

val no_upd_lemma_0: #t:Type -> h0:HS.mem -> h1:HS.mem -> b:pointer t -> Lemma
  (requires (live h0 b /\ modifies_0 h0 h1))
  (ensures  (live h0 b /\ live h1 b /\ equal_values h0 b h1 b))
  [SMTPatT (modifies_0 h0 h1); SMTPatT (live h0 b)]
let no_upd_lemma_0 #t h0 h1 b = ()

val no_upd_lemma_1: #t:Type -> #t':Type -> h0:HS.mem -> h1:HS.mem -> a:pointer t -> b:pointer t' -> Lemma
  (requires (live h0 b /\ disjoint a b /\ modifies_1 a h0 h1))
  (ensures  (live h0 b /\ live h1 b /\ equal_values h0 b h1 b))
  [SMTPatOr [ [ SMTPatT (modifies_1 a h0 h1); SMTPatT (gread h1 b) ] ; [ SMTPatT (modifies_1 a h0 h1); SMTPatT (live h0 b) ] ] ]
let no_upd_lemma_1 #t #t' h0 h1 a b = ()

val no_upd_fresh: #t:Type -> h0:HS.mem -> h1:HS.mem -> a:pointer t -> Lemma
  (requires (live h0 a /\ HS.fresh_frame h0 h1))
  (ensures  (live h0 a /\ live h1 a /\ equal_values h0 a h1 a))
  [SMTPatT (live h0 a); SMTPatT (HS.fresh_frame h0 h1)]
let no_upd_fresh #t h0 h1 a = ()

val no_upd_popped: #t:Type -> h0:HS.mem -> h1:HS.mem -> b:pointer t -> Lemma
  (requires (live h0 b /\ frameOf b <> h0.HS.tip /\ HS.popped h0 h1))
  (ensures  (live h0 b /\ live h1 b /\ equal_values h0 b h1 b))
  [SMTPatT (live h0 b); SMTPatT (HS.popped h0 h1)]
let no_upd_popped #t h0 h1 b = ()

let lemma_modifies_sub_1 #t h0 h1 (b:pointer t) : Lemma
  (requires (h1 == h0))
  (ensures  (modifies_1 b h0 h1))
  [SMTPatT (live h0 b); SMTPatT (modifies_1 b h0 h1)]
  = ()

let modifies_substruct_1 (#tsub #ta:Type) h0 h1 (sub:pointer tsub) (a:pointer ta) : Lemma
  (requires (live h0 a /\ modifies_1 sub h0 h1 /\ live h1 sub /\ includes a sub))
  (ensures  (modifies_1 a h0 h1 /\ live h1 a))
  [SMTPatT (modifies_1 sub h0 h1); SMTPatT (includes a sub)]
  = ()

let modifies_popped_1' (#t:Type) (a:pointer t) h0 h1 h2 h3 : Lemma
  (requires (live h0 a /\ HS.fresh_frame h0 h1 /\ HS.popped h2 h3 /\ modifies_1 a h1 h2))
  (ensures  (modifies_1 a h0 h3))
  [SMTPatT (HS.fresh_frame h0 h1); SMTPatT (HS.popped h2 h3); SMTPatT (modifies_1 a h1 h2)]
  = ()

let live_popped (#t:Type) (b:pointer t) h0 h1 : Lemma
  (requires (HS.popped h0 h1 /\ live h0 b /\ frameOf b <> h0.HS.tip))
  (ensures  (live h1 b))
  [SMTPatT (HS.popped h0 h1); SMTPatT (live h0 b)]
  = ()

let live_fresh (#t:Type) (b:pointer t) h0 h1 : Lemma
  (requires (HS.fresh_frame h0 h1 /\ live h0 b))
  (ensures  (live h1 b))
  [SMTPatT (HS.fresh_frame h0 h1); SMTPatT (live h0 b)]
  = ()

let modifies_poppable_1 #t h0 h1 (b:pointer t) : Lemma
  (requires (modifies_1 b h0 h1 /\ HS.poppable h0))
  (ensures  (HS.poppable h1))
  [SMTPatT (modifies_1 b h0 h1)]
  = ()

(* The modifies class *)

(*
abstract
let pointer_of_reference
  (#t: Type)
  (r: HS.reference t)
: GTot (pointer t)
= Pointer r PathBase

let as_aref_pointer_of_reference
  (#t: Type)
  (r: HS.reference t)
: Lemma
  (requires True)
  (ensures (as_aref (pointer_of_reference r) == HS.as_aref r))
  [SMTPat (as_aref (pointer_of_reference r))]
= ()

let contains_pointer_of_reference
  (#t: Type)
  (h: HS.mem)
  (r: HS.reference t)
: Lemma
  (requires True)
  (ensures (contains h (pointer_of_reference r) == HS.contains h r))
  [SMTPat (contains h (pointer_of_reference r))]
= ()

let gread_pointer_of_reference
  (#t: Type)
  (h: HS.mem)
  (r: HS.reference t)
: Lemma
  (requires (live h (pointer_of_reference r)))
  (ensures (gread h (pointer_of_reference r) == HS.sel h r))
  [SMTPat (gread h (pointer_of_reference r))]
= ()

let frameOf_pointer_of_reference
  (#t: Type)
  (h: HS.mem)
  (r: HS.reference t)
: Lemma
  (requires True)
  (ensures (frameOf (pointer_of_reference r) == HS.frameOf r))
  [SMTPat (frameOf (pointer_of_reference r))]
= ()
*)

noeq type object =
| Object:
    (#t: Type) ->
    (obj: pointer t) ->
    (with_contents: bool) ->
    object

abstract
let object_ancestor
  (o: object)
: Tot HS.object
= HS.ObjectReference _ (Pointer?.content (Object?.obj o))

abstract
let object_ancestor_with_contents_eq
  (#t: Type)
  (p: pointer t)
: Lemma
  (object_ancestor (Object p true) == object_ancestor (Object p false))
= ()

let as_aref_object_ancestor
  (o: object)
: Lemma
  (requires True)
  (ensures (HS.ObjectReference? (object_ancestor o) /\ HS.as_aref (HS.ObjectReference?.r (object_ancestor o)) == as_aref (Object?.obj o)))
= ()

(*
let object_ancestor_pointer_of_reference
  (#t: Type)
  (r: HS.reference t)
: Lemma
  (requires True)
  (ensures (object_ancestor (Object (pointer_of_reference r)) == HS.ObjectReference _ r))
  [SMTPat (object_ancestor (Object (pointer_of_reference r)))]
= ()
*)

let object_ancestor_gfield
  (#key: eqtype)
  (#value: (key -> Tot Type))
  (p: pointer (DM.t key value))
  (fd: key)
  (b: bool)
: Lemma
  (requires True)
  (ensures (object_ancestor (Object (gfield p fd) b) == object_ancestor (Object p b)))
  [SMTPat (object_ancestor (Object (gfield p fd) b))]
= ()

let object_ancestor_gcell
  (#length: UInt32.t)
  (#value: Type)
  (p: pointer (array length value))
  (i: UInt32.t {UInt32.v i < UInt32.v length})
  (b: bool)
: Lemma
  (requires True)
  (ensures (object_ancestor (Object (gcell p i) b) == object_ancestor (Object p b)))
  [SMTPat (object_ancestor (Object (gcell p i) b))]
= ()

let object_disjoint
  (o1 o2: object)
: Tot Type0
= disjoint (Object?.obj o1) (Object?.obj o2) \/ Object?.with_contents o1 <> Object?.with_contents o2

let object_live
  (h: HS.mem)
  (o: object)
= live h (Object?.obj o)

let object_contains
  (h: HS.mem)
  (o: object)
= contains h (Object?.obj o)

let object_preserved
  (p: object)
  (h1 h2: HS.mem)
: Tot Type0
= (object_live h1 p ==> (object_live h2 p /\ (Object?.with_contents p ==> gread h2 (Object?.obj p) == gread h1 (Object?.obj p))))

let object_includes
  (o1 o2: object)
= includes (Object?.obj o1) (Object?.obj o2) /\ Object?.with_contents o1 == Object?.with_contents o2

let class': Modifies.class' HS.mem 1 object =
  Modifies.Class
    (* heap  *)                 HS.mem
    (* level *)                 1
    (* carrier *)               object
    (* disjoint *)              object_disjoint
    (* live *)                  object_live
    (* contains *)              object_contains
    (* preserved *)             object_preserved
    (* includes *)              object_includes
    (* ancestor_count *)        (fun x -> 1)
    (* ancestor_types *)        (fun x y -> HS.object)
    (* ancestor_class_levels *) (fun x y -> 0)
    (* ancestor_classes *)      (fun x y -> HS.class)
    (* ancestor_objects *)      (fun x y -> object_ancestor x)

abstract
let class_invariant ()
: Lemma 
  (requires True)
  (ensures (Modifies.class_invariant HS.class class'))
//  [SMTPat (Modifies.class_invariant HS.class class')]
= let s: Modifies.class_invariant_body u#0 u#1 HS.class class' = {
    Modifies.preserved_refl = (let f _ _ = () in f);
    Modifies.preserved_trans = (let f _ _ _ _ = () in f);
    Modifies.preserved_ancestors_preserved = begin
      let g
	(x: object)
	(h: HS.mem)
	(h' : HS.mem)
	(s: squash (Modifies.Class?.ancestor_count class' x > 0))
	(f: (
	  (i: nat { i < Modifies.Class?.ancestor_count class' x } ) ->
	  Lemma
	  (Modifies.Class?.preserved (Modifies.Class?.ancestor_classes class' x i) (Modifies.ancestor_objects class' x i) h h')
	))
      : Lemma
	(ensures (Modifies.Class?.preserved class' x h h'))
      = f 0
      in
      g
    end;
    Modifies.disjoint_sym = (let f _ _ = () in f);
    Modifies.level_0_class_eq_root = ();
    Modifies.level_0_fresh_disjoint = (let f _ _ _ _ = () in f);
    Modifies.preserved_live = (let f _ _ _ = () in f);
    Modifies.preserved_contains = (let f _ _ _ = () in f);
    Modifies.live_contains = (let f _ _ = () in f);
    Modifies.ancestors_contains = begin
      let g
	(h: HS.mem)
	(o: object)
	(s: squash (Modifies.Class?.ancestor_count class' o > 0))
	(f: (
	  (i: nat {i < Modifies.Class?.ancestor_count class' o } ) ->
	  Lemma
	  (Modifies.Class?.contains (Modifies.Class?.ancestor_classes class' o i) h (Modifies.ancestor_objects class' o i))
        ))
      : Lemma
	(ensures (Modifies.Class?.contains class' h o))
      = f 0
      in
      g
    end;
    Modifies.live_ancestors = (let f _ _ _ = () in f);
    Modifies.includes_refl = (let f _ = () in f);
    Modifies.includes_trans = (let f _ _ _ = () in f);
    Modifies.preserved_includes = begin
      let f
	(o1: object)
	(o2: object)
	(hbefore: HS.mem)
	(hafter: HS.mem)
      : Lemma
        (requires (Modifies.Class?.preserved class' o1 hbefore hafter /\ Modifies.Class?.includes class' o1 o2))
	(ensures (Modifies.Class?.preserved class' o2 hbefore hafter))
      = let x
	  (#t1: Type)
	  (#t2: Type)
	  (p1: pointer t1)
	  (p2: pointer t2 { includes p1 p2 } )
	: GTot Type0
	= (forall b . Modifies.Class?.preserved class' (Object p1 b) hbefore hafter ==> Modifies.Class?.preserved class' (Object p2 b) hbefore hafter)
	in
	let h_field
	  (#key: eqtype)
	  (#value: (key -> Tot Type))
	  (p: pointer (DM.t key value))
	  (fd: key {includes p (gfield p fd)})
	: Lemma (x p (gfield p fd))
	= ()
	in
	let h_cell
	  (#length: UInt32.t)
	  (#value: Type)
	  (p: pointer (array length value))
	  (i: UInt32.t {UInt32.v i < UInt32.v length /\ includes p (gcell p i)})
	: Lemma (x p (gcell p i))
	= ()
	in
	let h_refl
	  (#value: Type)
	  (p: pointer value {includes p p})
	: Lemma (x p p)
	= ()
	in
	let h_trans
	  (#value1: Type)
	  (#value2: Type)
	  (#value3: Type)
	  (p1: pointer value1)
	  (p2: pointer value2)
	  (p3: pointer value3 {includes p1 p2 /\ includes p2 p3 /\ includes p1 p3 /\ x p1 p2 /\ x p2 p3})
	: Lemma (x p1 p3)
	= ()
	in
	includes_ind x h_field h_cell h_refl h_trans (Object?.obj o1) (Object?.obj o2)
      in
      f
    end;
    Modifies.includes_contains = (let f _ _ _ = () in f);
    Modifies.contains_live = (let f _ _ _ = () in f);
    Modifies.includes_ancestors = begin
      let g
	(o1: object)
	(o2: object {Modifies.Class?.includes class' o1 o2 } )
	(i2: nat {i2 < Modifies.Class?.ancestor_count class' o2 } )
      : Tot (squash (i1: (i1 : nat {i1 < Modifies.Class?.ancestor_count class' o1} ) {
	  Modifies.includes_ancestors_t_prop class' o1 o2 i2 i1
        } ))
      = Squash.return_squash 0
      in
      g
    end;
    Modifies.disjoint_includes = (let f _ _ _ = () in f);
  }
  in
  (Modifies.class_invariant_intro s)

let class: Modifies.class HS.class 1 object = class_invariant () ; class'

(*
let class_eq
  ()
: Lemma
  (requires True)
  (ensures (class == class'))
  [SMTPatOr [[SMTPat class]; [SMTPat class']]]
= ()
*)

let locset_of_pointer
  (#t: Type)
  (p: pointer t)
: Tot (Modifies.locset HS.root_class)
= Modifies.locset_of_object class (Object p true)

let locset_of_pointer_liveness_tag
  (#t: Type)
  (p: pointer t)
: Tot (Modifies.locset HS.root_class)
= Modifies.locset_of_object class (Object p false)

let locset_of_pointer_disjoint_locset_of_pointer_liveness_tag
  (#t1: Type)
  (p1: pointer t1)
  (#t2: Type)
  (p2: pointer t2)
: Lemma
  (requires True)
  (ensures (Modifies.locset_disjoint (locset_of_pointer p1) (locset_of_pointer_liveness_tag p2)))
  [SMTPat (Modifies.locset_disjoint (locset_of_pointer p1) (locset_of_pointer_liveness_tag p2))]
= ()

let locset_of_pointer_with_liveness
  (#t: Type)
  (p: pointer t)
: Tot (Modifies.locset HS.root_class)
= TSet.union (locset_of_pointer p) (locset_of_pointer_liveness_tag p)

let locset_of_pointer_with_liveness_includes_locset_of_pointer
  (#t: Type)
  (p: pointer t)
: Lemma
  (requires True)
  (ensures (Modifies.locset_includes (locset_of_pointer_with_liveness p) (locset_of_pointer p)))
  [SMTPat (Modifies.locset_includes (locset_of_pointer_with_liveness p) (locset_of_pointer p))]
= ()

let locset_of_pointer_with_liveness_includes_locset_of_pointer_liveness_tag
  (#t: Type)
  (p: pointer t)
: Lemma
  (requires True)
  (ensures (Modifies.locset_includes (locset_of_pointer_with_liveness p) (locset_of_pointer_liveness_tag p)))
  [SMTPat (Modifies.locset_includes (locset_of_pointer_with_liveness p) (locset_of_pointer_liveness_tag p))]
= ()

let locset_of_reference_ancestor_includes_locset_of_pointer_with_liveness
  (#t: Type)
  (p: pointer t)
  (b: bool)
: Lemma
  (requires True)
  (ensures (Modifies.locset_of_object HS.class (object_ancestor (Object p b)) `Modifies.locset_includes` (locset_of_pointer_with_liveness p)))
  [SMTPat (Modifies.locset_of_object HS.class (object_ancestor (Object p b)) `Modifies.locset_includes` (locset_of_pointer_with_liveness p))]
= let o = object_ancestor (Object p b) in
  let s = Modifies.locset_of_object HS.class o in
  let f b' : Lemma
  (Modifies.locset_includes_loc (Modifies.locset_of_object HS.class (object_ancestor (Object p b))) (Modifies.loc_of_object class (Object p b')))
  =
  Modifies.locset_includes_loc_ancestors s class (Object p b') (fun _ ->
    Modifies.locset_includes_loc_object s HS.class o o
  )
  in
  f false; f true

let locset_of_region_includes_locset_of_pointer_with_liveness
  (#t: Type u#0)
  (p: pointer t)
: Lemma
  (requires True)
  (ensures (Modifies.locset_includes (HS.locset_of_region (frameOf p)) (locset_of_pointer_with_liveness p)))
  [SMTPat (Modifies.locset_includes (HS.locset_of_region (frameOf p)) (locset_of_pointer_with_liveness p))]
= HS.locset_of_reference_subset_locset_of_region (frameOf p) (HS.ObjectReference?.r (object_ancestor (Object p false)));
  locset_of_reference_ancestor_includes_locset_of_pointer_with_liveness p false

abstract val write': #a:Type -> b:pointer a -> z:a -> Stack unit
  (requires (fun h -> live h b))
  (ensures (fun h0 _ h1 -> live h0 b /\ live h1 b
    /\ Modifies.modifies u#0 u#1 (locset_of_pointer b) h0 h1
    /\ gread h1 b == z ))
let write' #a b z =
  let s0 = !b.content in
  let s = path_upd s0 (Pointer?.p b) z in
  let h = HST.get () in
  let _ = b.content := s in
  let h' = HST.get () in
  let _ : squash (Modifies.modifies u#0 u#1 (HS.locset_of_reference b.content) h h') = HS.modifies_locset_of_reference_intro h b.content s in
  let _ : squash (Modifies.modifies u#0 u#1 (locset_of_pointer b) h h') =
    let f
      (ty: Type u#1)
      (l: nat)
      (c: Modifies.class HS.root_class l ty )
      (o: ty)
      (g: (
	(o' : Modifies.loc HS.root_class { TSet.mem o' (locset_of_pointer b) } ) ->
	Lemma
	(Modifies.loc_disjoint (Modifies.loc_of_object c o) o')
      ))
    : Lemma
      (Modifies.Class?.preserved c o h h')
    =
      let f0
	(#level: nat)
	(#ty: Type u#1)
	(c: Modifies.class HS.root_class level ty)
	(o: ty)
	(f: (
	  (i: nat { i < Modifies.Class?.ancestor_count class (Object b true) } ) ->
	  Lemma
	  (Modifies.loc_disjoint (Modifies.loc_of_object c o) (Modifies.loc_of_object (Modifies.Class?.ancestor_classes class (Object b true) i) (Modifies.Class?.ancestor_objects class (Object b true) i)))
        ))
      : Lemma
	(Modifies.Class?.preserved c o h h')
      = Modifies.modifies_elim (HS.locset_of_reference b.content) h h' () c o (fun _ -> f 0)
      in  
      let f1
        (o1': object)
        (j: squash (Modifies.Class?.disjoint class (Object b true) o1'))
      : Lemma
        (Modifies.Class?.preserved class o1' h h')
      = ()
      in
      Modifies.modifies_loc_refines class (Object b true) h h' f0 f1 c o (g (Modifies.loc_of_object class (Object b true)))
    in
    Modifies.modifies_intro (locset_of_pointer b) h h' f
  in
  ()

let modifies_pointer_elim
  (#t: Type)
  (p: pointer t)
  (s: Modifies.locset HS.root_class)
  (h h': HS.mem)
: Lemma
  (requires (Modifies.modifies s h h' /\ Modifies.locset_disjoint (locset_of_pointer p) s))
  (ensures (live h p ==> live h' p /\ gread h' p == gread h p))
  [SMTPatOr [ [ SMTPatT (Modifies.modifies s h h') ; SMTPatT (gread h' p) ] ; [ SMTPatT (Modifies.modifies s h h') ; SMTPatT (live h p) ] ] ] // inspired froj no_upd_lemma_1
= ()

let locset_of_pointer_with_liveness_disjoint
  (#t: Type)
  (p1 p2: pointer t)
: Lemma
  (requires (disjoint p1 p2))
  (ensures (Modifies.locset_disjoint (locset_of_pointer_with_liveness p1) (locset_of_pointer_with_liveness p2)))
  [SMTPatOr [[SMTPat (disjoint p1 p2)]; [SMTPat (Modifies.locset_disjoint (locset_of_pointer_with_liveness p1) (locset_of_pointer_with_liveness p2))]]]
= ()
  
let locset_of_pointer_includes
  (#t1: Type)
  (p1: pointer t1)
  (#t2: Type)
  (p2: pointer t2)
: Lemma
  (requires (includes p1 p2))
  (ensures (Modifies.locset_includes (locset_of_pointer p1) (locset_of_pointer p2)))
  [SMTPatOr [[SMTPatT (includes p1 p2)]; [SMTPat (Modifies.locset_includes (locset_of_pointer p1) (locset_of_pointer p2))]]]
= ()

let locset_of_pointer_liveness_tag_includes
  (#t1: Type)
  (p1: pointer t1)
  (#t2: Type)
  (p2: pointer t2)
: Lemma
  (requires (includes p1 p2))
  (ensures (Modifies.locset_includes (locset_of_pointer_liveness_tag p1) (locset_of_pointer_liveness_tag p2)))
  [SMTPatOr [[SMTPatT (includes p1 p2)]; [SMTPat (Modifies.locset_includes (locset_of_pointer_liveness_tag p1) (locset_of_pointer_liveness_tag p2))]]]
= ()

let locset_of_pointer_with_liveness_includes
  (#t1: Type)
  (p1: pointer t1)
  (#t2: Type)
  (p2: pointer t2)
: Lemma
  (requires (includes p1 p2))
  (ensures (Modifies.locset_includes (locset_of_pointer_with_liveness p1) (locset_of_pointer_with_liveness p2)))
  [SMTPatOr [[SMTPatT (includes p1 p2)]; [SMTPat (Modifies.locset_includes (locset_of_pointer_with_liveness p1) (locset_of_pointer_with_liveness p2))]]]
= assert (Modifies.locset_includes (locset_of_pointer_with_liveness p1) (locset_of_pointer p1));
  assert (Modifies.locset_includes (locset_of_pointer_with_liveness p1) (locset_of_pointer_liveness_tag p1))
  // FIXME: WHY WHY WHY not automatic?
