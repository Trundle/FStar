open Prims
type name = FStar_Syntax_Syntax.bv
let remove_unit f x = f x ()
let binders_of_env:
  FStar_Tactics_Basic.proofstate ->
    FStar_Ident.lid ->
      FStar_Syntax_Syntax.args -> FStar_Syntax_Syntax.term Prims.option
  =
  fun ps  ->
    fun nm  ->
      fun args  ->
        match args with
        | (embedded_env,uu____37)::[] ->
            let env =
              FStar_Tactics_Embedding.unembed_env
                ps.FStar_Tactics_Basic.main_context embedded_env in
            let uu____51 =
              let uu____52 = FStar_TypeChecker_Env.all_binders env in
              FStar_Tactics_Embedding.embed_binders uu____52 in
            Some uu____51
        | uu____54 -> None
let type_of_binder:
  FStar_Ident.lid ->
    FStar_Syntax_Syntax.args -> FStar_Syntax_Syntax.term Prims.option
  =
  fun nm  ->
    fun args  ->
      match args with
      | (embedded_binder,uu____64)::[] ->
          let uu____77 =
            FStar_Tactics_Embedding.unembed_binder embedded_binder in
          (match uu____77 with
           | (b,uu____80) ->
               let uu____81 =
                 FStar_Tactics_Embedding.embed_term
                   b.FStar_Syntax_Syntax.sort in
               Some uu____81)
      | uu____82 -> None
let term_eq:
  FStar_Ident.lid ->
    FStar_Syntax_Syntax.args -> FStar_Syntax_Syntax.term Prims.option
  =
  fun nm  ->
    fun args  ->
      match args with
      | (embedded_t1,uu____92)::(embedded_t2,uu____94)::[] ->
          let t1 = FStar_Tactics_Embedding.unembed_term embedded_t1 in
          let t2 = FStar_Tactics_Embedding.unembed_term embedded_t2 in
          let uu____117 = FStar_Syntax_Util.eq_tm t1 t2 in
          (match uu____117 with
           | FStar_Syntax_Util.Equal  ->
               let uu____119 = FStar_Tactics_Embedding.embed_bool true in
               Some uu____119
           | uu____120 ->
               let uu____121 = FStar_Tactics_Embedding.embed_bool false in
               Some uu____121)
      | uu____122 -> None
let mk_pure_interpretation_1 f unembed_a embed_b nm args =
  (let uu____169 = FStar_ST.read FStar_Tactics_Basic.tacdbg in
   if uu____169
   then
     let uu____172 = FStar_Ident.string_of_lid nm in
     let uu____173 = FStar_Syntax_Print.args_to_string args in
     FStar_Util.print2 "Reached %s, args are: %s\n" uu____172 uu____173
   else ());
  (match args with
   | a::[] ->
       let uu____189 =
         let uu____190 =
           let uu____191 = unembed_a (Prims.fst a) in f uu____191 in
         embed_b uu____190 in
       Some uu____189
   | uu____194 -> failwith "Unexpected interpretation of pure primitive")
let mk_tactic_interpretation_0 ps t embed_a t_a nm args =
  match args with
  | (embedded_state,uu____237)::[] ->
      ((let uu____251 = FStar_ST.read FStar_Tactics_Basic.tacdbg in
        if uu____251
        then
          let uu____254 = FStar_Ident.string_of_lid nm in
          let uu____255 = FStar_Syntax_Print.args_to_string args in
          FStar_Util.print2 "Reached %s, args are: %s\n" uu____254 uu____255
        else ());
       (let uu____257 =
          FStar_Tactics_Embedding.unembed_state
            ps.FStar_Tactics_Basic.main_context embedded_state in
        match uu____257 with
        | (goals,smt_goals) ->
            let ps1 =
              let uu___108_266 = ps in
              {
                FStar_Tactics_Basic.main_context =
                  (uu___108_266.FStar_Tactics_Basic.main_context);
                FStar_Tactics_Basic.main_goal =
                  (uu___108_266.FStar_Tactics_Basic.main_goal);
                FStar_Tactics_Basic.all_implicits =
                  (uu___108_266.FStar_Tactics_Basic.all_implicits);
                FStar_Tactics_Basic.goals = goals;
                FStar_Tactics_Basic.smt_goals = smt_goals;
                FStar_Tactics_Basic.transaction =
                  (uu___108_266.FStar_Tactics_Basic.transaction)
              } in
            let res = FStar_Tactics_Basic.run t ps1 in
            let uu____269 =
              FStar_Tactics_Embedding.embed_result res embed_a t_a in
            Some uu____269))
  | uu____270 -> failwith "Unexpected application of tactic primitive"
