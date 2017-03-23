open Prims
type debug_level_t =
  | Low 
  | Medium 
  | High 
  | Extreme 
  | Other of Prims.string 
let uu___is_Low : debug_level_t -> Prims.bool =
  fun projectee  -> match projectee with | Low  -> true | uu____7 -> false 
let uu___is_Medium : debug_level_t -> Prims.bool =
  fun projectee  ->
    match projectee with | Medium  -> true | uu____11 -> false
  
let uu___is_High : debug_level_t -> Prims.bool =
  fun projectee  -> match projectee with | High  -> true | uu____15 -> false 
let uu___is_Extreme : debug_level_t -> Prims.bool =
  fun projectee  ->
    match projectee with | Extreme  -> true | uu____19 -> false
  
let uu___is_Other : debug_level_t -> Prims.bool =
  fun projectee  ->
    match projectee with | Other _0 -> true | uu____24 -> false
  
let __proj__Other__item___0 : debug_level_t -> Prims.string =
  fun projectee  -> match projectee with | Other _0 -> _0 
type option_val =
  | Bool of Prims.bool 
  | String of Prims.string 
  | Int of Prims.int 
  | List of option_val Prims.list 
  | Unset 
let uu___is_Bool : option_val -> Prims.bool =
  fun projectee  ->
    match projectee with | Bool _0 -> true | uu____49 -> false
  
let __proj__Bool__item___0 : option_val -> Prims.bool =
  fun projectee  -> match projectee with | Bool _0 -> _0 
let uu___is_String : option_val -> Prims.bool =
  fun projectee  ->
    match projectee with | String _0 -> true | uu____61 -> false
  
let __proj__String__item___0 : option_val -> Prims.string =
  fun projectee  -> match projectee with | String _0 -> _0 
let uu___is_Int : option_val -> Prims.bool =
  fun projectee  -> match projectee with | Int _0 -> true | uu____73 -> false 
let __proj__Int__item___0 : option_val -> Prims.int =
  fun projectee  -> match projectee with | Int _0 -> _0 
let uu___is_List : option_val -> Prims.bool =
  fun projectee  ->
    match projectee with | List _0 -> true | uu____86 -> false
  
let __proj__List__item___0 : option_val -> option_val Prims.list =
  fun projectee  -> match projectee with | List _0 -> _0 
let uu___is_Unset : option_val -> Prims.bool =
  fun projectee  ->
    match projectee with | Unset  -> true | uu____100 -> false
  
type options =
  | Set 
  | Reset 
  | Restore 
let uu___is_Set : options -> Prims.bool =
  fun projectee  -> match projectee with | Set  -> true | uu____104 -> false 
let uu___is_Reset : options -> Prims.bool =
  fun projectee  ->
    match projectee with | Reset  -> true | uu____108 -> false
  
let uu___is_Restore : options -> Prims.bool =
  fun projectee  ->
    match projectee with | Restore  -> true | uu____112 -> false
  
let __unit_tests__ : Prims.bool FStar_ST.ref = FStar_Util.mk_ref false 
let __unit_tests : Prims.unit -> Prims.bool =
  fun uu____118  -> FStar_ST.read __unit_tests__ 
let __set_unit_tests : Prims.unit -> Prims.unit =
  fun uu____123  -> FStar_ST.write __unit_tests__ true 
let __clear_unit_tests : Prims.unit -> Prims.unit =
  fun uu____128  -> FStar_ST.write __unit_tests__ false 
let as_bool : option_val -> Prims.bool =
  fun uu___45_133  ->
    match uu___45_133 with
    | Bool b -> b
    | uu____135 -> failwith "Impos: expected Bool"
  
let as_int : option_val -> Prims.int =
  fun uu___46_138  ->
    match uu___46_138 with
    | Int b -> b
    | uu____140 -> failwith "Impos: expected Int"
  
let as_string : option_val -> Prims.string =
  fun uu___47_143  ->
    match uu___47_143 with
    | String b -> b
    | uu____145 -> failwith "Impos: expected String"
  
let as_list as_t uu___48_161 =
  match uu___48_161 with
  | List ts -> FStar_All.pipe_right ts (FStar_List.map as_t)
  | uu____168 -> failwith "Impos: expected List" 
let as_option as_t uu___49_185 =
  match uu___49_185 with
  | Unset  -> None
  | v1 -> let uu____189 = as_t v1  in Some uu____189 
let fstar_options : option_val FStar_Util.smap Prims.list FStar_ST.ref =
  FStar_Util.mk_ref [] 
let peek : Prims.unit -> option_val FStar_Util.smap =
  fun uu____201  ->
    let uu____202 = FStar_ST.read fstar_options  in FStar_List.hd uu____202
  
let pop : Prims.unit -> Prims.unit =
  fun uu____212  ->
    let uu____213 = FStar_ST.read fstar_options  in
    match uu____213 with
    | []|_::[] -> failwith "TOO MANY POPS!"
    | uu____224::tl1 -> FStar_ST.write fstar_options tl1
  
let push : Prims.unit -> Prims.unit =
  fun uu____236  ->
    let uu____237 =
      let uu____240 =
        let uu____242 = peek ()  in FStar_Util.smap_copy uu____242  in
      let uu____244 = FStar_ST.read fstar_options  in uu____240 :: uu____244
       in
    FStar_ST.write fstar_options uu____237
  
let set_option : Prims.string -> option_val -> Prims.unit =
  fun k  ->
    fun v1  -> let uu____262 = peek ()  in FStar_Util.smap_add uu____262 k v1
  
let set_option' : (Prims.string * option_val) -> Prims.unit =
  fun uu____268  -> match uu____268 with | (k,v1) -> set_option k v1 
let light_off_files : Prims.string Prims.list FStar_ST.ref =
  FStar_Util.mk_ref [] 
let add_light_off_file : Prims.string -> Prims.unit =
  fun filename  ->
    let uu____281 =
      let uu____283 = FStar_ST.read light_off_files  in filename :: uu____283
       in
    FStar_ST.write light_off_files uu____281
  
