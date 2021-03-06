open Prims
type name = FStar_Syntax_Syntax.bv
let tacdbg: Prims.bool FStar_ST.ref = FStar_Util.mk_ref false
type goal =
  {
  context: FStar_TypeChecker_Env.env;
  witness: FStar_Syntax_Syntax.term Prims.option;
  goal_ty: FStar_Syntax_Syntax.term;}
type proofstate =
  {
  main_context: FStar_TypeChecker_Env.env;
  main_goal: goal;
  all_implicits: FStar_TypeChecker_Env.implicits;
  goals: goal Prims.list;
  smt_goals: goal Prims.list;
  transaction: FStar_Unionfind.tx;}
type 'a result =
  | Success of ('a* proofstate)
  | Failed of (Prims.string* proofstate)
let uu___is_Success projectee =
  match projectee with | Success _0 -> true | uu____103 -> false
let __proj__Success__item___0 projectee =
  match projectee with | Success _0 -> _0
let uu___is_Failed projectee =
  match projectee with | Failed _0 -> true | uu____134 -> false
let __proj__Failed__item___0 projectee =
  match projectee with | Failed _0 -> _0
exception Failure of Prims.string
let uu___is_Failure: Prims.exn -> Prims.bool =
  fun projectee  ->
    match projectee with | Failure uu____158 -> true | uu____159 -> false
let __proj__Failure__item__uu___: Prims.exn -> Prims.string =
  fun projectee  -> match projectee with | Failure uu____166 -> uu____166
type 'a tac = {
  tac_f: proofstate -> 'a result;}
let mk_tac f = { tac_f = f }
let run t p = t.tac_f p
let ret x = mk_tac (fun p  -> Success (x, p))
let bind t1 t2 =
  mk_tac
    (fun p  ->
       let uu____259 = run t1 p in
       match uu____259 with
       | Success (a,q) -> let uu____264 = t2 a in run uu____264 q
       | Failed (msg,q) -> Failed (msg, q))
let goal_to_string: goal -> Prims.string =
  fun g  ->
    let g_binders =
      let uu____272 = FStar_TypeChecker_Env.all_binders g.context in
      FStar_All.pipe_right uu____272
        (FStar_Syntax_Print.binders_to_string ", ") in
    let uu____273 = FStar_Syntax_Print.term_to_string g.goal_ty in
    FStar_Util.format2 "%s |- %s" g_binders uu____273
let tacprint: Prims.string -> Prims.unit =
  fun s  -> FStar_Util.print1 "TAC>> %s\n" s
let tacprint1: Prims.string -> Prims.string -> Prims.unit =
  fun s  ->
    fun x  ->
      let uu____283 = FStar_Util.format1 s x in
      FStar_Util.print1 "TAC>> %s\n" uu____283
let tacprint2: Prims.string -> Prims.string -> Prims.string -> Prims.unit =
  fun s  ->
    fun x  ->
      fun y  ->
        let uu____293 = FStar_Util.format2 s x y in
        FStar_Util.print1 "TAC>> %s\n" uu____293
let tacprint3:
  Prims.string -> Prims.string -> Prims.string -> Prims.string -> Prims.unit
  =
  fun s  ->
    fun x  ->
      fun y  ->
        fun z  ->
          let uu____306 = FStar_Util.format3 s x y z in
          FStar_Util.print1 "TAC>> %s\n" uu____306
let dump_goal ps goal =
  let uu____320 = goal_to_string goal in tacprint uu____320
let dump_proofstate: proofstate -> Prims.string -> Prims.unit =
  fun ps  ->
    fun msg  ->
      tacprint1 "State dump (%s):" msg;
      (let uu____329 = FStar_Util.string_of_int (FStar_List.length ps.goals) in
       tacprint1 "ACTIVE goals (%s):" uu____329);
      FStar_List.iter (dump_goal ps) ps.goals;
      (let uu____335 =
         FStar_Util.string_of_int (FStar_List.length ps.smt_goals) in
       tacprint1 "SMT goals (%s):" uu____335);
      FStar_List.iter (dump_goal ps) ps.smt_goals
let print_proof_state: Prims.string -> Prims.unit tac =
  fun msg  -> mk_tac (fun p  -> dump_proofstate p msg; Success ((), p))
let get: proofstate tac = mk_tac (fun p  -> Success (p, p))
let log ps f =
  let uu____366 = FStar_ST.read tacdbg in if uu____366 then f () else ()
let mlog: (Prims.unit -> Prims.unit) -> Prims.unit tac =
  fun f  -> bind get (fun ps  -> log ps f; ret ())
let fail msg = mk_tac (fun p  -> Failed (msg, p))
let set: proofstate -> Prims.unit tac =
  fun p  -> mk_tac (fun uu____396  -> Success ((), p))
let solve: goal -> FStar_Syntax_Syntax.typ -> Prims.unit =
  fun goal  ->
    fun solution  ->
      match goal.witness with
      | None  -> ()
      | Some w ->
          let uu____404 =
            FStar_TypeChecker_Rel.teq_nosmt goal.context w solution in
          if uu____404
          then ()
          else
            (let uu____406 =
               let uu____407 =
                 let uu____408 = FStar_Syntax_Print.term_to_string solution in
                 let uu____409 = FStar_Syntax_Print.term_to_string w in
                 let uu____410 =
                   FStar_Syntax_Print.term_to_string goal.goal_ty in
                 FStar_Util.format3 "%s does not solve %s : %s" uu____408
                   uu____409 uu____410 in
               Failure uu____407 in
             Prims.raise uu____406)
let dismiss: Prims.unit tac =
  bind get
    (fun p  ->
       let uu____413 =
         let uu___82_414 = p in
         let uu____415 = FStar_List.tl p.goals in
         {
           main_context = (uu___82_414.main_context);
           main_goal = (uu___82_414.main_goal);
           all_implicits = (uu___82_414.all_implicits);
           goals = uu____415;
           smt_goals = (uu___82_414.smt_goals);
           transaction = (uu___82_414.transaction)
         } in
       set uu____413)
let dismiss_all: Prims.unit tac =
  bind get
    (fun p  ->
       set
         (let uu___83_419 = p in
          {
            main_context = (uu___83_419.main_context);
            main_goal = (uu___83_419.main_goal);
            all_implicits = (uu___83_419.all_implicits);
            goals = [];
            smt_goals = (uu___83_419.smt_goals);
            transaction = (uu___83_419.transaction)
          }))
let add_goals: goal Prims.list -> Prims.unit tac =
  fun gs  ->
    bind get
      (fun p  ->
         set
           (let uu___84_428 = p in
            {
              main_context = (uu___84_428.main_context);
              main_goal = (uu___84_428.main_goal);
              all_implicits = (uu___84_428.all_implicits);
              goals = (FStar_List.append gs p.goals);
              smt_goals = (uu___84_428.smt_goals);
              transaction = (uu___84_428.transaction)
            }))
let add_smt_goals: goal Prims.list -> Prims.unit tac =
  fun gs  ->
    bind get
      (fun p  ->
         set
           (let uu___85_437 = p in
            {
              main_context = (uu___85_437.main_context);
              main_goal = (uu___85_437.main_goal);
              all_implicits = (uu___85_437.all_implicits);
              goals = (uu___85_437.goals);
              smt_goals = (FStar_List.append gs p.smt_goals);
              transaction = (uu___85_437.transaction)
            }))
let replace_cur: goal -> Prims.unit tac =
  fun g  -> bind dismiss (fun uu____443  -> add_goals [g])
let add_implicits: FStar_TypeChecker_Env.implicits -> Prims.unit tac =
  fun i  ->
    bind get
      (fun p  ->
         set
           (let uu___86_450 = p in
            {
              main_context = (uu___86_450.main_context);
              main_goal = (uu___86_450.main_goal);
              all_implicits = (FStar_List.append i p.all_implicits);
              goals = (uu___86_450.goals);
              smt_goals = (uu___86_450.smt_goals);
              transaction = (uu___86_450.transaction)
            }))
let is_true: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____460 = FStar_Syntax_Util.destruct_typ_as_formula t in
    match uu____460 with
    | Some (FStar_Syntax_Util.BaseConn (l,[])) ->
        FStar_Ident.lid_equals l FStar_Syntax_Const.true_lid
    | uu____472 -> false
let is_false: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____477 = FStar_Syntax_Util.destruct_typ_as_formula t in
    match uu____477 with
    | Some (FStar_Syntax_Util.BaseConn (l,[])) ->
        FStar_Ident.lid_equals l FStar_Syntax_Const.false_lid
    | uu____489 -> false
let conj_goals: goal -> goal -> goal =
  fun g1  ->
    fun g2  ->
      let t1 = g1.goal_ty in
      let t2 = g2.goal_ty in
      let uu____499 = (is_true t1) || (is_false t2) in
      if uu____499
      then g2
      else
        (let uu____501 = (is_true t2) || (is_false t1) in
         if uu____501
         then g1
         else
           (let uu___87_503 = g1 in
            let uu____504 = FStar_Syntax_Util.mk_conj t1 t2 in
            {
              context = (uu___87_503.context);
              witness = (uu___87_503.witness);
              goal_ty = uu____504
            }))
let with_cur_goal nm f =
  bind get
    (fun p  ->
       match p.goals with | [] -> fail "No more goals" | hd1::tl1 -> f hd1)
let cur_goal: goal tac =
  mk_tac
    (fun ps  ->
       match ps.goals with
       | hd1::uu____534 -> Success (hd1, ps)
       | uu____536 -> Failed ("No goals left", ps))
let set_cur_goal: goal -> Prims.unit tac =
  fun g  ->
    mk_tac
      (fun ps  ->
         match ps.goals with
         | hd1::tl1 ->
             Success
               ((),
                 (let uu___88_548 = ps in
                  {
                    main_context = (uu___88_548.main_context);
                    main_goal = (uu___88_548.main_goal);
                    all_implicits = (uu___88_548.all_implicits);
                    goals = (g :: tl1);
                    smt_goals = (uu___88_548.smt_goals);
                    transaction = (uu___88_548.transaction)
                  }))
         | uu____549 -> Failed ("No goals left", ps))
let replace_point:
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term
  =
  fun e1  ->
    fun e2  ->
      fun t  ->
        let uu____560 = FStar_Syntax_Util.term_eq e1 t in
        if uu____560 then e2 else t
let treplace env e1 e2 t =
  FStar_Syntax_Util.bottom_fold (replace_point e1 e2) t
let grewrite_impl:
  FStar_Syntax_Syntax.typ ->
    FStar_Syntax_Syntax.typ ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.unit tac
  =
  fun t1  ->
    fun t2  ->
      fun e1  ->
        fun e2  ->
          bind cur_goal
            (fun g  ->
               let env = g.context in
               let ok =
                 let uu____601 = FStar_TypeChecker_Rel.try_teq true env t1 t2 in
                 match uu____601 with
                 | None  -> false
                 | Some g1 -> FStar_TypeChecker_Rel.is_trivial g1 in
               if ok
               then
                 let goal_ty' = treplace env e1 e2 g.goal_ty in
                 let uu____606 =
                   set_cur_goal
                     (let uu___89_608 = g in
                      {
                        context = (uu___89_608.context);
                        witness = (uu___89_608.witness);
                        goal_ty = goal_ty'
                      }) in
                 bind uu____606
                   (fun uu____609  ->
                      let uu____610 =
                        let uu____612 =
                          let uu____613 =
                            FStar_Syntax_Util.mk_eq2
                              FStar_Syntax_Syntax.U_zero t1 e1 e2 in
                          {
                            context = (g.context);
                            witness = None;
                            goal_ty = uu____613
                          } in
                        [uu____612] in
                      add_goals uu____610)
               else
                 (FStar_TypeChecker_Err.add_errors env
                    [("Ill-type rewriting requested",
                       (e1.FStar_Syntax_Syntax.pos))];
                  fail "grewrite: Ill-typed rewriting requested"))
let smt: Prims.unit tac =
  with_cur_goal "smt"
    (fun g  ->
       bind dismiss
         (fun uu____622  ->
            let uu____623 =
              add_goals
                [(let uu___90_625 = g in
                  {
                    context = (uu___90_625.context);
                    witness = (uu___90_625.witness);
                    goal_ty = FStar_Syntax_Util.t_true
                  })] in
            bind uu____623 (fun uu____626  -> add_smt_goals [g])))
let focus_cur_goal nm f =
  bind get
    (fun p  ->
       match p.goals with
       | [] -> fail "No more goals"
       | hd1::tl1 ->
           let q =
             let uu___91_648 = p in
             {
               main_context = (uu___91_648.main_context);
               main_goal = (uu___91_648.main_goal);
               all_implicits = (uu___91_648.all_implicits);
               goals = [hd1];
               smt_goals = (uu___91_648.smt_goals);
               transaction = (uu___91_648.transaction)
             } in
           let uu____649 = set q in
           bind uu____649
             (fun uu____651  ->
                bind f
                  (fun a  ->
                     bind get
                       (fun q'  ->
                          let q2 =
                            let uu___92_655 = q' in
                            {
                              main_context = (uu___92_655.main_context);
                              main_goal = (uu___92_655.main_goal);
                              all_implicits = (uu___92_655.all_implicits);
                              goals = (FStar_List.append q'.goals tl1);
                              smt_goals = (uu___92_655.smt_goals);
                              transaction = (uu___92_655.transaction)
                            } in
                          let uu____656 = set q2 in
                          bind uu____656 (fun uu____658  -> ret a)))))
let cur_goal_and_rest f g =
  bind get
    (fun p  ->
       match p.goals with
       | [] -> fail "No more goals"
       | uu____692::[] -> bind f (fun a  -> ret (a, None))
       | hd1::tl1 ->
           bind dismiss_all
             (fun uu____707  ->
                let uu____708 = add_goals [hd1] in
                bind uu____708
                  (fun uu____713  ->
                     bind f
                       (fun a  ->
                          bind get
                            (fun uu____721  ->
                               match uu____721 with
                               | { main_context = uu____726;
                                   main_goal = uu____727;
                                   all_implicits = uu____728;
                                   goals = sub_goals_f;
                                   smt_goals = uu____730;
                                   transaction = uu____731;_} ->
                                   bind dismiss_all
                                     (fun uu____737  ->
                                        let uu____738 = add_goals tl1 in
                                        bind uu____738
                                          (fun uu____743  ->
                                             bind g
                                               (fun b  ->
                                                  let uu____748 =
                                                    add_goals sub_goals_f in
                                                  bind uu____748
                                                    (fun uu____753  ->
                                                       ret (a, (Some b)))))))))))
let or_else t1 t2 =
  mk_tac
    (fun p  ->
       let uu____776 = t1.tac_f p in
       match uu____776 with | Failed uu____779 -> t2.tac_f p | q -> q)
let rec map t =
  mk_tac
    (fun ps  ->
       let uu____797 =
         let uu____800 =
           let uu____806 = map t in cur_goal_and_rest t uu____806 in
         bind uu____800
           (fun uu___81_815  ->
              match uu___81_815 with
              | (hd1,None ) -> ret [hd1]
              | (hd1,Some tl1) -> ret (hd1 :: tl1)) in
       run uu____797 ps)
let map_goal_term:
  (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) -> Prims.unit tac =
  fun f  ->
    let aux =
      with_cur_goal "map_goal"
        (fun g  ->
           let uu____848 =
             let uu___93_849 = g in
             let uu____850 = f g.goal_ty in
             {
               context = (uu___93_849.context);
               witness = (uu___93_849.witness);
               goal_ty = uu____850
             } in
           replace_cur uu____848) in
    let uu____851 = map aux in bind uu____851 (fun uu____855  -> ret ())
let map_meta t =
  with_cur_goal "map_meta"
    (fun g  ->
       let uu____868 =
         let uu____869 = FStar_Syntax_Subst.compress g.goal_ty in
         uu____869.FStar_Syntax_Syntax.n in
       match uu____868 with
       | FStar_Syntax_Syntax.Tm_meta (f,annot) ->
           let uu____879 =
             replace_cur
               (let uu___94_881 = g in
                {
                  context = (uu___94_881.context);
                  witness = (uu___94_881.witness);
                  goal_ty = f
                }) in
           bind uu____879
             (fun uu____882  ->
                bind t
                  (fun a  ->
                     let uu____884 =
                       map_goal_term
                         (fun tm  ->
                            let uu____887 = is_true tm in
                            if uu____887
                            then tm
                            else
                              FStar_Syntax_Syntax.mk
                                (FStar_Syntax_Syntax.Tm_meta (tm, annot))
                                None tm.FStar_Syntax_Syntax.pos) in
                     bind uu____884 (fun uu____893  -> ret a)))
       | uu____894 -> fail "Not a meta")
let seq: Prims.unit tac -> Prims.unit tac -> Prims.unit tac =
  fun t1  ->
    fun t2  ->
      let uu____907 =
        bind t1
          (fun uu____909  ->
             let uu____910 = map t2 in
             bind uu____910 (fun uu____914  -> ret ())) in
      focus_cur_goal "seq" uu____907
let intros: FStar_Syntax_Syntax.binders tac =
  with_cur_goal "intros"
    (fun goal  ->
       let uu____918 = FStar_Syntax_Util.destruct_typ_as_formula goal.goal_ty in
       match uu____918 with
       | Some (FStar_Syntax_Util.QAll (bs,pats,body)) ->
           let new_context =
             FStar_TypeChecker_Env.push_binders goal.context bs in
           let new_goal =
             { context = new_context; witness = None; goal_ty = body } in
           bind dismiss
             (fun uu____926  ->
                let uu____927 = add_goals [new_goal] in
                bind uu____927
                  (fun uu____929  ->
                     let uu____930 =
                       FStar_All.pipe_left mlog
                         (fun uu____935  ->
                            let uu____936 =
                              FStar_Syntax_Print.binders_to_string ", " bs in
                            FStar_Util.print1 "intros: %s\n" uu____936) in
                     bind uu____930 (fun uu____937  -> ret bs)))
       | uu____938 -> fail "Cannot intro this goal, expected a forall")
let intros_no_names: Prims.unit tac = bind intros (fun uu____941  -> ret ())
let mk_squash p =
  let sq = FStar_Syntax_Util.fvar_const FStar_Syntax_Const.squash_lid in
  let uu____952 = let uu____958 = FStar_Syntax_Syntax.as_arg p in [uu____958] in
  FStar_Syntax_Util.mk_app sq uu____952
let un_squash:
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax Prims.option
  =
  fun t  ->
    let uu____965 = FStar_Syntax_Util.head_and_args t in
    match uu____965 with
    | (head1,args) ->
        let uu____994 =
          let uu____1002 =
            let uu____1003 = FStar_Syntax_Util.un_uinst head1 in
            uu____1003.FStar_Syntax_Syntax.n in
          (uu____1002, args) in
        (match uu____994 with
         | (FStar_Syntax_Syntax.Tm_fvar fv,(p,uu____1016)::[]) when
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.squash_lid
             -> Some p
         | (FStar_Syntax_Syntax.Tm_refine
            ({ FStar_Syntax_Syntax.ppname = uu____1036;
               FStar_Syntax_Syntax.index = uu____1037;
               FStar_Syntax_Syntax.sort =
                 { FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv;
                   FStar_Syntax_Syntax.tk = uu____1039;
                   FStar_Syntax_Syntax.pos = uu____1040;
                   FStar_Syntax_Syntax.vars = uu____1041;_};_},p),[])
             when
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.unit_lid ->
             Some p
         | uu____1060 -> None)
let imp_intro: FStar_Syntax_Syntax.binder tac =
  with_cur_goal "imp_intro"
    (fun goal  ->
       let uu____1072 =
         FStar_Syntax_Util.destruct_typ_as_formula goal.goal_ty in
       match uu____1072 with
       | Some (FStar_Syntax_Util.BaseConn
           (l,(lhs,uu____1077)::(rhs,uu____1079)::[])) when
           FStar_Ident.lid_equals l FStar_Syntax_Const.imp_lid ->
           let name = FStar_Syntax_Syntax.new_bv None lhs in
           let new_goal =
             let uu____1107 = FStar_TypeChecker_Env.push_bv goal.context name in
             { context = uu____1107; witness = None; goal_ty = rhs } in
           bind dismiss
             (fun uu____1108  ->
                let uu____1109 = add_goals [new_goal] in
                bind uu____1109
                  (fun uu____1111  ->
                     let uu____1112 =
                       FStar_All.pipe_left mlog
                         (fun uu____1117  ->
                            let uu____1118 =
                              FStar_Syntax_Print.bv_to_string name in
                            FStar_Util.print1 "imp_intro: %s\n" uu____1118) in
                     bind uu____1112
                       (fun uu____1119  ->
                          let uu____1120 = FStar_Syntax_Syntax.mk_binder name in
                          ret uu____1120)))
       | uu____1121 -> fail "Cannot intro this goal, expected an '==>'")
let split: Prims.unit tac =
  with_cur_goal "split"
    (fun goal  ->
       let uu____1125 =
         FStar_Syntax_Util.destruct_typ_as_formula goal.goal_ty in
       match uu____1125 with
       | Some (FStar_Syntax_Util.BaseConn (l,args)) when
           FStar_Ident.lid_equals l FStar_Syntax_Const.and_lid ->
           let new_goals =
             FStar_All.pipe_right args
               (FStar_List.map
                  (fun uu____1135  ->
                     match uu____1135 with
                     | (a,uu____1139) ->
                         let uu___95_1140 = goal in
                         {
                           context = (uu___95_1140.context);
                           witness = None;
                           goal_ty = a
                         })) in
           bind dismiss (fun uu____1141  -> add_goals new_goals)
       | uu____1142 -> fail "Cannot split this goal; expected a conjunction")
let trivial: Prims.unit tac =
  with_cur_goal "trivial"
    (fun goal  ->
       let steps =
         [FStar_TypeChecker_Normalize.Reify;
         FStar_TypeChecker_Normalize.Beta;
         FStar_TypeChecker_Normalize.UnfoldUntil
           FStar_Syntax_Syntax.Delta_constant;
         FStar_TypeChecker_Normalize.Zeta;
         FStar_TypeChecker_Normalize.Iota;
         FStar_TypeChecker_Normalize.Primops] in
       let t =
         FStar_TypeChecker_Normalize.normalize steps goal.context
           goal.goal_ty in
       let uu____1149 = FStar_Syntax_Util.destruct_typ_as_formula t in
       match uu____1149 with
       | Some (FStar_Syntax_Util.BaseConn (l,[])) when
           FStar_Ident.lid_equals l FStar_Syntax_Const.true_lid ->
           bind dismiss
             (fun uu____1162  ->
                add_goals
                  [(let uu___96_1163 = goal in
                    {
                      context = (uu___96_1163.context);
                      witness = (uu___96_1163.witness);
                      goal_ty = t
                    })])
       | uu____1164 -> fail "Not a trivial goal")
let apply_lemma: FStar_Syntax_Syntax.term -> Prims.unit tac =
  fun tm  ->
    with_cur_goal "apply_lemma"
      (fun goal  ->
         try
           let uu____1175 =
             (goal.context).FStar_TypeChecker_Env.type_of goal.context tm in
           match uu____1175 with
           | (tm1,t,guard) ->
               let uu____1183 =
                 let uu____1184 = FStar_Syntax_Util.is_lemma t in
                 Prims.op_Negation uu____1184 in
               if uu____1183
               then fail "apply_lemma: not a lemma"
               else
                 (let uu____1187 = FStar_Syntax_Util.arrow_formals_comp t in
                  match uu____1187 with
                  | (bs,comp) ->
                      let uu____1202 =
                        FStar_List.fold_left
                          (fun uu____1219  ->
                             fun uu____1220  ->
                               match (uu____1219, uu____1220) with
                               | ((uvs,guard1,subst1),(b,aq)) ->
                                   let b_t =
                                     FStar_Syntax_Subst.subst subst1
                                       b.FStar_Syntax_Syntax.sort in
                                   let uu____1269 =
                                     FStar_TypeChecker_Util.new_implicit_var
                                       "apply_lemma"
                                       (goal.goal_ty).FStar_Syntax_Syntax.pos
                                       goal.context b_t in
                                   (match uu____1269 with
                                    | (u,uu____1284,g_u) ->
                                        let uu____1292 =
                                          FStar_TypeChecker_Rel.conj_guard
                                            guard1 g_u in
                                        (((u, aq) :: uvs), uu____1292,
                                          ((FStar_Syntax_Syntax.NT (b, u)) ::
                                          subst1)))) ([], guard, []) bs in
                      (match uu____1202 with
                       | (uvs,implicits,subst1) ->
                           let uvs1 = FStar_List.rev uvs in
                           let comp1 =
                             FStar_Syntax_Subst.subst_comp subst1 comp in
                           let uu____1324 =
                             let c = FStar_Syntax_Util.comp_to_comp_typ comp1 in
                             match c.FStar_Syntax_Syntax.effect_args with
                             | pre::post::uu____1340 ->
                                 ((Prims.fst pre), (Prims.fst post))
                             | uu____1370 ->
                                 failwith "Impossible: not a lemma" in
                           (match uu____1324 with
                            | (pre,post) ->
                                let uu____1393 =
                                  FStar_TypeChecker_Rel.try_teq false
                                    goal.context post goal.goal_ty in
                                (match uu____1393 with
                                 | None  ->
                                     fail
                                       "apply_lemma: does not unify with goal"
                                 | Some g ->
                                     let g1 =
                                       let uu____1398 =
                                         FStar_TypeChecker_Rel.solve_deferred_constraints
                                           goal.context g in
                                       FStar_All.pipe_right uu____1398
                                         FStar_TypeChecker_Rel.resolve_implicits in
                                     let solution =
                                       (FStar_Syntax_Syntax.mk_Tm_app tm1
                                          uvs1) None
                                         (goal.context).FStar_TypeChecker_Env.range in
                                     let implicits1 =
                                       FStar_All.pipe_right
                                         implicits.FStar_TypeChecker_Env.implicits
                                         (FStar_List.filter
                                            (fun uu____1434  ->
                                               match uu____1434 with
                                               | (uu____1441,uu____1442,uu____1443,tm2,uu____1445,uu____1446)
                                                   ->
                                                   let uu____1447 =
                                                     FStar_Syntax_Util.head_and_args
                                                       tm2 in
                                                   (match uu____1447 with
                                                    | (hd1,uu____1458) ->
                                                        let uu____1473 =
                                                          let uu____1474 =
                                                            FStar_Syntax_Subst.compress
                                                              hd1 in
                                                          uu____1474.FStar_Syntax_Syntax.n in
                                                        (match uu____1473
                                                         with
                                                         | FStar_Syntax_Syntax.Tm_uvar
                                                             uu____1477 ->
                                                             true
                                                         | uu____1486 ->
                                                             false)))) in
                                     (solve goal solution;
                                      (let sub_goals =
                                         let uu____1490 =
                                           FStar_All.pipe_right implicits1
                                             (FStar_List.map
                                                (fun uu____1506  ->
                                                   match uu____1506 with
                                                   | (_msg,_env,_uvar,term,typ,uu____1518)
                                                       ->
                                                       {
                                                         context =
                                                           (goal.context);
                                                         witness =
                                                           (Some term);
                                                         goal_ty = typ
                                                       })) in
                                         (let uu___99_1519 = goal in
                                          {
                                            context = (uu___99_1519.context);
                                            witness = None;
                                            goal_ty = pre
                                          }) :: uu____1490 in
                                       let uu____1520 =
                                         add_implicits
                                           g1.FStar_TypeChecker_Env.implicits in
                                       bind uu____1520
                                         (fun uu____1522  ->
                                            bind dismiss
                                              (fun uu____1523  ->
                                                 add_goals sub_goals))))))))
         with | uu____1526 -> fail "apply_lemma: ill-typed term")
let exact: FStar_Syntax_Syntax.term -> Prims.unit tac =
  fun tm  ->
    with_cur_goal "exact"
      (fun goal  ->
         try
           let uu____1536 =
             (goal.context).FStar_TypeChecker_Env.type_of goal.context tm in
           match uu____1536 with
           | (uu____1541,t,guard) ->
               let uu____1544 =
                 FStar_TypeChecker_Rel.teq_nosmt goal.context t goal.goal_ty in
               if uu____1544
               then
                 (solve goal tm;
                  replace_cur
                    (let uu___102_1547 = goal in
                     {
                       context = (uu___102_1547.context);
                       witness = None;
                       goal_ty = FStar_Syntax_Util.t_true
                     }))
               else
                 (let msg =
                    let uu____1550 = FStar_Syntax_Print.term_to_string tm in
                    let uu____1551 = FStar_Syntax_Print.term_to_string t in
                    let uu____1552 =
                      FStar_Syntax_Print.term_to_string goal.goal_ty in
                    FStar_Util.format3
                      "%s : %s does not exactly solve the goal %s" uu____1550
                      uu____1551 uu____1552 in
                  fail msg)
         with
         | e ->
             let uu____1556 =
               let uu____1557 = FStar_Syntax_Print.term_to_string tm in
               FStar_Util.format1 "Term is not typeable: %s" uu____1557 in
             fail uu____1556)
let rewrite: FStar_Syntax_Syntax.binder -> Prims.unit tac =
  fun h  ->
    with_cur_goal "rewrite"
      (fun goal  ->
         let uu____1564 =
           FStar_All.pipe_left mlog
             (fun uu____1569  ->
                let uu____1570 =
                  FStar_Syntax_Print.bv_to_string (Prims.fst h) in
                let uu____1571 =
                  FStar_Syntax_Print.term_to_string
                    (Prims.fst h).FStar_Syntax_Syntax.sort in
                FStar_Util.print2 "+++Rewrite %s : %s\n" uu____1570
                  uu____1571) in
         bind uu____1564
           (fun uu____1572  ->
              let uu____1573 =
                let uu____1575 =
                  let uu____1576 =
                    FStar_TypeChecker_Env.lookup_bv goal.context
                      (Prims.fst h) in
                  FStar_All.pipe_left Prims.fst uu____1576 in
                FStar_Syntax_Util.destruct_typ_as_formula uu____1575 in
              match uu____1573 with
              | Some (FStar_Syntax_Util.BaseConn
                  (l,uu____1583::(x,uu____1585)::(e,uu____1587)::[])) when
                  FStar_Ident.lid_equals l FStar_Syntax_Const.eq2_lid ->
                  let uu____1621 =
                    let uu____1622 = FStar_Syntax_Subst.compress x in
                    uu____1622.FStar_Syntax_Syntax.n in
                  (match uu____1621 with
                   | FStar_Syntax_Syntax.Tm_name x1 ->
                       let goal1 =
                         let uu___103_1628 = goal in
                         let uu____1629 =
                           FStar_Syntax_Subst.subst
                             [FStar_Syntax_Syntax.NT (x1, e)] goal.goal_ty in
                         {
                           context = (uu___103_1628.context);
                           witness = (uu___103_1628.witness);
                           goal_ty = uu____1629
                         } in
                       replace_cur goal1
                   | uu____1632 ->
                       fail
                         "Not an equality hypothesis with a variable on the LHS")
              | uu____1633 -> fail "Not an equality hypothesis"))
let clear: Prims.unit tac =
  with_cur_goal "clear"
    (fun goal  ->
       let uu____1637 = FStar_TypeChecker_Env.pop_bv goal.context in
       match uu____1637 with
       | None  -> fail "Cannot clear; empty context"
       | Some (x,env') ->
           let fns = FStar_Syntax_Free.names goal.goal_ty in
           let uu____1650 = FStar_Util.set_mem x fns in
           if uu____1650
           then fail "Cannot clear; variable appears in goal"
           else
             (let new_goal =
                let uu___104_1654 = goal in
                {
                  context = env';
                  witness = (uu___104_1654.witness);
                  goal_ty = (uu___104_1654.goal_ty)
                } in
              bind dismiss (fun uu____1655  -> add_goals [new_goal])))
let clear_hd: name -> Prims.unit tac =
  fun x  ->
    with_cur_goal "clear_hd"
      (fun goal  ->
         let uu____1662 = FStar_TypeChecker_Env.pop_bv goal.context in
         match uu____1662 with
         | None  -> fail "Cannot clear_hd; empty context"
         | Some (y,env') ->
             if Prims.op_Negation (FStar_Syntax_Syntax.bv_eq x y)
             then fail "Cannot clear_hd; head variable mismatch"
             else clear)
let revert: Prims.unit tac =
  with_cur_goal "revert"
    (fun goal  ->
       let uu____1677 = FStar_TypeChecker_Env.pop_bv goal.context in
       match uu____1677 with
       | None  -> fail "Cannot revert; empty context"
       | Some (x,env') ->
           let fvs = FStar_Syntax_Free.names goal.goal_ty in
           let new_goal =
             let uu____1691 = FStar_Util.set_mem x fvs in
             if uu____1691
             then
               let uu___105_1692 = goal in
               let uu____1693 =
                 let uu____1694 =
                   FStar_TypeChecker_TcTerm.universe_of env'
                     x.FStar_Syntax_Syntax.sort in
                 FStar_Syntax_Util.mk_forall uu____1694 x goal.goal_ty in
               {
                 context = env';
                 witness = (uu___105_1692.witness);
                 goal_ty = uu____1693
               }
             else
               (let uu___106_1696 = goal in
                let uu____1697 =
                  FStar_Syntax_Util.mk_imp x.FStar_Syntax_Syntax.sort
                    goal.goal_ty in
                {
                  context = env';
                  witness = (uu___106_1696.witness);
                  goal_ty = uu____1697
                }) in
           bind dismiss (fun uu____1698  -> add_goals [new_goal]))
let revert_hd: name -> Prims.unit tac =
  fun x  ->
    with_cur_goal "revert_hd"
      (fun goal  ->
         let uu____1705 = FStar_TypeChecker_Env.pop_bv goal.context in
         match uu____1705 with
         | None  -> fail "Cannot revert_hd; empty context"
         | Some (y,env') ->
             if Prims.op_Negation (FStar_Syntax_Syntax.bv_eq x y)
             then
               let uu____1717 =
                 let uu____1718 = FStar_Syntax_Print.bv_to_string x in
                 let uu____1719 = FStar_Syntax_Print.bv_to_string y in
                 FStar_Util.format2
                   "Cannot revert_hd %s; head variable mismatch ... egot %s"
                   uu____1718 uu____1719 in
               fail uu____1717
             else revert)
let rec revert_all_hd: name Prims.list -> Prims.unit tac =
  fun xs  ->
    match xs with
    | [] -> ret ()
    | x::xs1 ->
        let uu____1732 = revert_all_hd xs1 in
        bind uu____1732 (fun uu____1734  -> revert_hd x)
let is_name: FStar_Syntax_Syntax.term -> Prims.bool =
  fun x  ->
    let uu____1738 =
      let uu____1739 = FStar_Syntax_Subst.compress x in
      uu____1739.FStar_Syntax_Syntax.n in
    match uu____1738 with
    | FStar_Syntax_Syntax.Tm_name uu____1742 -> true
    | uu____1743 -> false
let as_name: FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.bv =
  fun x  ->
    let uu____1747 =
      let uu____1748 = FStar_Syntax_Subst.compress x in
      uu____1748.FStar_Syntax_Syntax.n in
    match uu____1747 with
    | FStar_Syntax_Syntax.Tm_name x1 -> x1
    | uu____1752 -> failwith "Not a name"
let destruct_equality_imp:
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.bv*
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax*
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax) Prims.option
  =
  fun t  ->
    let uu____1764 = FStar_Syntax_Util.destruct_typ_as_formula t in
    match uu____1764 with
    | Some (FStar_Syntax_Util.BaseConn
        (l,(lhs,uu____1776)::(rhs,uu____1778)::[])) when
        FStar_Ident.lid_equals l FStar_Syntax_Const.imp_lid ->
        let uu____1804 = FStar_Syntax_Util.destruct_typ_as_formula lhs in
        (match uu____1804 with
         | Some (FStar_Syntax_Util.BaseConn (eq1,_::(x,_)::(e,_)::[]))|Some
           (FStar_Syntax_Util.BaseConn (eq1,(x,_)::(e,_)::[])) when
             (FStar_Ident.lid_equals eq1 FStar_Syntax_Const.eq2_lid) &&
               (is_name x)
             ->
             let uu____1876 =
               let uu____1884 = as_name x in (uu____1884, e, rhs) in
             Some uu____1876
         | uu____1896 -> None)
    | uu____1905 -> None
let at_most_one t =
  bind t
    (fun a  ->
       bind get
         (fun p  ->
            match p.goals with
            | []|_::[] -> ret a
            | uu____1928 -> fail "expected at most one goal remaining"))
let merge_sub_goals: Prims.unit tac =
  bind get
    (fun p  ->
       match p.goals with
       | g1::g2::rest ->
           let uu____1937 =
             ((FStar_TypeChecker_Env.eq_gamma g1.context g2.context) &&
                (FStar_Option.isNone g1.witness))
               && (FStar_Option.isNone g2.witness) in
           if uu____1937
           then
             let uu____1939 =
               let uu___107_1940 = p in
               let uu____1941 =
                 let uu____1943 = conj_goals g1 g2 in uu____1943 :: rest in
               {
                 main_context = (uu___107_1940.main_context);
                 main_goal = (uu___107_1940.main_goal);
                 all_implicits = (uu___107_1940.all_implicits);
                 goals = uu____1941;
                 smt_goals = (uu___107_1940.smt_goals);
                 transaction = (uu___107_1940.transaction)
               } in
             set uu____1939
           else
             (let g1_binders =
                let uu____1946 = FStar_TypeChecker_Env.all_binders g1.context in
                FStar_All.pipe_right uu____1946
                  (FStar_Syntax_Print.binders_to_string ", ") in
              let g2_binders =
                let uu____1948 = FStar_TypeChecker_Env.all_binders g2.context in
                FStar_All.pipe_right uu____1948
                  (FStar_Syntax_Print.binders_to_string ", ") in
              let uu____1949 =
                let uu____1950 = goal_to_string g1 in
                let uu____1951 = goal_to_string g2 in
                let uu____1952 =
                  let uu____1953 =
                    FStar_TypeChecker_Env.eq_gamma g1.context g2.context in
                  FStar_All.pipe_right uu____1953 FStar_Util.string_of_bool in
                FStar_Util.format3
                  "Cannot merge sub-goals: incompatible contexts:\ng1=%s\ng2=%s\neq_gamma=%s\n"
                  uu____1950 uu____1951 uu____1952 in
              fail uu____1949)
       | uu____1954 ->
           let goals =
             let uu____1957 =
               FStar_All.pipe_right p.goals
                 (FStar_List.map
                    (fun x  -> FStar_Syntax_Print.term_to_string x.goal_ty)) in
             FStar_All.pipe_right uu____1957 (FStar_String.concat "\n\t") in
           let uu____1963 =
             FStar_Util.format1
               "Cannot merge sub-goals: not enough sub-goals\n\tGoals are: %s"
               goals in
           fail uu____1963)
let rec visit: Prims.unit tac -> Prims.unit tac =
  fun callback  ->
    let uu____1971 =
      let uu____1973 =
        with_cur_goal "visit_strengthen_else"
          (fun goal  ->
             let uu____1976 =
               FStar_Syntax_Util.destruct_typ_as_formula goal.goal_ty in
             match uu____1976 with
             | None  ->
                 let uu____1979 =
                   let uu____1980 = FStar_Syntax_Subst.compress goal.goal_ty in
                   uu____1980.FStar_Syntax_Syntax.n in
                 (match uu____1979 with
                  | FStar_Syntax_Syntax.Tm_meta uu____1984 ->
                      let uu____1989 = visit callback in map_meta uu____1989
                  | uu____1991 ->
                      let uu____1992 =
                        FStar_All.pipe_left mlog
                          (fun uu____1997  ->
                             let uu____1998 =
                               FStar_Syntax_Print.term_to_string goal.goal_ty in
                             FStar_Util.print1
                               "Not a formula, split to smt %s\n" uu____1998) in
                      bind uu____1992 (fun uu____1999  -> smt))
             | Some (FStar_Syntax_Util.QEx uu____2000) ->
                 let uu____2004 =
                   FStar_All.pipe_left mlog
                     (fun uu____2009  ->
                        let uu____2010 =
                          FStar_Syntax_Print.term_to_string goal.goal_ty in
                        FStar_Util.print1
                          "Not yet handled: exists\n\tGoal is %s\n"
                          uu____2010) in
                 bind uu____2004 (fun uu____2011  -> ret ())
             | Some (FStar_Syntax_Util.QAll (xs,uu____2013,uu____2014)) ->
                 bind intros
                   (fun binders  ->
                      let uu____2016 = visit callback in
                      let uu____2018 =
                        let uu____2020 =
                          let uu____2022 = FStar_List.map Prims.fst binders in
                          revert_all_hd uu____2022 in
                        bind uu____2020
                          (fun uu____2026  ->
                             with_cur_goal "inner"
                               (fun goal1  ->
                                  let uu____2028 =
                                    FStar_All.pipe_left mlog
                                      (fun uu____2033  ->
                                         let uu____2034 =
                                           goal_to_string goal1 in
                                         FStar_Util.print1
                                           "After reverting intros, goal is %s\n"
                                           uu____2034) in
                                  bind uu____2028 (fun uu____2035  -> ret ()))) in
                      seq uu____2016 uu____2018)
             | Some (FStar_Syntax_Util.BaseConn (l,uu____2037)) when
                 FStar_Ident.lid_equals l FStar_Syntax_Const.and_lid ->
                 let uu____2038 =
                   let uu____2040 = visit callback in seq split uu____2040 in
                 bind uu____2038 (fun uu____2042  -> merge_sub_goals)
             | Some (FStar_Syntax_Util.BaseConn (l,uu____2044)) when
                 FStar_Ident.lid_equals l FStar_Syntax_Const.imp_lid ->
                 bind imp_intro
                   (fun h  ->
                      let uu____2046 = visit callback in
                      seq uu____2046 revert)
             | Some (FStar_Syntax_Util.BaseConn (l,uu____2049)) ->
                 or_else trivial smt) in
      or_else callback uu____1973 in
    focus_cur_goal "visit_strengthen" uu____1971
type order =
  | Lt
  | Eq
  | Gt
let uu___is_Lt: order -> Prims.bool =
  fun projectee  -> match projectee with | Lt  -> true | uu____2053 -> false
let uu___is_Eq: order -> Prims.bool =
  fun projectee  -> match projectee with | Eq  -> true | uu____2057 -> false
let uu___is_Gt: order -> Prims.bool =
  fun projectee  -> match projectee with | Gt  -> true | uu____2061 -> false
let order_binder:
  FStar_Syntax_Syntax.binder -> FStar_Syntax_Syntax.binder -> order =
  fun x  ->
    fun y  ->
      let n1 = FStar_Syntax_Syntax.order_bv (Prims.fst x) (Prims.fst y) in
      if n1 < (Prims.parse_int "0")
      then Lt
      else if n1 = (Prims.parse_int "0") then Eq else Gt
let proofstate_of_goal_ty:
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.term -> proofstate =
  fun env  ->
    fun g  ->
      let g1 =
        let uu____2078 =
          FStar_TypeChecker_Normalize.normalize
            [FStar_TypeChecker_Normalize.Beta] env g in
        { context = env; witness = None; goal_ty = uu____2078 } in
      let uu____2079 = FStar_Unionfind.new_transaction () in
      {
        main_context = env;
        main_goal = g1;
        all_implicits = [];
        goals = [g1];
        smt_goals = [];
        transaction = uu____2079
      }