let mk_tactic_interpretation_1 ps t unembed_b embed_a t_a nm args =
  match args with
  | (b,uu____330)::(embedded_state,uu____332)::[] ->
      ((let uu____354 = FStar_ST.read FStar_Tactics_Basic.tacdbg in
        if uu____354
        then
          let uu____357 = FStar_Ident.string_of_lid nm in
          let uu____358 = FStar_Syntax_Print.term_to_string embedded_state in
          FStar_Util.print2 "Reached %s, goals are: %s\n" uu____357 uu____358
        else ());
       (let uu____360 =
          FStar_Tactics_Embedding.unembed_state
            ps.FStar_Tactics_Basic.main_context embedded_state in
        match uu____360 with
        | (goals,smt_goals) ->
            let ps1 =
              let uu___109_369 = ps in
              {
                FStar_Tactics_Basic.main_context =
                  (uu___109_369.FStar_Tactics_Basic.main_context);
                FStar_Tactics_Basic.main_goal =
                  (uu___109_369.FStar_Tactics_Basic.main_goal);
                FStar_Tactics_Basic.all_implicits =
                  (uu___109_369.FStar_Tactics_Basic.all_implicits);
                FStar_Tactics_Basic.goals = goals;
                FStar_Tactics_Basic.smt_goals = smt_goals;
                FStar_Tactics_Basic.transaction =
                  (uu___109_369.FStar_Tactics_Basic.transaction)
              } in
            let res =
              let uu____372 = let uu____374 = unembed_b b in t uu____374 in
              FStar_Tactics_Basic.run uu____372 ps1 in
            let uu____375 =
              FStar_Tactics_Embedding.embed_result res embed_a t_a in
            Some uu____375))
  | uu____376 ->
      let uu____377 =
        let uu____378 = FStar_Ident.string_of_lid nm in
        let uu____379 = FStar_Syntax_Print.args_to_string args in
        FStar_Util.format2 "Unexpected application of tactic primitive %s %s"
          uu____378 uu____379 in
      failwith uu____377
let mk_tactic_interpretation_2 ps t unembed_a unembed_b embed_c t_c nm args =
  match args with
  | (a,uu____456)::(b,uu____458)::(embedded_state,uu____460)::[] ->
      ((let uu____490 = FStar_ST.read FStar_Tactics_Basic.tacdbg in
        if uu____490
        then
          let uu____493 = FStar_Ident.string_of_lid nm in
          let uu____494 = FStar_Syntax_Print.term_to_string embedded_state in
          FStar_Util.print2 "Reached %s, goals are: %s\n" uu____493 uu____494
        else ());
       (let uu____496 =
          FStar_Tactics_Embedding.unembed_state
            ps.FStar_Tactics_Basic.main_context embedded_state in
        match uu____496 with
        | (goals,smt_goals) ->
            let ps1 =
              let uu___110_505 = ps in
              {
                FStar_Tactics_Basic.main_context =
                  (uu___110_505.FStar_Tactics_Basic.main_context);
                FStar_Tactics_Basic.main_goal =
                  (uu___110_505.FStar_Tactics_Basic.main_goal);
                FStar_Tactics_Basic.all_implicits =
                  (uu___110_505.FStar_Tactics_Basic.all_implicits);
                FStar_Tactics_Basic.goals = goals;
                FStar_Tactics_Basic.smt_goals = smt_goals;
                FStar_Tactics_Basic.transaction =
                  (uu___110_505.FStar_Tactics_Basic.transaction)
              } in
            let res =
              let uu____508 =
                let uu____510 = unembed_a a in
                let uu____511 = unembed_b b in t uu____510 uu____511 in
              FStar_Tactics_Basic.run uu____508 ps1 in
            let uu____512 =
              FStar_Tactics_Embedding.embed_result res embed_c t_c in
            Some uu____512))
  | uu____513 ->
      let uu____514 =
        let uu____515 = FStar_Ident.string_of_lid nm in
        let uu____516 = FStar_Syntax_Print.args_to_string args in
        FStar_Util.format2 "Unexpected application of tactic primitive %s %s"
          uu____515 uu____516 in
      failwith uu____514