let init : Prims.unit -> Prims.unit =
  fun uu____293  ->
    let vals =
      [("__temp_no_proj", (List []));
      ("_fstar_home", (String ""));
      ("_include_path", (List []));
      ("admit_smt_queries", (Bool false));
      ("cardinality", (String "off"));
      ("codegen", Unset);
      ("codegen-lib", (List []));
      ("debug", (List []));
      ("debug_level", (List []));
      ("dep", Unset);
      ("detail_errors", (Bool false));
      ("doc", (Bool false));
      ("dump_module", (List []));
      ("eager_inference", (Bool false));
      ("explicit_deps", (Bool false));
      ("extract_all", (Bool false));
      ("extract_module", (List []));
      ("extract_namespace", (List []));
      ("fs_typ_app", (Bool false));
      ("fsi", (Bool false));
      ("fstar_home", Unset);
      ("full_context_dependency", (Bool true));
      ("hide_genident_nums", (Bool false));
      ("hide_uvar_nums", (Bool false));
      ("hint_info", (Bool false));
      ("in", (Bool false));
      ("include", (List []));
      ("indent", (Bool false));
      ("initial_fuel", (Int (Prims.parse_int "2")));
      ("initial_ifuel", (Int (Prims.parse_int "1")));
      ("inline_arith", (Bool false));
      ("lax", (Bool false));
      ("log_queries", (Bool false));
      ("log_types", (Bool false));
      ("max_fuel", (Int (Prims.parse_int "8")));
      ("max_ifuel", (Int (Prims.parse_int "2")));
      ("min_fuel", (Int (Prims.parse_int "1")));
      ("MLish", (Bool false));
      ("n_cores", (Int (Prims.parse_int "1")));
      ("no_default_includes", (Bool false));
      ("no_extract", (List []));
      ("no_location_info", (Bool false));
      ("no_warn_top_level_effects", (Bool true));
      ("odir", Unset);
      ("prims", Unset);
      ("pretype", (Bool true));
      ("prims_ref", Unset);
      ("print_before_norm", (Bool false));
      ("print_bound_var_types", (Bool false));
      ("print_effect_args", (Bool false));
      ("print_fuels", (Bool false));
      ("print_implicits", (Bool false));
      ("print_universes", (Bool false));
      ("print_z3_statistics", (Bool false));
      ("prn", (Bool false));
      ("record_hints", (Bool false));
      ("reuse_hint_for", Unset);
      ("show_signatures", (List []));
      ("silent", (Bool false));
      ("smt", Unset);
      ("split_cases", (Int (Prims.parse_int "0")));
      ("timing", (Bool false));
      ("trace_error", (Bool false));
      ("unthrottle_inductives", (Bool false));
      ("use_eq_at_higher_order", (Bool false));
      ("use_hints", (Bool false));
      ("verify", (Bool true));
      ("verify_all", (Bool false));
      ("verify_module", (List []));
      ("warn_default_effects", (Bool false));
      ("z3refresh", (Bool false));
      ("z3rlimit", (Int (Prims.parse_int "5")));
      ("z3seed", (Int (Prims.parse_int "0")));
      ("z3timeout", (Int (Prims.parse_int "5")));
      ("z3cliopt", (List []));
      ("__no_positivity", (Bool false))]  in
    let o = peek ()  in
    FStar_Util.smap_clear o;
    FStar_All.pipe_right vals (FStar_List.iter set_option')
  
let clear : Prims.unit -> Prims.unit =
  fun uu____462  ->
    let o = FStar_Util.smap_create (Prims.parse_int "50")  in
    FStar_ST.write fstar_options [o];
    FStar_ST.write light_off_files [];
    init ()
  
let _run : Prims.unit = clear () 
let lookup_opt s c =
  let uu____493 =
    let uu____495 = peek ()  in FStar_Util.smap_try_find uu____495 s  in
  match uu____493 with
  | None  ->
      failwith
        (Prims.strcat "Impossible: option " (Prims.strcat s " not found"))
  | Some s1 -> c s1 
let get_admit_smt_queries : Prims.unit -> Prims.bool =
  fun uu____500  -> lookup_opt "admit_smt_queries" as_bool 
let get_cardinality : Prims.unit -> Prims.string =
  fun uu____503  -> lookup_opt "cardinality" as_string 
let get_codegen : Prims.unit -> Prims.string Prims.option =
  fun uu____507  -> lookup_opt "codegen" (as_option as_string) 
let get_codegen_lib : Prims.unit -> Prims.string Prims.list =
  fun uu____512  -> lookup_opt "codegen-lib" (as_list as_string) 
let get_debug : Prims.unit -> Prims.string Prims.list =
  fun uu____517  -> lookup_opt "debug" (as_list as_string) 
let get_debug_level : Prims.unit -> Prims.string Prims.list =
  fun uu____522  -> lookup_opt "debug_level" (as_list as_string) 
let get_dep : Prims.unit -> Prims.string Prims.option =
  fun uu____527  -> lookup_opt "dep" (as_option as_string) 
let get_detail_errors : Prims.unit -> Prims.bool =
  fun uu____531  -> lookup_opt "detail_errors" as_bool 
let get_doc : Prims.unit -> Prims.bool =
  fun uu____534  -> lookup_opt "doc" as_bool 
let get_dump_module : Prims.unit -> Prims.string Prims.list =
  fun uu____538  -> lookup_opt "dump_module" (as_list as_string) 
let get_eager_inference : Prims.unit -> Prims.bool =
  fun uu____542  -> lookup_opt "eager_inference" as_bool 
let get_explicit_deps : Prims.unit -> Prims.bool =
  fun uu____545  -> lookup_opt "explicit_deps" as_bool 
let get_extract_all : Prims.unit -> Prims.bool =
  fun uu____548  -> lookup_opt "extract_all" as_bool 
let get_extract_module : Prims.unit -> Prims.string Prims.list =
  fun uu____552  -> lookup_opt "extract_module" (as_list as_string) 
let get_extract_namespace : Prims.unit -> Prims.string Prims.list =
  fun uu____557  -> lookup_opt "extract_namespace" (as_list as_string) 
let get_fs_typ_app : Prims.unit -> Prims.bool =
  fun uu____561  -> lookup_opt "fs_typ_app" as_bool 
let get_fstar_home : Prims.unit -> Prims.string Prims.option =
  fun uu____565  -> lookup_opt "fstar_home" (as_option as_string) 
let get_hide_genident_nums : Prims.unit -> Prims.bool =
  fun uu____569  -> lookup_opt "hide_genident_nums" as_bool 
let get_hide_uvar_nums : Prims.unit -> Prims.bool =
  fun uu____572  -> lookup_opt "hide_uvar_nums" as_bool 
let get_hint_info : Prims.unit -> Prims.bool =
  fun uu____575  -> lookup_opt "hint_info" as_bool 
let get_in : Prims.unit -> Prims.bool =
  fun uu____578  -> lookup_opt "in" as_bool 
let get_include : Prims.unit -> Prims.string Prims.list =
  fun uu____582  -> lookup_opt "include" (as_list as_string) 
let get_indent : Prims.unit -> Prims.bool =
  fun uu____586  -> lookup_opt "indent" as_bool 
let get_initial_fuel : Prims.unit -> Prims.int =
  fun uu____589  -> lookup_opt "initial_fuel" as_int 
let get_initial_ifuel : Prims.unit -> Prims.int =
  fun uu____592  -> lookup_opt "initial_ifuel" as_int 
let get_inline_arith : Prims.unit -> Prims.bool =
  fun uu____595  -> lookup_opt "inline_arith" as_bool 
let get_lax : Prims.unit -> Prims.bool =
  fun uu____598  -> lookup_opt "lax" as_bool 
let get_log_queries : Prims.unit -> Prims.bool =
  fun uu____601  -> lookup_opt "log_queries" as_bool 
let get_log_types : Prims.unit -> Prims.bool =
  fun uu____604  -> lookup_opt "log_types" as_bool 
let get_max_fuel : Prims.unit -> Prims.int =
  fun uu____607  -> lookup_opt "max_fuel" as_int 
let get_max_ifuel : Prims.unit -> Prims.int =
  fun uu____610  -> lookup_opt "max_ifuel" as_int 
let get_min_fuel : Prims.unit -> Prims.int =
  fun uu____613  -> lookup_opt "min_fuel" as_int 
let get_MLish : Prims.unit -> Prims.bool =
  fun uu____616  -> lookup_opt "MLish" as_bool 
let get_n_cores : Prims.unit -> Prims.int =
  fun uu____619  -> lookup_opt "n_cores" as_int 
let get_no_default_includes : Prims.unit -> Prims.bool =
  fun uu____622  -> lookup_opt "no_default_includes" as_bool 
let get_no_extract : Prims.unit -> Prims.string Prims.list =
  fun uu____626  -> lookup_opt "no_extract" (as_list as_string) 
let get_no_location_info : Prims.unit -> Prims.bool =
  fun uu____630  -> lookup_opt "no_location_info" as_bool 
let get_warn_top_level_effects : Prims.unit -> Prims.bool =
  fun uu____633  -> lookup_opt "no_warn_top_level_effects" as_bool 
let get_odir : Prims.unit -> Prims.string Prims.option =
  fun uu____637  -> lookup_opt "odir" (as_option as_string) 
let get_prims : Prims.unit -> Prims.string Prims.option =
  fun uu____642  -> lookup_opt "prims" (as_option as_string) 
let get_print_before_norm : Prims.unit -> Prims.bool =
  fun uu____646  -> lookup_opt "print_before_norm" as_bool 
let get_print_bound_var_types : Prims.unit -> Prims.bool =
  fun uu____649  -> lookup_opt "print_bound_var_types" as_bool 
let get_print_effect_args : Prims.unit -> Prims.bool =
  fun uu____652  -> lookup_opt "print_effect_args" as_bool 
let get_print_fuels : Prims.unit -> Prims.bool =
  fun uu____655  -> lookup_opt "print_fuels" as_bool 
let get_print_implicits : Prims.unit -> Prims.bool =
  fun uu____658  -> lookup_opt "print_implicits" as_bool 
let get_print_universes : Prims.unit -> Prims.bool =
  fun uu____661  -> lookup_opt "print_universes" as_bool 
let get_print_z3_statistics : Prims.unit -> Prims.bool =
  fun uu____664  -> lookup_opt "print_z3_statistics" as_bool 
let get_prn : Prims.unit -> Prims.bool =
  fun uu____667  -> lookup_opt "prn" as_bool 
let get_record_hints : Prims.unit -> Prims.bool =
  fun uu____670  -> lookup_opt "record_hints" as_bool 
let get_reuse_hint_for : Prims.unit -> Prims.string Prims.option =
  fun uu____674  -> lookup_opt "reuse_hint_for" (as_option as_string) 
let get_show_signatures : Prims.unit -> Prims.string Prims.list =
  fun uu____679  -> lookup_opt "show_signatures" (as_list as_string) 
let get_silent : Prims.unit -> Prims.bool =
  fun uu____683  -> lookup_opt "silent" as_bool 
let get_smt : Prims.unit -> Prims.string Prims.option =
  fun uu____687  -> lookup_opt "smt" (as_option as_string) 
let get_split_cases : Prims.unit -> Prims.int =
  fun uu____691  -> lookup_opt "split_cases" as_int 
let get_timing : Prims.unit -> Prims.bool =
  fun uu____694  -> lookup_opt "timing" as_bool 
let get_trace_error : Prims.unit -> Prims.bool =
  fun uu____697  -> lookup_opt "trace_error" as_bool 
let get_unthrottle_inductives : Prims.unit -> Prims.bool =
  fun uu____700  -> lookup_opt "unthrottle_inductives" as_bool 
let get_use_eq_at_higher_order : Prims.unit -> Prims.bool =
  fun uu____703  -> lookup_opt "use_eq_at_higher_order" as_bool 
let get_use_hints : Prims.unit -> Prims.bool =
  fun uu____706  -> lookup_opt "use_hints" as_bool 
let get_verify_all : Prims.unit -> Prims.bool =
  fun uu____709  -> lookup_opt "verify_all" as_bool 
let get_verify_module : Prims.unit -> Prims.string Prims.list =
  fun uu____713  -> lookup_opt "verify_module" (as_list as_string) 
let get___temp_no_proj : Prims.unit -> Prims.string Prims.list =
  fun uu____718  -> lookup_opt "__temp_no_proj" (as_list as_string) 
let get_version : Prims.unit -> Prims.bool =
  fun uu____722  -> lookup_opt "version" as_bool 
let get_warn_default_effects : Prims.unit -> Prims.bool =
  fun uu____725  -> lookup_opt "warn_default_effects" as_bool 
let get_z3cliopt : Prims.unit -> Prims.string Prims.list =
  fun uu____729  -> lookup_opt "z3cliopt" (as_list as_string) 
let get_z3refresh : Prims.unit -> Prims.bool =
  fun uu____733  -> lookup_opt "z3refresh" as_bool 
let get_z3rlimit : Prims.unit -> Prims.int =
  fun uu____736  -> lookup_opt "z3rlimit" as_int 
let get_z3seed : Prims.unit -> Prims.int =
  fun uu____739  -> lookup_opt "z3seed" as_int 
let get_z3timeout : Prims.unit -> Prims.int =
  fun uu____742  -> lookup_opt "z3timeout" as_int 
let get_no_positivity : Prims.unit -> Prims.bool =
  fun uu____745  -> lookup_opt "__no_positivity" as_bool 
let dlevel : Prims.string -> debug_level_t =
  fun uu___50_748  ->
    match uu___50_748 with
    | "Low" -> Low
    | "Medium" -> Medium
    | "High" -> High
    | "Extreme" -> Extreme
    | s -> Other s
  
let one_debug_level_geq : debug_level_t -> debug_level_t -> Prims.bool =
  fun l1  ->
    fun l2  ->
      match l1 with
      | Other _|Low  -> l1 = l2
      | Medium  -> (l2 = Low) || (l2 = Medium)
      | High  -> ((l2 = Low) || (l2 = Medium)) || (l2 = High)
      | Extreme  ->
          (((l2 = Low) || (l2 = Medium)) || (l2 = High)) || (l2 = Extreme)
  
let debug_level_geq : debug_level_t -> Prims.bool =
  fun l2  ->
    let uu____760 = get_debug_level ()  in
    FStar_All.pipe_right uu____760
      (FStar_Util.for_some (fun l1  -> one_debug_level_geq (dlevel l1) l2))
  
let include_path_base_dirs : Prims.string Prims.list = ["/lib"; "/lib/fstar"] 
let universe_include_path_base_dirs : Prims.string Prims.list =
  ["/ulib"; "/lib/fstar"] 
let _version : Prims.string FStar_ST.ref = FStar_Util.mk_ref "" 
let _platform : Prims.string FStar_ST.ref = FStar_Util.mk_ref "" 
let _compiler : Prims.string FStar_ST.ref = FStar_Util.mk_ref "" 
let _date : Prims.string FStar_ST.ref = FStar_Util.mk_ref "" 
let _commit : Prims.string FStar_ST.ref = FStar_Util.mk_ref "" 
let display_version : Prims.unit -> Prims.unit =
  fun uu____788  ->
    let uu____789 =
      let uu____790 = FStar_ST.read _version  in
      let uu____793 = FStar_ST.read _platform  in
      let uu____796 = FStar_ST.read _compiler  in
      let uu____799 = FStar_ST.read _date  in
      let uu____802 = FStar_ST.read _commit  in
      FStar_Util.format5
        "F* %s\nplatform=%s\ncompiler=%s\ndate=%s\ncommit=%s\n" uu____790
        uu____793 uu____796 uu____799 uu____802
       in
    FStar_Util.print_string uu____789
  
let display_usage_aux specs =
  FStar_Util.print_string "fstar.exe [options] file[s]\n";
  FStar_List.iter
    (fun uu____832  ->
       match uu____832 with
       | (uu____838,flag,p,doc) ->
           (match p with
            | FStar_Getopt.ZeroArgs ig ->
                if doc = ""
                then
                  let uu____847 =
                    let uu____848 = FStar_Util.colorize_bold flag  in
                    FStar_Util.format1 "  --%s\n" uu____848  in
                  FStar_Util.print_string uu____847
                else
                  (let uu____850 =
                     let uu____851 = FStar_Util.colorize_bold flag  in
                     FStar_Util.format2 "  --%s  %s\n" uu____851 doc  in
                   FStar_Util.print_string uu____850)
            | FStar_Getopt.OneArg (uu____852,argname) ->
                if doc = ""
                then
                  let uu____858 =
                    let uu____859 = FStar_Util.colorize_bold flag  in
                    let uu____860 = FStar_Util.colorize_bold argname  in
                    FStar_Util.format2 "  --%s %s\n" uu____859 uu____860  in
                  FStar_Util.print_string uu____858
                else
                  (let uu____862 =
                     let uu____863 = FStar_Util.colorize_bold flag  in
                     let uu____864 = FStar_Util.colorize_bold argname  in
                     FStar_Util.format3 "  --%s %s  %s\n" uu____863 uu____864
                       doc
                      in
                   FStar_Util.print_string uu____862))) specs
  
let mk_spec :
  (FStar_BaseTypes.char * Prims.string * option_val FStar_Getopt.opt_variant
    * Prims.string) -> FStar_Getopt.opt
  =
  fun o  ->
    let uu____878 = o  in
    match uu____878 with
    | (ns,name,arg,desc) ->
        let arg1 =
          match arg with
          | FStar_Getopt.ZeroArgs f ->
              let g uu____899 =
                let uu____900 = let uu____903 = f ()  in (name, uu____903)
                   in
                set_option' uu____900  in
              FStar_Getopt.ZeroArgs g
          | FStar_Getopt.OneArg (f,d) ->
              let g x =
                let uu____914 = let uu____917 = f x  in (name, uu____917)  in
                set_option' uu____914  in
              FStar_Getopt.OneArg (g, d)
           in
        (ns, name, arg1, desc)
  
let cons_extract_module : Prims.string -> option_val =
  fun s  ->
    let uu____924 =
      let uu____926 =
        let uu____928 = get_extract_module ()  in (FStar_String.lowercase s)
          :: uu____928
         in
      FStar_All.pipe_right uu____926
        (FStar_List.map (fun _0_25  -> String _0_25))
       in
    List uu____924
  
let cons_extract_namespace : Prims.string -> option_val =
  fun s  ->
    let uu____935 =
      let uu____937 =
        let uu____939 = get_extract_namespace ()  in
        (FStar_String.lowercase s) :: uu____939  in
      FStar_All.pipe_right uu____937
        (FStar_List.map (fun _0_26  -> String _0_26))
       in
    List uu____935
  
let add_extract_module : Prims.string -> Prims.unit =
  fun s  ->
    let uu____946 = cons_extract_module s  in
    set_option "extract_module" uu____946
  
let add_extract_namespace : Prims.string -> Prims.unit =
  fun s  ->
    let uu____950 = cons_extract_namespace s  in
    set_option "extract_namespace" uu____950
  
let cons_verify_module : Prims.string -> option_val =
  fun s  ->
    let uu____954 =
      let uu____956 =
        let uu____958 = get_verify_module ()  in (FStar_String.lowercase s)
          :: uu____958
         in
      FStar_All.pipe_right uu____956
        (FStar_List.map (fun _0_27  -> String _0_27))
       in
    List uu____954
  
let add_verify_module : Prims.string -> Prims.unit =
  fun s  ->
    let uu____965 = cons_verify_module s  in
    set_option "verify_module" uu____965
  
let rec specs :
  Prims.unit ->
    (FStar_Char.char * Prims.string * Prims.unit FStar_Getopt.opt_variant *
      Prims.string) Prims.list
  =
  fun uu____973  ->
    let specs1 =
      [(FStar_Getopt.noshort, "admit_smt_queries",
         (FStar_Getopt.OneArg
            (((fun s  ->
                 if s = "true"
                 then Bool true
                 else
                   if s = "false"
                   then Bool false
                   else failwith "Invalid argument to --admit_smt_queries")),
              "[true|false]")),
         "Admit SMT queries, unsafe! (default 'false')");
      (FStar_Getopt.noshort, "cardinality",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1002 = validate_cardinality x  in String uu____1002)),
             "[off|warn|check]")),
        "Check cardinality constraints on inductive data types (default 'off')");
      (FStar_Getopt.noshort, "codegen",
        (FStar_Getopt.OneArg
           (((fun s  ->
                let uu____1012 = parse_codegen s  in String uu____1012)),
             "[OCaml|FSharp|Kremlin]")), "Generate code for execution");
      (FStar_Getopt.noshort, "codegen-lib",
        (FStar_Getopt.OneArg
           (((fun s  ->
                let uu____1022 =
                  let uu____1024 =
                    let uu____1026 = get_codegen_lib ()  in s :: uu____1026
                     in
                  FStar_All.pipe_right uu____1024
                    (FStar_List.map (fun _0_28  -> String _0_28))
                   in
                List uu____1022)), "[namespace]")),
        "External runtime library (i.e. M.N.x extracts to M.N.X instead of M_N.x)");
      (FStar_Getopt.noshort, "debug",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1039 =
                  let uu____1041 =
                    let uu____1043 = get_debug ()  in x :: uu____1043  in
                  FStar_All.pipe_right uu____1041
                    (FStar_List.map (fun _0_29  -> String _0_29))
                   in
                List uu____1039)), "[module name]")),
        "Print lots of debugging information while checking module");
      (FStar_Getopt.noshort, "debug_level",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1056 =
                  let uu____1058 =
                    let uu____1060 = get_debug_level ()  in x :: uu____1060
                     in
                  FStar_All.pipe_right uu____1058
                    (FStar_List.map (fun _0_30  -> String _0_30))
                   in
                List uu____1056)), "[Low|Medium|High|Extreme|...]")),
        "Control the verbosity of debugging info");
      (FStar_Getopt.noshort, "dep",
        (FStar_Getopt.OneArg
           (((fun x  ->
                if (x = "make") || (x = "graph")
                then String x
                else failwith "invalid argument to 'dep'")), "[make|graph]")),
        "Output the transitive closure of the dependency graph in a format suitable for the given tool");
      (FStar_Getopt.noshort, "detail_errors",
        (FStar_Getopt.ZeroArgs ((fun uu____1080  -> Bool true))),
        "Emit a detailed error report by asking the SMT solver many queries; will take longer;\n         implies n_cores=1");
      (FStar_Getopt.noshort, "doc",
        (FStar_Getopt.ZeroArgs ((fun uu____1087  -> Bool true))),
        "Extract Markdown documentation files for the input modules, as well as an index. Output is written to --odir directory.");
      (FStar_Getopt.noshort, "dump_module",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1097 =
                  let uu____1099 =
                    let uu____1101 = get_dump_module ()  in x :: uu____1101
                     in
                  FStar_All.pipe_right uu____1099
                    (FStar_List.map (fun _0_31  -> String _0_31))
                   in
                FStar_All.pipe_right uu____1097 (fun _0_32  -> List _0_32))),
             "[module name]")), "");
      (FStar_Getopt.noshort, "eager_inference",
        (FStar_Getopt.ZeroArgs ((fun uu____1112  -> Bool true))),
        "Solve all type-inference constraints eagerly; more efficient but at the cost of generality");
      (FStar_Getopt.noshort, "explicit_deps",
        (FStar_Getopt.ZeroArgs ((fun uu____1119  -> Bool true))),
        "Do not find dependencies automatically, the user provides them on the command-line");
      (FStar_Getopt.noshort, "extract_all",
        (FStar_Getopt.ZeroArgs ((fun uu____1126  -> Bool true))),
        "Discover the complete dependency graph and do not stop at interface boundaries");
      (FStar_Getopt.noshort, "extract_module",
        (FStar_Getopt.OneArg (cons_extract_module, "[module name]")),
        "Only extract the specified modules (instead of the possibly-partial dependency graph)");
      (FStar_Getopt.noshort, "extract_namespace",
        (FStar_Getopt.OneArg (cons_extract_namespace, "[namespace name]")),
        "Only extract modules in the specified namespace");
      (FStar_Getopt.noshort, "fstar_home",
        (FStar_Getopt.OneArg (((fun _0_33  -> String _0_33)), "[dir]")),
        "Set the FSTAR_HOME variable to [dir]");
      (FStar_Getopt.noshort, "hide_genident_nums",
        (FStar_Getopt.ZeroArgs ((fun uu____1157  -> Bool true))),
        "Don't print generated identifier numbers");
      (FStar_Getopt.noshort, "hide_uvar_nums",
        (FStar_Getopt.ZeroArgs ((fun uu____1164  -> Bool true))),
        "Don't print unification variable numbers");
      (FStar_Getopt.noshort, "hint_info",
        (FStar_Getopt.ZeroArgs ((fun uu____1171  -> Bool true))),
        "Print information regarding hints");
      (FStar_Getopt.noshort, "in",
        (FStar_Getopt.ZeroArgs ((fun uu____1178  -> Bool true))),
        "Interactive mode; reads input from stdin");
      (FStar_Getopt.noshort, "include",
        (FStar_Getopt.OneArg
           (((fun s  ->
                let uu____1188 =
                  let uu____1190 =
                    let uu____1192 = get_include ()  in
                    FStar_List.append uu____1192 [s]  in
                  FStar_All.pipe_right uu____1190
                    (FStar_List.map (fun _0_34  -> String _0_34))
                   in
                List uu____1188)), "[path]")),
        "A directory in which to search for files included on the command line");
      (FStar_Getopt.noshort, "indent",
        (FStar_Getopt.ZeroArgs ((fun uu____1202  -> Bool true))),
        "Parses and outputs the files on the command line");
      (FStar_Getopt.noshort, "initial_fuel",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1212 = FStar_Util.int_of_string x  in
                Int uu____1212)), "[non-negative integer]")),
        "Number of unrolling of recursive functions to try initially (default 2)");
      (FStar_Getopt.noshort, "initial_ifuel",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1222 = FStar_Util.int_of_string x  in
                Int uu____1222)), "[non-negative integer]")),
        "Number of unrolling of inductive datatypes to try at first (default 1)");
      (FStar_Getopt.noshort, "inline_arith",
        (FStar_Getopt.ZeroArgs ((fun uu____1229  -> Bool true))),
        "Inline definitions of arithmetic functions in the SMT encoding");
      (FStar_Getopt.noshort, "lax",
        (FStar_Getopt.ZeroArgs ((fun uu____1236  -> Bool true))),
        "Run the lax-type checker only (admit all verification conditions)");
      (FStar_Getopt.noshort, "log_types",
        (FStar_Getopt.ZeroArgs ((fun uu____1243  -> Bool true))),
        "Print types computed for data/val/let-bindings");
      (FStar_Getopt.noshort, "log_queries",
        (FStar_Getopt.ZeroArgs ((fun uu____1250  -> Bool true))),
        "Log the Z3 queries in several queries-*.smt2 files, as we go");
      (FStar_Getopt.noshort, "max_fuel",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1260 = FStar_Util.int_of_string x  in
                Int uu____1260)), "[non-negative integer]")),
        "Number of unrolling of recursive functions to try at most (default 8)");
      (FStar_Getopt.noshort, "max_ifuel",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1270 = FStar_Util.int_of_string x  in
                Int uu____1270)), "[non-negative integer]")),
        "Number of unrolling of inductive datatypes to try at most (default 2)");
      (FStar_Getopt.noshort, "min_fuel",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1280 = FStar_Util.int_of_string x  in
                Int uu____1280)), "[non-negative integer]")),
        "Minimum number of unrolling of recursive functions to try (default 1)");
      (FStar_Getopt.noshort, "MLish",
        (FStar_Getopt.ZeroArgs ((fun uu____1287  -> Bool true))),
        "Trigger various specializations for compiling the F* compiler itself (not meant for user code)");
      (FStar_Getopt.noshort, "n_cores",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1297 = FStar_Util.int_of_string x  in
                Int uu____1297)), "[positive integer]")),
        "Maximum number of cores to use for the solver (implies detail_errors = false) (default 1)");
      (FStar_Getopt.noshort, "no_default_includes",
        (FStar_Getopt.ZeroArgs ((fun uu____1304  -> Bool true))),
        "Ignore the default module search paths");
      (FStar_Getopt.noshort, "no_extract",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1314 =
                  let uu____1316 =
                    let uu____1318 = get_no_extract ()  in x :: uu____1318
                     in
                  FStar_All.pipe_right uu____1316
                    (FStar_List.map (fun _0_35  -> String _0_35))
                   in
                List uu____1314)), "[module name]")),
        "Do not extract code from this module");
      (FStar_Getopt.noshort, "no_location_info",
        (FStar_Getopt.ZeroArgs ((fun uu____1328  -> Bool true))),
        "Suppress location information in the generated OCaml output (only relevant with --codegen OCaml)");
      (FStar_Getopt.noshort, "odir",
        (FStar_Getopt.OneArg (((fun _0_36  -> String _0_36)), "[dir]")),
        "Place output in directory [dir]");
      (FStar_Getopt.noshort, "prims",
        (FStar_Getopt.OneArg (((fun _0_37  -> String _0_37)), "file")), "");
      (FStar_Getopt.noshort, "print_before_norm",
        (FStar_Getopt.ZeroArgs ((fun uu____1351  -> Bool true))),
        "Do not normalize types before printing (for debugging)");
      (FStar_Getopt.noshort, "print_bound_var_types",
        (FStar_Getopt.ZeroArgs ((fun uu____1358  -> Bool true))),
        "Print the types of bound variables");
      (FStar_Getopt.noshort, "print_effect_args",
        (FStar_Getopt.ZeroArgs ((fun uu____1365  -> Bool true))),
        "Print inferred predicate transformers for all computation types");
      (FStar_Getopt.noshort, "print_fuels",
        (FStar_Getopt.ZeroArgs ((fun uu____1372  -> Bool true))),
        "Print the fuel amounts used for each successful query");
      (FStar_Getopt.noshort, "print_implicits",
        (FStar_Getopt.ZeroArgs ((fun uu____1379  -> Bool true))),
        "Print implicit arguments");
      (FStar_Getopt.noshort, "print_universes",
        (FStar_Getopt.ZeroArgs ((fun uu____1386  -> Bool true))),
        "Print universes");
      (FStar_Getopt.noshort, "print_z3_statistics",
        (FStar_Getopt.ZeroArgs ((fun uu____1393  -> Bool true))),
        "Print Z3 statistics for each SMT query");
      (FStar_Getopt.noshort, "prn",
        (FStar_Getopt.ZeroArgs ((fun uu____1400  -> Bool true))),
        "Print real names (you may want to use this in conjunction with log_queries)");
      (FStar_Getopt.noshort, "record_hints",
        (FStar_Getopt.ZeroArgs ((fun uu____1407  -> Bool true))),
        "Record a database of hints for efficient proof replay");
      (FStar_Getopt.noshort, "reuse_hint_for",
        (FStar_Getopt.OneArg
           (((fun _0_38  -> String _0_38)),
             "top-level name in the current module")),
        "Optimistically, attempt using the recorded hint for 'f' when trying to verify some other term 'g'");
      (FStar_Getopt.noshort, "show_signatures",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1425 =
                  let uu____1427 =
                    let uu____1429 = get_show_signatures ()  in x ::
                      uu____1429
                     in
                  FStar_All.pipe_right uu____1427
                    (FStar_List.map (fun _0_39  -> String _0_39))
                   in
                List uu____1425)), "[module name]")),
        "Show the checked signatures for all top-level symbols in the module");
      (FStar_Getopt.noshort, "silent",
        (FStar_Getopt.ZeroArgs ((fun uu____1439  -> Bool true))), " ");
      (FStar_Getopt.noshort, "smt",
        (FStar_Getopt.OneArg (((fun _0_40  -> String _0_40)), "[path]")),
        "Path to the SMT solver (usually Z3, but could be any SMT2-compatible solver)");
      (FStar_Getopt.noshort, "split_cases",
        (FStar_Getopt.OneArg
           (((fun n1  ->
                let uu____1457 = FStar_Util.int_of_string n1  in
                Int uu____1457)), "[positive integer]")),
        "Partition VC of a match into groups of [n] cases");
      (FStar_Getopt.noshort, "timing",
        (FStar_Getopt.ZeroArgs ((fun uu____1464  -> Bool true))),
        "Print the time it takes to verify each top-level definition");
      (FStar_Getopt.noshort, "trace_error",
        (FStar_Getopt.ZeroArgs ((fun uu____1471  -> Bool true))),
        "Don't print an error message; show an exception trace instead");
      (FStar_Getopt.noshort, "unthrottle_inductives",
        (FStar_Getopt.ZeroArgs ((fun uu____1478  -> Bool true))),
        "Let the SMT solver unfold inductive types to arbitrary depths (may affect verifier performance)");
      (FStar_Getopt.noshort, "use_eq_at_higher_order",
        (FStar_Getopt.ZeroArgs ((fun uu____1485  -> Bool true))),
        "Use equality constraints when comparing higher-order types (Temporary)");
      (FStar_Getopt.noshort, "use_hints",
        (FStar_Getopt.ZeroArgs ((fun uu____1492  -> Bool true))),
        "Use a previously recorded hints database for proof replay");
      (FStar_Getopt.noshort, "verify_all",
        (FStar_Getopt.ZeroArgs ((fun uu____1499  -> Bool true))),
        "With automatic dependencies, verify all the dependencies, not just the files passed on the command-line.");
      (FStar_Getopt.noshort, "verify_module",
        (FStar_Getopt.OneArg (cons_verify_module, "[module name]")),
        "Name of the module to verify");
      (FStar_Getopt.noshort, "__temp_no_proj",
        (FStar_Getopt.OneArg
           (((fun x  ->
                let uu____1517 =
                  let uu____1519 =
                    let uu____1521 = get___temp_no_proj ()  in x ::
                      uu____1521
                     in
                  FStar_All.pipe_right uu____1519
                    (FStar_List.map (fun _0_41  -> String _0_41))
                   in
                List uu____1517)), "[module name]")),
        "Don't generate projectors for this module");
      ('v', "version",
        (FStar_Getopt.ZeroArgs
           ((fun uu____1531  ->
               display_version (); FStar_All.exit (Prims.parse_int "0")))),
        "Display version number");
      (FStar_Getopt.noshort, "warn_default_effects",
        (FStar_Getopt.ZeroArgs ((fun uu____1539  -> Bool true))),
        "Warn when (a -> b) is desugared to (a -> Tot b)");
      (FStar_Getopt.noshort, "z3cliopt",
        (FStar_Getopt.OneArg
           (((fun s  ->
                let uu____1549 =
                  let uu____1551 =
                    let uu____1553 = get_z3cliopt ()  in
                    FStar_List.append uu____1553 [s]  in
                  FStar_All.pipe_right uu____1551
                    (FStar_List.map (fun _0_42  -> String _0_42))
                   in
                List uu____1549)), "[option]")), "Z3 command line options");
      (FStar_Getopt.noshort, "z3refresh",
        (FStar_Getopt.ZeroArgs ((fun uu____1563  -> Bool false))),
        "Restart Z3 after each query; useful for ensuring proof robustness");
      (FStar_Getopt.noshort, "z3rlimit",
        (FStar_Getopt.OneArg
           (((fun s  ->
                let uu____1573 = FStar_Util.int_of_string s  in
                Int uu____1573)), "[positive integer]")),
        "Set the Z3 per-query resource limit (default 5 units, taking roughtly 5s)");
      (FStar_Getopt.noshort, "z3seed",
        (FStar_Getopt.OneArg
           (((fun s  ->
                let uu____1583 = FStar_Util.int_of_string s  in
                Int uu____1583)), "[positive integer]")),
        "Set the Z3 random seed (default 0)");
      (FStar_Getopt.noshort, "z3timeout",
        (FStar_Getopt.OneArg
           (((fun s  ->
                FStar_Util.print_string
                  "Warning: z3timeout ignored; use z3rlimit instead\n";
                (let uu____1594 = FStar_Util.int_of_string s  in
                 Int uu____1594))), "[positive integer]")),
        "Set the Z3 per-query (soft) timeout to [t] seconds (default 5)");
      (FStar_Getopt.noshort, "__no_positivity",
        (FStar_Getopt.ZeroArgs ((fun uu____1601  -> Bool true))),
        "Don't check positivity of inductive types")]
       in
    let uu____1607 = FStar_List.map mk_spec specs1  in
    ('h', "help",
      (FStar_Getopt.ZeroArgs
         (fun x  ->
            display_usage_aux specs1; FStar_All.exit (Prims.parse_int "0"))),
      "Display this information") :: uu____1607