let grewrite_interpretation:
  FStar_Tactics_Basic.proofstate ->
    FStar_Ident.lid ->
      FStar_Syntax_Syntax.args -> FStar_Syntax_Syntax.term Prims.option
  =
  fun ps  ->
    fun nm  ->
      fun args  ->
        match args with
        | (et1,uu____531)::(et2,uu____533)::(embedded_state,uu____535)::[] ->
            let uu____564 =
              FStar_Tactics_Embedding.unembed_state
                ps.FStar_Tactics_Basic.main_context embedded_state in
            (match uu____564 with
             | (goals,smt_goals) ->
                 let ps1 =
                   let uu___111_573 = ps in
                   {
                     FStar_Tactics_Basic.main_context =
                       (uu___111_573.FStar_Tactics_Basic.main_context);
                     FStar_Tactics_Basic.main_goal =
                       (uu___111_573.FStar_Tactics_Basic.main_goal);
                     FStar_Tactics_Basic.all_implicits =
                       (uu___111_573.FStar_Tactics_Basic.all_implicits);
                     FStar_Tactics_Basic.goals = goals;
                     FStar_Tactics_Basic.smt_goals = smt_goals;
                     FStar_Tactics_Basic.transaction =
                       (uu___111_573.FStar_Tactics_Basic.transaction)
                   } in
                 let res =
                   let uu____576 =
                     let uu____578 =
                       FStar_Tactics_Embedding.type_of_embedded et1 in
                     let uu____579 =
                       FStar_Tactics_Embedding.type_of_embedded et2 in
                     let uu____580 = FStar_Tactics_Embedding.unembed_term et1 in
                     let uu____581 = FStar_Tactics_Embedding.unembed_term et2 in
                     FStar_Tactics_Basic.grewrite_impl uu____578 uu____579
                       uu____580 uu____581 in
                   FStar_Tactics_Basic.run uu____576 ps1 in
                 let uu____582 =
                   FStar_Tactics_Embedding.embed_result res
                     FStar_Tactics_Embedding.embed_unit
                     FStar_TypeChecker_Common.t_unit in
                 Some uu____582)
        | uu____583 ->
            let uu____584 =
              let uu____585 = FStar_Ident.string_of_lid nm in
              let uu____586 = FStar_Syntax_Print.args_to_string args in
              FStar_Util.format2
                "Unexpected application of tactic primitive %s %s" uu____585
                uu____586 in
            failwith uu____584
let rec primitive_steps:
  FStar_Tactics_Basic.proofstate ->
    FStar_TypeChecker_Normalize.primitive_step Prims.list
  =
  fun ps  ->
    let mk1 nm arity interpretation =
      let nm1 = FStar_Tactics_Embedding.fstar_tactics_lid nm in
      let uu____630 = interpretation nm1 in
      {
        FStar_TypeChecker_Normalize.name = nm1;
        FStar_TypeChecker_Normalize.arity = arity;
        FStar_TypeChecker_Normalize.strong_reduction_ok = false;
        FStar_TypeChecker_Normalize.interpretation = uu____630
      } in
    let uu____634 =
      mk1 "forall_intros_" (Prims.parse_int "1")
        (mk_tactic_interpretation_0 ps FStar_Tactics_Basic.intros
           FStar_Tactics_Embedding.embed_binders
           FStar_Tactics_Embedding.fstar_tactics_binders) in
    let uu____635 =
      let uu____637 =
        mk1 "implies_intro_" (Prims.parse_int "1")
          (mk_tactic_interpretation_0 ps FStar_Tactics_Basic.imp_intro
             FStar_Tactics_Embedding.embed_binder
             FStar_Tactics_Embedding.fstar_tactics_binder) in
      let uu____638 =
        let uu____640 =
          mk1 "trivial_" (Prims.parse_int "1")
            (mk_tactic_interpretation_0 ps FStar_Tactics_Basic.trivial
               FStar_Tactics_Embedding.embed_unit
               FStar_TypeChecker_Common.t_unit) in
        let uu____641 =
          let uu____643 =
            mk1 "revert_" (Prims.parse_int "1")
              (mk_tactic_interpretation_0 ps FStar_Tactics_Basic.revert
                 FStar_Tactics_Embedding.embed_unit
                 FStar_TypeChecker_Common.t_unit) in
          let uu____644 =
            let uu____646 =
              mk1 "clear_" (Prims.parse_int "1")
                (mk_tactic_interpretation_0 ps FStar_Tactics_Basic.clear
                   FStar_Tactics_Embedding.embed_unit
                   FStar_TypeChecker_Common.t_unit) in
            let uu____647 =
              let uu____649 =
                mk1 "split_" (Prims.parse_int "1")
                  (mk_tactic_interpretation_0 ps FStar_Tactics_Basic.split
                     FStar_Tactics_Embedding.embed_unit
                     FStar_TypeChecker_Common.t_unit) in
              let uu____650 =
                let uu____652 =
                  mk1 "merge_" (Prims.parse_int "1")
                    (mk_tactic_interpretation_0 ps
                       FStar_Tactics_Basic.merge_sub_goals
                       FStar_Tactics_Embedding.embed_unit
                       FStar_TypeChecker_Common.t_unit) in
                let uu____653 =
                  let uu____655 =
                    mk1 "rewrite_" (Prims.parse_int "2")
                      (mk_tactic_interpretation_1 ps
                         FStar_Tactics_Basic.rewrite
                         FStar_Tactics_Embedding.unembed_binder
                         FStar_Tactics_Embedding.embed_unit
                         FStar_TypeChecker_Common.t_unit) in
                  let uu____656 =
                    let uu____658 =
                      mk1 "smt_" (Prims.parse_int "1")
                        (mk_tactic_interpretation_0 ps
                           FStar_Tactics_Basic.smt
                           FStar_Tactics_Embedding.embed_unit
                           FStar_TypeChecker_Common.t_unit) in
                    let uu____659 =
                      let uu____661 =
                        mk1 "exact_" (Prims.parse_int "2")
                          (mk_tactic_interpretation_1 ps
                             FStar_Tactics_Basic.exact
                             FStar_Tactics_Embedding.unembed_term
                             FStar_Tactics_Embedding.embed_unit
                             FStar_TypeChecker_Common.t_unit) in
                      let uu____662 =
                        let uu____664 =
                          mk1 "apply_lemma_" (Prims.parse_int "2")
                            (mk_tactic_interpretation_1 ps
                               FStar_Tactics_Basic.apply_lemma
                               FStar_Tactics_Embedding.unembed_term
                               FStar_Tactics_Embedding.embed_unit
                               FStar_TypeChecker_Common.t_unit) in
                        let uu____665 =
                          let uu____667 =
                            mk1 "visit_" (Prims.parse_int "2")
                              (mk_tactic_interpretation_1 ps
                                 FStar_Tactics_Basic.visit
                                 (unembed_tactic_0
                                    FStar_Tactics_Embedding.unembed_unit)
                                 FStar_Tactics_Embedding.embed_unit
                                 FStar_TypeChecker_Common.t_unit) in
                          let uu____669 =
                            let uu____671 =
                              mk1 "focus_" (Prims.parse_int "2")
                                (mk_tactic_interpretation_1 ps
                                   (FStar_Tactics_Basic.focus_cur_goal
                                      "user_tactic")
                                   (unembed_tactic_0
                                      FStar_Tactics_Embedding.unembed_unit)
                                   FStar_Tactics_Embedding.embed_unit
                                   FStar_TypeChecker_Common.t_unit) in
                            let uu____673 =
                              let uu____675 =
                                mk1 "seq_" (Prims.parse_int "3")
                                  (mk_tactic_interpretation_2 ps
                                     FStar_Tactics_Basic.seq
                                     (unembed_tactic_0
                                        FStar_Tactics_Embedding.unembed_unit)
                                     (unembed_tactic_0
                                        FStar_Tactics_Embedding.unembed_unit)
                                     FStar_Tactics_Embedding.embed_unit
                                     FStar_TypeChecker_Common.t_unit) in
                              let uu____678 =
                                let uu____680 =
                                  mk1 "term_as_formula_"
                                    (Prims.parse_int "1")
                                    (mk_pure_interpretation_1
                                       FStar_Tactics_Embedding.term_as_formula
                                       FStar_Tactics_Embedding.unembed_term
                                       (FStar_Tactics_Embedding.embed_option
                                          FStar_Tactics_Embedding.embed_formula
                                          FStar_Tactics_Embedding.fstar_tactics_formula)) in
                                let uu____682 =
                                  let uu____684 =
                                    mk1 "inspect_" (Prims.parse_int "1")
                                      (mk_pure_interpretation_1
                                         FStar_Tactics_Embedding.inspect
                                         FStar_Tactics_Embedding.unembed_term
                                         FStar_Tactics_Embedding.embed_term_view) in
                                  let uu____685 =
                                    let uu____687 =
                                      mk1 "binders_of_env_"
                                        (Prims.parse_int "1")
                                        (binders_of_env ps) in
                                    let uu____688 =
                                      let uu____690 =
                                        mk1 "type_of_binder_"
                                          (Prims.parse_int "1")
                                          type_of_binder in
                                      let uu____691 =
                                        let uu____693 =
                                          mk1 "term_eq_"
                                            (Prims.parse_int "2") term_eq in
                                        let uu____694 =
                                          let uu____696 =
                                            mk1 "print_"
                                              (Prims.parse_int "2")
                                              (mk_tactic_interpretation_1 ps
                                                 FStar_Tactics_Basic.print_proof_state
                                                 FStar_Tactics_Embedding.unembed_string
                                                 FStar_Tactics_Embedding.embed_unit
                                                 FStar_TypeChecker_Common.t_unit) in
                                          let uu____697 =
                                            let uu____699 =
                                              mk1 "grewrite_"
                                                (Prims.parse_int "3")
                                                (grewrite_interpretation ps) in
                                            [uu____699] in
                                          uu____696 :: uu____697 in
                                        uu____693 :: uu____694 in
                                      uu____690 :: uu____691 in
                                    uu____687 :: uu____688 in
                                  uu____684 :: uu____685 in
                                uu____680 :: uu____682 in
                              uu____675 :: uu____678 in
                            uu____671 :: uu____673 in
                          uu____667 :: uu____669 in
                        uu____664 :: uu____665 in
                      uu____661 :: uu____662 in
                    uu____658 :: uu____659 in
                  uu____655 :: uu____656 in
                uu____652 :: uu____653 in
              uu____649 :: uu____650 in
            uu____646 :: uu____647 in
          uu____643 :: uu____644 in
        uu____640 :: uu____641 in
      uu____637 :: uu____638 in
    uu____634 :: uu____635