and parse_codegen : Prims.string -> Prims.string =
  fun s  ->
    match s with
    | "Kremlin"|"OCaml"|"FSharp" -> s
    | uu____1628 ->
        (FStar_Util.print_string "Wrong argument to codegen flag\n";
         (let uu____1631 = specs ()  in display_usage_aux uu____1631);
         FStar_All.exit (Prims.parse_int "1"))

and validate_cardinality : Prims.string -> Prims.string =
  fun x  ->
    match x with
    | "warn"|"check"|"off" -> x
    | uu____1639 ->
        (FStar_Util.print_string "Wrong argument to cardinality flag\n";
         (let uu____1642 = specs ()  in display_usage_aux uu____1642);
         FStar_All.exit (Prims.parse_int "1"))

let settable : Prims.string -> Prims.bool =
  fun uu___51_1651  ->
    match uu___51_1651 with
    | "admit_smt_queries"
      |"cardinality"
       |"debug"
        |"debug_level"
         |"detail_errors"
          |"eager_inference"
           |"hide_genident_nums"
            |"hide_uvar_nums"
             |"hint_info"
              |"initial_fuel"
               |"initial_ifuel"
                |"inline_arith"
                 |"lax"
                  |"log_types"
                   |"log_queries"
                    |"max_fuel"
                     |"max_ifuel"
                      |"min_fuel"
                       |"print_before_norm"
                        |"print_bound_var_types"
                         |"print_effect_args"
                          |"print_fuels"
                           |"print_implicits"
                            |"print_universes"
                             |"print_z3_statistics"
                              |"prn"
                               |"show_signatures"
                                |"silent"
                                 |"split_cases"
                                  |"timing"
                                   |"trace_error"
                                    |"unthrottle_inductives"
                                     |"use_eq_at_higher_order"
                                      |"__temp_no_proj"
                                       |"no_warn_top_level_effects"
                                        |"reuse_hint_for"|"z3refresh"
        -> true
    | uu____1652 -> false
  