and unembed_tactic_0 unembed_b embedded_tac_b =
  FStar_Tactics_Basic.bind FStar_Tactics_Basic.get
    (fun proof_state  ->
       let tm =
         let uu____708 =
           let uu____709 =
             let uu____710 =
               let uu____711 =
                 FStar_Tactics_Embedding.embed_state
                   ((proof_state.FStar_Tactics_Basic.goals), []) in
               FStar_Syntax_Syntax.as_arg uu____711 in
             [uu____710] in
           FStar_Syntax_Syntax.mk_Tm_app embedded_tac_b uu____709 in
         uu____708 None FStar_Range.dummyRange in
       let steps =
         [FStar_TypeChecker_Normalize.Reify;
         FStar_TypeChecker_Normalize.Beta;
         FStar_TypeChecker_Normalize.UnfoldUntil
           FStar_Syntax_Syntax.Delta_constant;
         FStar_TypeChecker_Normalize.Zeta;
         FStar_TypeChecker_Normalize.Iota;
         FStar_TypeChecker_Normalize.Primops] in
       let uu____720 =
         FStar_All.pipe_left FStar_Tactics_Basic.mlog
           (fun uu____725  ->
              let uu____726 = FStar_Syntax_Print.term_to_string tm in
              FStar_Util.print1 "Starting normalizer with %s\n" uu____726) in
       FStar_Tactics_Basic.bind uu____720
         (fun uu____727  ->
            let result =
              let uu____729 = primitive_steps proof_state in
              FStar_TypeChecker_Normalize.normalize_with_primitive_steps
                uu____729 steps proof_state.FStar_Tactics_Basic.main_context
                tm in
            let uu____731 =
              FStar_All.pipe_left FStar_Tactics_Basic.mlog
                (fun uu____736  ->
                   let uu____737 = FStar_Syntax_Print.term_to_string result in
                   FStar_Util.print1 "Reduced tactic: got %s\n" uu____737) in
            FStar_Tactics_Basic.bind uu____731
              (fun uu____738  ->
                 let uu____739 =
                   FStar_Tactics_Embedding.unembed_result
                     proof_state.FStar_Tactics_Basic.main_context result
                     unembed_b in
                 match uu____739 with
                 | FStar_Util.Inl (b,(goals,smt_goals)) ->
                     FStar_Tactics_Basic.bind FStar_Tactics_Basic.dismiss
                       (fun uu____766  ->
                          let uu____767 = FStar_Tactics_Basic.add_goals goals in
                          FStar_Tactics_Basic.bind uu____767
                            (fun uu____769  ->
                               let uu____770 =
                                 FStar_Tactics_Basic.add_smt_goals smt_goals in
                               FStar_Tactics_Basic.bind uu____770
                                 (fun uu____772  -> FStar_Tactics_Basic.ret b)))
                 | FStar_Util.Inr (msg,(goals,smt_goals)) ->
                     FStar_Tactics_Basic.bind FStar_Tactics_Basic.dismiss
                       (fun uu____792  ->
                          let uu____793 = FStar_Tactics_Basic.add_goals goals in
                          FStar_Tactics_Basic.bind uu____793
                            (fun uu____795  ->
                               let uu____796 =
                                 FStar_Tactics_Basic.add_smt_goals smt_goals in
                               FStar_Tactics_Basic.bind uu____796
                                 (fun uu____798  ->
                                    FStar_Tactics_Basic.fail msg))))))
let evaluate_user_tactic: Prims.unit FStar_Tactics_Basic.tac =
  FStar_Tactics_Basic.with_cur_goal "evaluate_user_tactic"
    (fun goal  ->
       FStar_Tactics_Basic.bind FStar_Tactics_Basic.get
         (fun proof_state  ->
            let uu____802 =
              FStar_Syntax_Util.head_and_args
                goal.FStar_Tactics_Basic.goal_ty in
            match uu____802 with
            | (hd1,args) ->
                let uu____829 =
                  let uu____837 =
                    let uu____838 = FStar_Syntax_Util.un_uinst hd1 in
                    uu____838.FStar_Syntax_Syntax.n in
                  (uu____837, args) in
                (match uu____829 with
                 | (FStar_Syntax_Syntax.Tm_fvar
                    fv,(tactic,uu____849)::(assertion,uu____851)::[]) when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Tactics_Embedding.by_tactic_lid
                     ->
                     let uu____877 =
                       let uu____879 =
                         FStar_Tactics_Basic.replace_cur
                           (let uu___112_881 = goal in
                            {
                              FStar_Tactics_Basic.context =
                                (uu___112_881.FStar_Tactics_Basic.context);
                              FStar_Tactics_Basic.witness =
                                (uu___112_881.FStar_Tactics_Basic.witness);
                              FStar_Tactics_Basic.goal_ty = assertion
                            }) in
                       FStar_Tactics_Basic.bind uu____879
                         (fun uu____882  ->
                            unembed_tactic_0
                              FStar_Tactics_Embedding.unembed_unit tactic) in
                     FStar_Tactics_Basic.focus_cur_goal "user tactic"
                       uu____877
                 | uu____883 -> FStar_Tactics_Basic.fail "Not a user tactic")))