let resettable : Prims.string -> Prims.bool =
  fun s  ->
    (((settable s) || (s = "z3timeout")) || (s = "z3rlimit")) ||
      (s = "z3seed")
  
let all_specs : FStar_Getopt.opt Prims.list = specs () 
let settable_specs :
  (FStar_BaseTypes.char * Prims.string * Prims.unit FStar_Getopt.opt_variant
    * Prims.string) Prims.list
  =
  FStar_All.pipe_right all_specs
    (FStar_List.filter
       (fun uu____1675  ->
          match uu____1675 with
          | (uu____1681,x,uu____1683,uu____1684) -> settable x))
  
let resettable_specs :
  (FStar_BaseTypes.char * Prims.string * Prims.unit FStar_Getopt.opt_variant
    * Prims.string) Prims.list
  =
  FStar_All.pipe_right all_specs
    (FStar_List.filter
       (fun uu____1705  ->
          match uu____1705 with
          | (uu____1711,x,uu____1713,uu____1714) -> resettable x))
  
let display_usage : Prims.unit -> Prims.unit =
  fun uu____1719  ->
    let uu____1720 = specs ()  in display_usage_aux uu____1720
  
let fstar_home : Prims.unit -> Prims.string =
  fun uu____1729  ->
    let uu____1730 = get_fstar_home ()  in
    match uu____1730 with
    | None  ->
        let x = FStar_Util.get_exec_dir ()  in
        let x1 = Prims.strcat x "/.."  in
        (set_option' ("fstar_home", (String x1)); x1)
    | Some x -> x
  
let set_options : options -> Prims.string -> FStar_Getopt.parse_cmdline_res =
  fun o  ->
    fun s  ->
      let specs1 =
        match o with
        | Set  -> resettable_specs
        | Reset  -> resettable_specs
        | Restore  -> all_specs  in
      FStar_Getopt.parse_string specs1 (fun uu____1755  -> ()) s
  
let file_list_ : Prims.string Prims.list FStar_ST.ref = FStar_Util.mk_ref [] 
let parse_cmd_line :
  Prims.unit -> (FStar_Getopt.parse_cmdline_res * Prims.string Prims.list) =
  fun uu____1766  ->
    let res =
      let uu____1768 = specs ()  in
      FStar_Getopt.parse_cmdline uu____1768
        (fun i  ->
           let uu____1771 =
             let uu____1773 = FStar_ST.read file_list_  in
             FStar_List.append uu____1773 [i]  in
           FStar_ST.write file_list_ uu____1771)
       in
    let uu____1781 = FStar_ST.read file_list_  in (res, uu____1781)
  
let file_list : Prims.unit -> Prims.string Prims.list =
  fun uu____1790  -> FStar_ST.read file_list_ 
let restore_cmd_line_options : Prims.bool -> FStar_Getopt.parse_cmdline_res =
  fun should_clear  ->
    let old_verify_module = get_verify_module ()  in
    if should_clear then clear () else init ();
    (let r =
       let uu____1802 = specs ()  in
       FStar_Getopt.parse_cmdline uu____1802 (fun x  -> ())  in
     (let uu____1806 =
        let uu____1809 =
          let uu____1810 =
            FStar_List.map (fun _0_43  -> String _0_43) old_verify_module  in
          List uu____1810  in
        ("verify_module", uu____1809)  in
      set_option' uu____1806);
     r)
  
let should_verify : Prims.string -> Prims.bool =
  fun m  ->
    let uu____1815 = get_lax ()  in
    if uu____1815
    then false
    else
      (let uu____1817 = get_verify_all ()  in
       if uu____1817
       then true
       else
         (let uu____1819 = get_verify_module ()  in
          match uu____1819 with
          | [] ->
              let uu____1821 = file_list ()  in
              FStar_List.existsML
                (fun f  ->
                   let f1 = FStar_Util.basename f  in
                   let f2 =
                     let uu____1826 =
                       let uu____1827 =
                         let uu____1828 =
                           let uu____1829 = FStar_Util.get_file_extension f1
                              in
                           FStar_String.length uu____1829  in
                         (FStar_String.length f1) - uu____1828  in
                       uu____1827 - (Prims.parse_int "1")  in
                     FStar_String.substring f1 (Prims.parse_int "0")
                       uu____1826
                      in
                   (FStar_String.lowercase f2) = m) uu____1821
          | l -> FStar_List.contains (FStar_String.lowercase m) l))
  
let dont_gen_projectors : Prims.string -> Prims.bool =
  fun m  ->
    let uu____1839 = get___temp_no_proj ()  in
    FStar_List.contains m uu____1839
  
let should_print_message : Prims.string -> Prims.bool =
  fun m  ->
    let uu____1844 = should_verify m  in
    if uu____1844 then m <> "Prims" else false
  
let include_path : Prims.unit -> Prims.string Prims.list =
  fun uu____1849  ->
    let uu____1850 = get_no_default_includes ()  in
    if uu____1850
    then get_include ()
    else
      (let h = fstar_home ()  in
       let defs = universe_include_path_base_dirs  in
       let uu____1856 =
         let uu____1858 =
           FStar_All.pipe_right defs
             (FStar_List.map (fun x  -> Prims.strcat h x))
            in
         FStar_All.pipe_right uu____1858
           (FStar_List.filter FStar_Util.file_exists)
          in
       let uu____1865 =
         let uu____1867 = get_include ()  in
         FStar_List.append uu____1867 ["."]  in
       FStar_List.append uu____1856 uu____1865)
  
let find_file : Prims.string -> Prims.string Prims.option =
  fun filename  ->
    let uu____1873 = FStar_Util.is_path_absolute filename  in
    if uu____1873
    then (if FStar_Util.file_exists filename then Some filename else None)
    else
      (let uu____1878 =
         let uu____1880 = include_path ()  in FStar_List.rev uu____1880  in
       FStar_Util.find_map uu____1878
         (fun p  ->
            let path = FStar_Util.join_paths p filename  in
            if FStar_Util.file_exists path then Some path else None))
  
let prims : Prims.unit -> Prims.string =
  fun uu____1888  ->
    let uu____1889 = get_prims ()  in
    match uu____1889 with
    | None  ->
        let filename = "prims.fst"  in
        let uu____1892 = find_file filename  in
        (match uu____1892 with
         | Some result -> result
         | None  ->
             let uu____1895 =
               let uu____1896 =
                 FStar_Util.format1
                   "unable to find required file \"%s\" in the module search path.\n"
                   filename
                  in
               FStar_Util.Failure uu____1896  in
             Prims.raise uu____1895)
    | Some x -> x
  
let prepend_output_dir : Prims.string -> Prims.string =
  fun fname  ->
    let uu____1901 = get_odir ()  in
    match uu____1901 with
    | None  -> fname
    | Some x -> Prims.strcat x (Prims.strcat "/" fname)
  
let __temp_no_proj : Prims.string -> Prims.bool =
  fun s  ->
    let uu____1907 = get___temp_no_proj ()  in
    FStar_All.pipe_right uu____1907 (FStar_List.contains s)
  
let admit_smt_queries : Prims.unit -> Prims.bool =
  fun uu____1912  -> get_admit_smt_queries () 
let check_cardinality : Prims.unit -> Prims.bool =
  fun uu____1915  ->
    let uu____1916 = get_cardinality ()  in uu____1916 = "check"
  
let codegen : Prims.unit -> Prims.string Prims.option =
  fun uu____1920  -> get_codegen () 
let codegen_libs : Prims.unit -> Prims.string Prims.list Prims.list =
  fun uu____1925  ->
    let uu____1926 = get_codegen_lib ()  in
    FStar_All.pipe_right uu____1926
      (FStar_List.map (fun x  -> FStar_Util.split x "."))
  
let debug_any : Prims.unit -> Prims.bool =
  fun uu____1935  -> let uu____1936 = get_debug ()  in uu____1936 <> [] 
let debug_at_level : Prims.string -> debug_level_t -> Prims.bool =
  fun modul  ->
    fun level  ->
      ((modul = "") ||
         (let uu____1945 = get_debug ()  in
          FStar_All.pipe_right uu____1945 (FStar_List.contains modul)))
        && (debug_level_geq level)
  
let dep : Prims.unit -> Prims.string Prims.option =
  fun uu____1951  -> get_dep () 
let detail_errors : Prims.unit -> Prims.bool =
  fun uu____1954  -> get_detail_errors () 
let doc : Prims.unit -> Prims.bool = fun uu____1957  -> get_doc () 
let dump_module : Prims.string -> Prims.bool =
  fun s  ->
    let uu____1961 = get_dump_module ()  in
    FStar_All.pipe_right uu____1961 (FStar_List.contains s)
  
let eager_inference : Prims.unit -> Prims.bool =
  fun uu____1966  -> get_eager_inference () 
let explicit_deps : Prims.unit -> Prims.bool =
  fun uu____1969  -> get_explicit_deps () 
let extract_all : Prims.unit -> Prims.bool =
  fun uu____1972  -> get_extract_all () 
let fs_typ_app : Prims.string -> Prims.bool =
  fun filename  ->
    let uu____1976 = FStar_ST.read light_off_files  in
    FStar_List.contains filename uu____1976
  
let full_context_dependency : Prims.unit -> Prims.bool =
  fun uu____1983  -> true 
let hide_genident_nums : Prims.unit -> Prims.bool =
  fun uu____1986  -> get_hide_genident_nums () 
let hide_uvar_nums : Prims.unit -> Prims.bool =
  fun uu____1989  -> get_hide_uvar_nums () 
let hint_info : Prims.unit -> Prims.bool =
  fun uu____1992  -> get_hint_info () 
let indent : Prims.unit -> Prims.bool = fun uu____1995  -> get_indent () 
let initial_fuel : Prims.unit -> Prims.int =
  fun uu____1998  ->
    let uu____1999 = get_initial_fuel ()  in
    let uu____2000 = get_max_fuel ()  in Prims.min uu____1999 uu____2000
  
let initial_ifuel : Prims.unit -> Prims.int =
  fun uu____2003  ->
    let uu____2004 = get_initial_ifuel ()  in
    let uu____2005 = get_max_ifuel ()  in Prims.min uu____2004 uu____2005
  
let inline_arith : Prims.unit -> Prims.bool =
  fun uu____2008  -> get_inline_arith () 
let interactive : Prims.unit -> Prims.bool = fun uu____2011  -> get_in () 
let lax : Prims.unit -> Prims.bool = fun uu____2014  -> get_lax () 
let log_queries : Prims.unit -> Prims.bool =
  fun uu____2017  -> get_log_queries () 
let log_types : Prims.unit -> Prims.bool =
  fun uu____2020  -> get_log_types () 
let max_fuel : Prims.unit -> Prims.int = fun uu____2023  -> get_max_fuel () 
let max_ifuel : Prims.unit -> Prims.int = fun uu____2026  -> get_max_ifuel () 
let min_fuel : Prims.unit -> Prims.int = fun uu____2029  -> get_min_fuel () 
let ml_ish : Prims.unit -> Prims.bool = fun uu____2032  -> get_MLish () 
let set_ml_ish : Prims.unit -> Prims.unit =
  fun uu____2035  -> set_option "MLish" (Bool true) 
let n_cores : Prims.unit -> Prims.int = fun uu____2038  -> get_n_cores () 
let no_default_includes : Prims.unit -> Prims.bool =
  fun uu____2041  -> get_no_default_includes () 
let no_extract : Prims.string -> Prims.bool =
  fun s  ->
    let uu____2045 = get_no_extract ()  in
    FStar_All.pipe_right uu____2045 (FStar_List.contains s)
  
let no_location_info : Prims.unit -> Prims.bool =
  fun uu____2050  -> get_no_location_info () 
let norm_then_print : Prims.unit -> Prims.bool =
  fun uu____2053  ->
    let uu____2054 = get_print_before_norm ()  in uu____2054 = false
  
let output_dir : Prims.unit -> Prims.string Prims.option =
  fun uu____2058  -> get_odir () 
let print_bound_var_types : Prims.unit -> Prims.bool =
  fun uu____2061  -> get_print_bound_var_types () 
let print_effect_args : Prims.unit -> Prims.bool =
  fun uu____2064  -> get_print_effect_args () 
let print_fuels : Prims.unit -> Prims.bool =
  fun uu____2067  -> get_print_fuels () 
let print_implicits : Prims.unit -> Prims.bool =
  fun uu____2070  -> get_print_implicits () 
let print_real_names : Prims.unit -> Prims.bool =
  fun uu____2073  -> get_prn () 
let print_universes : Prims.unit -> Prims.bool =
  fun uu____2076  -> get_print_universes () 
let print_z3_statistics : Prims.unit -> Prims.bool =
  fun uu____2079  -> get_print_z3_statistics () 
let record_hints : Prims.unit -> Prims.bool =
  fun uu____2082  -> get_record_hints () 
let reuse_hint_for : Prims.unit -> Prims.string Prims.option =
  fun uu____2086  -> get_reuse_hint_for () 
let silent : Prims.unit -> Prims.bool = fun uu____2089  -> get_silent () 
let split_cases : Prims.unit -> Prims.int =
  fun uu____2092  -> get_split_cases () 
let timing : Prims.unit -> Prims.bool = fun uu____2095  -> get_timing () 
let trace_error : Prims.unit -> Prims.bool =
  fun uu____2098  -> get_trace_error () 
let unthrottle_inductives : Prims.unit -> Prims.bool =
  fun uu____2101  -> get_unthrottle_inductives () 
let use_eq_at_higher_order : Prims.unit -> Prims.bool =
  fun uu____2104  -> get_use_eq_at_higher_order () 
let use_hints : Prims.unit -> Prims.bool =
  fun uu____2107  -> get_use_hints () 
let verify_all : Prims.unit -> Prims.bool =
  fun uu____2110  -> get_verify_all () 
let verify_module : Prims.unit -> Prims.string Prims.list =
  fun uu____2114  -> get_verify_module () 
let warn_cardinality : Prims.unit -> Prims.bool =
  fun uu____2117  ->
    let uu____2118 = get_cardinality ()  in uu____2118 = "warn"
  
let warn_default_effects : Prims.unit -> Prims.bool =
  fun uu____2121  -> get_warn_default_effects () 
let warn_top_level_effects : Prims.unit -> Prims.bool =
  fun uu____2124  -> get_warn_top_level_effects () 
let z3_exe : Prims.unit -> Prims.string =
  fun uu____2127  ->
    let uu____2128 = get_smt ()  in
    match uu____2128 with | None  -> FStar_Platform.exe "z3" | Some s -> s
  
let z3_cliopt : Prims.unit -> Prims.string Prims.list =
  fun uu____2134  -> get_z3cliopt () 
let z3_refresh : Prims.unit -> Prims.bool =
  fun uu____2137  -> get_z3refresh () 
let z3_rlimit : Prims.unit -> Prims.int = fun uu____2140  -> get_z3rlimit () 
let z3_seed : Prims.unit -> Prims.int = fun uu____2143  -> get_z3seed () 
let z3_timeout : Prims.unit -> Prims.int =
  fun uu____2146  -> get_z3timeout () 
let no_positivity : Prims.unit -> Prims.bool =
  fun uu____2149  -> get_no_positivity () 
let should_extract : Prims.string -> Prims.bool =
  fun m  ->
    (let uu____2153 = no_extract m  in Prims.op_Negation uu____2153) &&
      ((extract_all ()) ||
         (let uu____2154 = get_extract_module ()  in
          match uu____2154 with
          | [] ->
              let uu____2156 = get_extract_namespace ()  in
              (match uu____2156 with
               | [] -> true
               | ns ->
                   FStar_Util.for_some
                     (FStar_Util.starts_with (FStar_String.lowercase m)) ns)
          | l -> FStar_List.contains (FStar_String.lowercase m) l))
  