let by_tactic_interp:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term* FStar_Tactics_Basic.goal Prims.list)
  =
  fun e  ->
    fun t  ->
      let uu____903 = FStar_Syntax_Util.head_and_args t in
      match uu____903 with
      | (hd1,args) ->
          let uu____932 =
            let uu____940 =
              let uu____941 = FStar_Syntax_Util.un_uinst hd1 in
              uu____941.FStar_Syntax_Syntax.n in
            (uu____940, args) in
          (match uu____932 with
           | (FStar_Syntax_Syntax.Tm_fvar
              fv,(tactic,uu____954)::(assertion,uu____956)::[]) when
               FStar_Syntax_Syntax.fv_eq_lid fv
                 FStar_Tactics_Embedding.by_tactic_lid
               ->
               let uu____982 =
                 let uu____984 =
                   unembed_tactic_0 FStar_Tactics_Embedding.unembed_unit
                     tactic in
                 let uu____986 =
                   FStar_Tactics_Basic.proofstate_of_goal_ty e assertion in
                 FStar_Tactics_Basic.run uu____984 uu____986 in
               (match uu____982 with
                | FStar_Tactics_Basic.Success (uu____990,ps) ->
                    (FStar_Syntax_Util.t_true,
                      (FStar_List.append ps.FStar_Tactics_Basic.goals
                         ps.FStar_Tactics_Basic.smt_goals))
                | FStar_Tactics_Basic.Failed (s,ps) ->
                    Prims.raise
                      (FStar_Errors.Error
                         ((Prims.strcat "user tactic failed: \""
                             (Prims.strcat s "\"")),
                           (tactic.FStar_Syntax_Syntax.pos))))
           | uu____998 -> (t, []))
let rec traverse:
  (FStar_TypeChecker_Env.env ->
     FStar_Syntax_Syntax.term ->
       (FStar_Syntax_Syntax.term* FStar_Tactics_Basic.goal Prims.list))
    ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term ->
        (FStar_Syntax_Syntax.term* FStar_Tactics_Basic.goal Prims.list)
  =
  fun f  ->
    fun e  ->
      fun t  ->
        let uu____1038 =
          let uu____1042 =
            let uu____1043 = FStar_Syntax_Subst.compress t in
            uu____1043.FStar_Syntax_Syntax.n in
          match uu____1042 with
          | FStar_Syntax_Syntax.Tm_uinst (t1,us) ->
              let uu____1055 = traverse f e t1 in
              (match uu____1055 with
               | (t',gs) -> ((FStar_Syntax_Syntax.Tm_uinst (t', us)), gs))
          | FStar_Syntax_Syntax.Tm_meta (t1,m) ->
              let uu____1073 = traverse f e t1 in
              (match uu____1073 with
               | (t',gs) -> ((FStar_Syntax_Syntax.Tm_meta (t', m)), gs))
          | FStar_Syntax_Syntax.Tm_app
              ({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv;
                 FStar_Syntax_Syntax.tk = uu____1086;
                 FStar_Syntax_Syntax.pos = uu____1087;
                 FStar_Syntax_Syntax.vars = uu____1088;_},(p,uu____1090)::
               (q,uu____1092)::[])
              when
              FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.imp_lid ->
              let x = FStar_Syntax_Syntax.new_bv None p in
              let uu____1123 =
                let uu____1127 = FStar_TypeChecker_Env.push_bv e x in
                traverse f uu____1127 q in
              (match uu____1123 with
               | (q',gs) ->
                   let uu____1135 =
                     let uu____1136 = FStar_Syntax_Util.mk_imp p q' in
                     uu____1136.FStar_Syntax_Syntax.n in
                   (uu____1135, gs))
          | FStar_Syntax_Syntax.Tm_app (hd1,args) ->
              let uu____1156 = traverse f e hd1 in
              (match uu____1156 with
               | (hd',gs1) ->
                   let uu____1167 =
                     FStar_List.fold_right
                       (fun uu____1182  ->
                          fun uu____1183  ->
                            match (uu____1182, uu____1183) with
                            | ((a,q),(as',gs)) ->
                                let uu____1226 = traverse f e a in
                                (match uu____1226 with
                                 | (a',gs') ->
                                     (((a', q) :: as'),
                                       (FStar_List.append gs gs')))) args
                       ([], []) in
                   (match uu____1167 with
                    | (as',gs2) ->
                        ((FStar_Syntax_Syntax.Tm_app (hd', as')),
                          (FStar_List.append gs1 gs2))))
          | FStar_Syntax_Syntax.Tm_abs (bs,t1,k) ->
              let uu____1294 = FStar_Syntax_Subst.open_term bs t1 in
              (match uu____1294 with
               | (bs1,topen) ->
                   let e' = FStar_TypeChecker_Env.push_binders e bs1 in
                   let uu____1303 = traverse f e' topen in
                   (match uu____1303 with
                    | (topen',gs) ->
                        let uu____1314 =
                          let uu____1315 = FStar_Syntax_Util.abs bs1 topen' k in
                          uu____1315.FStar_Syntax_Syntax.n in
                        (uu____1314, gs)))
          | x -> (x, []) in
        match uu____1038 with
        | (tn',gs) ->
            let t' =
              let uu___113_1331 = t in
              {
                FStar_Syntax_Syntax.n = tn';
                FStar_Syntax_Syntax.tk =
                  (uu___113_1331.FStar_Syntax_Syntax.tk);
                FStar_Syntax_Syntax.pos =
                  (uu___113_1331.FStar_Syntax_Syntax.pos);
                FStar_Syntax_Syntax.vars =
                  (uu___113_1331.FStar_Syntax_Syntax.vars)
              } in
            let uu____1336 = f e t' in
            (match uu____1336 with
             | (t'1,gs') -> (t'1, (FStar_List.append gs gs')))
let preprocess:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      (FStar_TypeChecker_Env.env* FStar_Syntax_Syntax.term) Prims.list
  =
  fun env  ->
    fun goal  ->
      (let uu____1361 =
         FStar_TypeChecker_Env.debug env (FStar_Options.Other "Tac") in
       FStar_ST.write FStar_Tactics_Basic.tacdbg uu____1361);
      (let uu____1365 = FStar_ST.read FStar_Tactics_Basic.tacdbg in
       if uu____1365
       then
         let uu____1368 = FStar_Syntax_Print.term_to_string goal in
         FStar_Util.print1 "About to preprocess %s\n" uu____1368
       else ());
      (let initial = ((Prims.parse_int "1"), []) in
       let uu____1381 = traverse by_tactic_interp env goal in
       match uu____1381 with
       | (t',gs) ->
           ((let uu____1393 = FStar_ST.read FStar_Tactics_Basic.tacdbg in
             if uu____1393
             then
               let uu____1396 =
                 let uu____1397 = FStar_TypeChecker_Env.all_binders env in
                 FStar_All.pipe_right uu____1397
                   (FStar_Syntax_Print.binders_to_string ", ") in
               let uu____1398 = FStar_Syntax_Print.term_to_string t' in
               FStar_Util.print2 "Main goal simplified to: %s |- %s\n"
                 uu____1396 uu____1398
             else ());
            (let s = initial in
             let s1 =
               FStar_List.fold_left
                 (fun uu____1417  ->
                    fun g  ->
                      match uu____1417 with
                      | (n1,gs1) ->
                          ((let uu____1438 =
                              FStar_ST.read FStar_Tactics_Basic.tacdbg in
                            if uu____1438
                            then
                              let uu____1441 = FStar_Util.string_of_int n1 in
                              let uu____1442 =
                                FStar_Tactics_Basic.goal_to_string g in
                              FStar_Util.print2 "Got goal #%s: %s\n"
                                uu____1441 uu____1442
                            else ());
                           (let gt' =
                              let uu____1445 =
                                let uu____1446 = FStar_Util.string_of_int n1 in
                                Prims.strcat "Goal #" uu____1446 in
                              FStar_TypeChecker_Util.label uu____1445
                                FStar_Range.dummyRange
                                g.FStar_Tactics_Basic.goal_ty in
                            ((n1 + (Prims.parse_int "1")),
                              (((g.FStar_Tactics_Basic.context), gt') ::
                              gs1))))) s gs in
             let uu____1452 = s1 in
             match uu____1452 with | (uu____1461,gs1) -> (env, t') :: gs1)))