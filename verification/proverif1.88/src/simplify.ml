(*************************************************************
 *                                                           *
 *  Cryptographic protocol verifier                          *
 *                                                           *
 *  Bruno Blanchet, Xavier Allamigeon, and Vincent Cheval    *
 *                                                           *
 *  Copyright (C) INRIA, LIENS, MPII 2000-2013               *
 *                                                           *
 *************************************************************)

(*

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details (in file LICENSE).

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*)
open Parsing_helper
open Types
open Pitypes

let new_occurrence = Terms.new_occurrence
let glob_table = Hashtbl.create 7
  
let rename_private_name n =
  Terms.create_name (Terms.fresh_id n.f_name) n.f_type true

(* Copy a process *)

let copy_binder add_in_glob_table b =
  let b' = 
    if add_in_glob_table then
      (* If it is the final copy, create a distinct variable *)
      if b.vname = -1 then
	Terms.new_var b.sname b.btype
      else
	Terms.copy_var b
    else
      Terms.copy_var_noren b 
  in
  match b.link with
    NoLink ->
      Terms.link b (TLink (Var b'));
      b'
  | _ -> Parsing_helper.internal_error ("unexpected link in copy_binder " ^ b.sname)

let rec copy_pat add_in_glob_table = function
    PatVar b -> PatVar (copy_binder add_in_glob_table b)
  | PatTuple(f,l) -> PatTuple(f, List.map (copy_pat add_in_glob_table) l)
  | PatEqual(t) -> PatEqual (Terms.copy_term3 t)

let rec copy_process add_in_glob_table = function
    Nil -> Nil
  | Par(p1,p2) -> 
      let p1' = copy_process add_in_glob_table p1 in
      let p2' = copy_process add_in_glob_table p2 in
      Par(p1', p2')
  | Restr(n,p,occ) -> 
      if add_in_glob_table then
	(* If it is the final copy, create a distinct name for each restriction and add it in the glob_table *)
	let n' = rename_private_name n in
	Hashtbl.add glob_table n.f_name n';
	Restr(n', Reduction_helper.process_subst (copy_process add_in_glob_table p) n (FunApp(n',[])), new_occurrence())
      else
	Restr(n, copy_process add_in_glob_table p, new_occurrence())
  | Repl(p,occ) -> Repl(copy_process add_in_glob_table p, new_occurrence())
  | Let(pat, t, p, q, occ) -> 
      Terms.auto_cleanup (fun () ->
	let pat' = copy_pat add_in_glob_table pat in 
	let occ' = new_occurrence() in
	let p' = copy_process add_in_glob_table p in
	let q' = copy_process add_in_glob_table q in
	Let(pat', Terms.copy_term3 t, p', q', occ'))
  | Input(t, pat, p, occ) -> 
      Terms.auto_cleanup (fun () ->
	let pat' = copy_pat add_in_glob_table pat in 
	Input(Terms.copy_term3 t, pat', copy_process add_in_glob_table p, new_occurrence()))
  | Output(tc,t,p, occ) -> 
      Output(Terms.copy_term3 tc, Terms.copy_term3 t, copy_process add_in_glob_table p, new_occurrence())
  | Test(t,p,q,occ) -> 
      let occ' = new_occurrence() in
      let p' = copy_process add_in_glob_table p in
      let q' = copy_process add_in_glob_table q in
      Test(Terms.copy_term3 t, p', q', occ')
  | Event(t, p, occ) -> Event(Terms.copy_term3 t, copy_process add_in_glob_table p, new_occurrence())
  | Insert(t, p, occ) -> Insert(Terms.copy_term3 t, copy_process add_in_glob_table p, new_occurrence())
  | Get(pat, t, p, q, occ) -> 
      Terms.auto_cleanup (fun () ->
	let pat' = copy_pat add_in_glob_table pat in 
	let p' = copy_process add_in_glob_table p in
	let q' = copy_process add_in_glob_table q in
	Get(pat', Terms.copy_term3 t, p', q', new_occurrence()))
  | Phase(n,p,occ) -> Phase(n, copy_process add_in_glob_table p, new_occurrence())
  | LetFilter(bl, f, p, q, occ) -> 
      Terms.auto_cleanup (fun () ->
	let bl' = List.map (copy_binder add_in_glob_table) bl in 
	let occ' = new_occurrence() in
	let p' = copy_process add_in_glob_table p in
	let q' = copy_process add_in_glob_table q in
	LetFilter(bl', Terms.copy_fact3 f, p', q', occ'))

(* Prepare a process by choosing new identifiers for names, variables... *)

let prepare_process p = 
  Hashtbl.clear glob_table;
  Terms.auto_cleanup (fun () ->
     Terms.reset_occurrence();
     copy_process true p
   )

(*********************************************
               Renaming 
**********************************************) 

let rec renaming_symbol restr_names symb = match symb.f_cat with
  | Name(_) -> 
      begin try
        List.assq symb restr_names
      with
        Not_found -> symb
      end
  | _ -> symb

let rec renaming_term restr_names = function
  | Var(v) -> Var(v)
  | FunApp(f,list_arg) -> 
      let f' = renaming_symbol restr_names f
      and list_arg' = List.map (renaming_term restr_names) list_arg in
      FunApp(f',list_arg')

      
(** We assume that this function is applied only on processes with one-variable-patterns *)      
let rec renaming_process restr_names = function
  | Nil -> Nil
  | Par(p1,p2) -> 
      let p1' = renaming_process restr_names p1
      and p2' = renaming_process restr_names p2 in
      Par(p1',p2')   
  | Repl(p,occ) -> Repl(renaming_process restr_names p,occ)
  | Restr(n,p,occ) -> 
      let n' = rename_private_name n in
      let restr_names' = (n,n')::restr_names in
      Restr(n',renaming_process restr_names' p,occ)
  | Test(t,p1,p2,occ) ->
      let t' = renaming_term restr_names t in
      let p1' = renaming_process restr_names p1
      and p2' = renaming_process restr_names p2 in
      Test(t',p1',p2',occ)
  | Input(term,pat,proc,occ) ->
      let term' = renaming_term restr_names term in
      let proc' = renaming_process restr_names proc in
      Input(term',pat,proc',occ)
  | Output(ch,term,proc,occ) -> 
      let ch' = renaming_term restr_names ch
      and term' = renaming_term restr_names term in
      let proc' = renaming_process restr_names proc in
      
      Output(ch', term', proc', occ)
  | Let(pat,term,proc1,proc2,occ) ->
      let term' = renaming_term restr_names term in
      
      let proc1' = renaming_process restr_names proc1
      and proc2' = renaming_process restr_names proc2 in
      
      Let(pat,term',proc1',proc2',occ)
  | Phase(n, proc,occ) -> 
      Phase(n, renaming_process restr_names proc, occ)
  | LetFilter(_,_,_,_,_) -> input_error "Merging and simplify do not support LetFilter in the process" dummy_ext
  | Event(_,_,_) -> internal_error "renaming_process does not support Event in the process; it should never occur in the result of simplify" 
  | Insert(term, proc, occ) -> 
      let term' = renaming_term restr_names term in
      let proc' = renaming_process restr_names proc in
      Insert(term', proc', occ)
  | Get(pat, term, proc, proc_else, occ) -> 
      let term' = renaming_term restr_names term in
      let proc' = renaming_process restr_names proc in
      let proc_else' = renaming_process restr_names proc_else in
      Get(pat, term', proc', proc_else', occ)

(*************************************
	Follow links in a process
**************************************)

let rec follow_pattern = function 
  | PatVar(x) -> PatVar(x)
  | PatTuple(f,l) -> PatTuple(f,List.map follow_pattern l)
  | PatEqual(t) -> PatEqual(Terms.copy_term3 t)
  
let rec follow_process = function
  | Nil -> Nil
  | Par(p1,p2) -> Par(follow_process p1,follow_process p2)
  | Repl(p,occ) -> Repl(follow_process p,occ)
  | Restr(f,p,occ) -> Restr(f,follow_process p,occ)
  | Test(t,p1,p2,occ) ->
      let t' = Terms.copy_term3 t
      and p1' = follow_process p1
      and p2' = follow_process p2 in
      Test(t',p1',p2',occ)
  | Input(t,pat,p,occ) ->
      let t' = Terms.copy_term3 t
      and pat' = follow_pattern pat
      and p' = follow_process p in
      Input(t',pat',p',occ)
  | Output(ch,t,p,occ) ->
      let ch' = Terms.copy_term3 ch
      and t' = Terms.copy_term3 t
      and p' = follow_process p in
      Output(ch',t',p',occ)
  | Let(pat,t,p1,p2,occ) ->
      let t' = Terms.copy_term3 t
      and pat' = follow_pattern pat
      and p1' = follow_process p1
      and p2' = follow_process p2 in
      Let(pat',t',p1',p2',occ)
  | LetFilter(_,_,_,_,_) -> input_error "Merging and simplify do not support LetFilter in the process" dummy_ext
  | Event(t,p,occ) -> 
      let t' = Terms.copy_term3 t in
      let p' = follow_process p in
      Event(t', p', occ)
  | Insert(t, p, occ) -> 
      let t' = Terms.copy_term3 t in
      let p' = follow_process p in
      Insert(t', p', occ)
  | Get(pat, t, p, q, occ) -> 
      let pat' = follow_pattern pat in
      let t' = Terms.copy_term3 t in
      let p' = follow_process p in
      let q' = follow_process q in
      Get(pat', t', p', q', occ)
  | Phase(n, proc,occ) -> Phase(n, follow_process proc, occ)
  
(*********************************************
               Merging process 
**********************************************)	 

(* In this section, we can assume that:
- all patterns are only variables
- There is no Test, LetFilter, Event, Insert, Get, Phase 
*)

(* We define a exception that will express that no merging is possible between two protocols *)

exception No_Merging

(* Preliminaries functions *)

(** Extract the list of names that are declared directly at the beginning of the process *)
let rec extract_list_name proc = match proc with
  | Restr(a,p,_) -> let (list_name, p') = extract_list_name p in
      (a::list_name,p')
  | _ -> ([],proc)
  
(** Extract the list of names that are declared directly at the beginning of the process
    but endind necessarely with a replication. 
    Raise No_merging if no replication follows the list of names. *)
let rec extract_list_name_followed_by_repl proc = match proc with
  | Restr(f,p,_) -> let (list_name,repl_proc) = extract_list_name_followed_by_repl p in
      (f::list_name, repl_proc)
  | Repl(_,_) -> ([],proc)
  |_ -> raise No_Merging


(* Merging two processes results in a list of the following type :
     [(process * (binder, terms, terms) list) list]
   
   The main list represents all the possible merging processes.
   The list [(binder, terms, terms) list] represents the binders of variables in 
   the process which would normally be replaced by diff'[M,M'] where M and M' are
   the two terms in the tuple. *)

let rec verify_term free_var = function
  | Var v -> 
      if not (List.memq v free_var)
      then
        begin
          Display.Text.display_term2 (Var v);
          internal_error "The previous variable is not declared:\n"
        end;
  |FunApp(_,l) -> List.iter (verify_term free_var) l
   
let rec verify_pattern free_var = function
  | PatVar(x) -> [x]
  | PatTuple(_,l) -> List.concat (List.map (verify_pattern free_var) l)
  | PatEqual(t) -> verify_term free_var t; []
  
let rec verify_process free_var proc = 
  match proc with
  | Nil -> ()
  | Par(p1,p2) -> verify_process free_var p1;
      verify_process free_var p2
  | Repl(p,_) -> verify_process free_var p
  | Restr(_,p,_) -> verify_process free_var p
  | Test(t,p1,p2,_) ->
      verify_term free_var t;
      verify_process free_var p1;
      verify_process free_var p2
  | Input(t,pat,p,_) ->
      let binders = verify_pattern free_var pat in
      
      verify_term free_var t;
      verify_process (binders@free_var) p
  | Output(t1,t2,p,_) ->
      verify_term free_var t1;
      verify_term free_var t2;
      verify_process free_var p
  | Let(pat,t,p1,p2,_) ->
      let binders = verify_pattern free_var pat in
      
      verify_term free_var t;
      verify_process (binders@free_var) p1;
      verify_process free_var p2
  | Phase(_, proc,_) -> verify_process free_var proc
  | LetFilter(_,_,_,_,_) -> input_error "verify_process do not support LetFilter in the process" dummy_ext

  | Event(_,_,_) -> 
      internal_error "verify_process do not support Event in the process; it should never occur in the result of simplify_process" 

  | Insert(t, p, _) -> 
      verify_term free_var t;
      verify_process free_var p
    
  | Get(pat, t, p, q, _) -> 
      let binders = verify_pattern free_var pat in
      let new_free_var = binders @ free_var in
      
      verify_term new_free_var t;
      verify_process new_free_var p;
      verify_process new_free_var q
   
let rec merge_processes process_1 process_2 = 
  let process_list = match process_1, process_2 with 
  | LetFilter(_,_,_,_,_), _ | _,LetFilter(_,_,_,_,_) -> 
      input_error "The merging processes function does not support LetFilter in the process" dummy_ext
  | Event(_,_,_),_ | _,Event(_,_,_) ->
      internal_error "The merging processes function does not support Event in the process; it should never occur in the result of simplify_process" 

  | Insert(t1, proc1, _), Insert(t2, proc2, _) ->
      let merge_list = merge_processes proc1 proc2 in
      let ty1 = Terms.get_term_type t1 in
      let ty2 = Terms.get_term_type t2 in
      if (ty1 != ty2) && not (!Param.ignore_types) then
	raise No_Merging;
      let y_diff = Terms.new_var_def ty1 in
      if Terms.equal_terms t1 t2 then
        List.map (fun (proc,binders) -> 
          Insert(t1,proc,new_occurrence ()),binders
            ) merge_list
      else
	List.map (fun (proc,binders) ->
          Insert(y_diff,proc,new_occurrence ()),
          (y_diff, t1, t2)::binders
				     ) merge_list

  | Get(pat1, t1, proc1, proc_else1, _), Get(pat2, t2, proc2, proc_else2, _) ->
      (* Warning: pat1 and pat2 should both be variables (by simplify) *)
      let x = Terms.new_var Param.def_var_name Param.table_type
      and old_x1 = Terms.term_of_pattern_variable pat1
      and old_x2 = Terms.term_of_pattern_variable pat2 in
      
      (* Test current_bound_vars *)
      assert (!Terms.current_bound_vars == []);
      Terms.link_var old_x1 (TLink (Var x));
      Terms.link_var old_x2 (TLink (Var x));
      let t1_substituted = Terms.copy_term3 t1 in
      let t2_substituted = Terms.copy_term3 t2 in
      let proc1_substituted = follow_process proc1
      and proc2_substituted = follow_process proc2 in
      Terms.cleanup ();

      let merge_list = merge_processes proc1_substituted proc2_substituted 
      and merge_list_else = merge_processes proc_else1 proc_else2 in

      if Terms.equal_terms t1_substituted t2_substituted then
	List.fold_left (fun acc1 -> fun (p_then, b_then) ->
          List.fold_left (fun acc2 -> fun (p_else, b_else) ->
	    (Get(PatVar x, t1_substituted, p_then, p_else, new_occurrence ()), (b_then@b_else)) :: acc2
	  ) acc1 merge_list_else
	) [] merge_list
      else
        let y_diff = Terms.new_var_def Param.table_type in
	List.fold_left (fun acc1 -> fun (p_then, b_then) ->
          List.fold_left (fun acc2 -> fun (p_else, b_else) ->
              (Get(PatVar x, y_diff, p_then, p_else, new_occurrence ()),
	       (y_diff, t1_substituted, t2_substituted)::(b_then@b_else)) :: acc2
          ) acc1 merge_list_else
        ) [] merge_list

  | Test(_,_,_,_),_ | _, Test(_,_,_,_) ->
      (* Test removed by simplify *)
      internal_error "The merging processes function does not support Test in the process; it should never occur in the result of simplify_process" 

  | Nil, Nil -> [Nil, []]
  | Nil,_ -> raise No_Merging
  | _, Nil -> raise No_Merging
  
  | Phase(n1,proc1,_), Phase(n2,proc2,_) -> 
      if n1 = n2 then
        (* May raise No_Merging *)
        let merge_list = merge_processes proc1 proc2 in
        List.map (fun (proc,binders) -> Phase(n1,proc,new_occurrence()),binders) merge_list
      else
        raise No_Merging
  
  | Output(ch1, term1, proc1, _), Output(ch2,term2,proc2,_) ->
      
      (*Printf.printf "---- DEBUG Merging---\n";
      Printf.printf "Process1:\n";
      Display.Text.display_process_occ "" process_1;
      Printf.printf "Process2:\n";
      Display.Text.display_process_occ "" process_2;
      Printf.printf "---- End DEBUG Merging---\n";*)
      
  
      let type_1 = Terms.get_term_type term1
      and type_2 = Terms.get_term_type term2 in
      
      if type_1 != type_2 && not (!Param.ignore_types) then raise No_Merging;
      
      (* May raise exception No_Merging *)
      let merge_list = merge_processes proc1 proc2 in
      
      begin match Terms.equal_terms ch1 ch2, Terms.equal_terms term1 term2 with
        |true, true -> 
          List.map (fun (proc,binders) -> 
            Output(ch1,term1,proc,new_occurrence ()),binders
          ) merge_list
        |true,false ->
          let y_diff = Terms.new_var_def type_1 in

          List.map (fun (proc,binders) ->
            Output(ch1,y_diff,proc,new_occurrence ()),
            (y_diff, term1, term2)::binders
          ) merge_list
        |false,true ->
          let y_diff = Terms.new_var_def Param.channel_type in
          
          List.map (fun (proc,binders) ->
            Output(y_diff,term1,proc,new_occurrence ()),
            (y_diff, ch1, ch2)::binders
          ) merge_list
        |_,_ ->
          let y_diff = Terms.new_var_def Param.channel_type
          and y'_diff = Terms.new_var_def type_1 in
      
          List.map (fun (proc,binders) ->
            Output(y_diff,y'_diff,proc,new_occurrence ()),
            (y_diff,ch1, ch2)::(y'_diff, term1,term2)::binders
          ) merge_list
      end
  | Input(ch1,pat1,proc1,_),Input(ch2,pat2,proc2,_) ->
      (* WARNING : pat1 and pat2 should both be variable *)
      let type_1 = Terms.get_pat_type pat1
      and type_2 = Terms.get_pat_type pat2 in
      
      if type_1 != type_2 then raise No_Merging;
      
      let x' = Terms.new_var Param.def_var_name type_1
      and old_x1 = Terms.term_of_pattern_variable pat1
      and old_x2 = Terms.term_of_pattern_variable pat2 in
      
      (* Test current_bound_vars *)
      assert(!Terms.current_bound_vars == []);
      
      Terms.link_var old_x1 (TLink (Var x'));
      Terms.link_var old_x2 (TLink (Var x'));
      
      let proc1_substituted = copy_process false proc1
      and proc2_substituted = copy_process false proc2 in
      
      Terms.cleanup ();
      
      (* May raise No_Merging *)
      let merge_list = merge_processes proc1_substituted proc2_substituted in
      
      if Terms.equal_terms ch1 ch2
      then
        begin
          List.map (fun (proc,binders) ->
            Input(ch1,PatVar(x'),proc,new_occurrence ()),
            binders
          ) merge_list
        end
      else
        begin
          let x = Terms.new_var Param.def_var_name Param.channel_type in
          let y_diff = Terms.new_var_def Param.channel_type in
      
          List.map (fun (proc, binders) -> 
            Let(PatVar x, y_diff,
              Input(Var x,PatVar(x'),proc,new_occurrence ()),
              Nil,
              new_occurrence ()
            ),
            (y_diff,ch1,ch2)::binders
          ) merge_list
        end
      
     
      
   | Par(proc1,proc1'),Par(proc2,proc2') ->
       
      let rec get_list_Par_proc proc = match proc with
        |Par(p1,p2) -> (get_list_Par_proc p1) @ (get_list_Par_proc p2)
        |_ -> [proc] in
        
      let list_proc1 = (get_list_Par_proc proc1)@(get_list_Par_proc proc1')
      and list_proc2 = (get_list_Par_proc proc2)@(get_list_Par_proc proc2') in
      
      let length1 = List.length list_proc1
      and length2 = List.length list_proc2 in
      
      if length1 <> length2
      then raise No_Merging;
      
      merge_Par_permutation list_proc1 list_proc2 []
      
   | Restr(_,_,_), _ ->  
          
       let renamed_proc = renaming_process [] process_1 in
            
       let (list_name, next_proc) = extract_list_name renamed_proc in
       
       let merge_proc_list = merge_processes next_proc process_2 in
       
       List.map (fun (p,binders) ->
         List.fold_right (fun a -> fun p' -> Restr(a,p',new_occurrence ())) list_name p,
         binders
       ) merge_proc_list
       
   | _, Restr(_,_,_) ->  
          
       let renamed_proc = renaming_process [] process_2 in
      
       let (list_name, next_proc) = extract_list_name renamed_proc in
       
       let merge_proc_list = merge_processes process_1 next_proc in
       
       List.map (fun (p,binders) ->
         List.fold_right (fun a -> fun p' -> Restr(a,p',new_occurrence ())) list_name p,
         binders
       ) merge_proc_list   
      
   | Let(pat1,term1,proc_then_1,proc_else_1,_),Let(pat2,term2,proc_then_2,proc_else_2,_) ->
      (* WARNING : pat1 and pat2 should both be variable *)
      let type_1 = Terms.get_pat_type pat1
      and type_2 = Terms.get_pat_type pat2 in
      
      begin try
        if type_1 != type_2 then raise No_Merging;
        
        let x = Terms.new_var Param.def_var_name type_1
        and old_x1 = Terms.term_of_pattern_variable pat1
        and old_x2 = Terms.term_of_pattern_variable pat2 in
      
        (* Test current_bound_vars *)
        assert (!Terms.current_bound_vars == []);
      
        Terms.link_var old_x1 (TLink (Var x));
        Terms.link_var old_x2 (TLink (Var x));
        
        let proc1_substituted = follow_process proc_then_1
        and proc2_substituted = follow_process proc_then_2 in
        
        Terms.cleanup ();
        
        (* Case Mlet1 *)
        let merge_list_then = merge_processes proc1_substituted proc2_substituted
        and merge_list_else = merge_processes proc_else_1 proc_else_2 in
          
        let y_diff = Terms.new_var_def type_1 in
      
        List.fold_left (fun acc1 -> fun (p_then, b_then) ->
          List.fold_left (fun acc2 -> fun (p_else, b_else) ->
            (Let(PatVar(x), y_diff, p_then, p_else, new_occurrence ()),
            (y_diff, term1, term2)::(b_then@b_else)) :: acc2
          ) acc1 merge_list_else
        ) [] merge_list_then
          
      with No_Merging -> 
      begin
        (* Case Mlet2 and Mlet3 are not applied when Mlet1 succeeds *)

        let x1 = Terms.new_var Param.def_var_name type_1
        and x2 = Terms.new_var Param.def_var_name type_2
        and old_x1 = Terms.term_of_pattern_variable pat1
        and old_x2 = Terms.term_of_pattern_variable pat2 in
      
        (* Test current_bound_vars *)
        assert (!Terms.current_bound_vars == []);
      
        Terms.link_var old_x1 (TLink (Var x1));
        Terms.link_var old_x2 (TLink (Var x2));
        
        let proc1_substituted = follow_process proc_then_1
        and proc2_substituted = follow_process proc_then_2 in
        
        Terms.cleanup ();
        
        let main_result = ref [] in
        
        (* Mlet2 *)
        
        begin try
          let merge_list_then_1 = merge_processes proc1_substituted process_2
          and y_diff = Terms.new_var_def type_1
          and c_o = Terms.glet_constant_never_fail_fun type_1 in
          
          main_result := !main_result @ (List.map (fun (p_then, b_then) -> 
              Let(PatVar(x1),y_diff, p_then, proc_else_1,new_occurrence ()),
              (y_diff,term1,FunApp(c_o,[]))::b_then
            ) merge_list_then_1);
          
        with 
          No_Merging -> ()
        end;
          
        (* Mlet2' *)
        
        begin try
          let merge_list_then_2 = merge_processes process_1 proc2_substituted
          and y_diff = Terms.new_var_def type_2
          and c_o = Terms.glet_constant_never_fail_fun type_2 in
          
          main_result := !main_result @ (List.map (fun (p_then, b_then) -> 
              Let(PatVar(x2),y_diff, p_then, proc_else_2,new_occurrence ()),
              (y_diff,FunApp(c_o,[]),term2)::b_then
            ) merge_list_then_2)
          
        with 
          No_Merging -> ()
        end;
          
        (* Mlet3 *)
        
        begin try
          let merge_list_else_1 = merge_processes proc_else_1 process_2
          and y_diff = Terms.new_var_def type_1
          and fail = Terms.get_fail_term type_1 in
          
          main_result := !main_result @ (List.map (fun (p_else, b_else) -> 
              Let(PatVar(x1),y_diff, proc1_substituted, p_else,new_occurrence ()),
              (y_diff,term1,fail)::b_else
            ) merge_list_else_1)
          
        with 
          No_Merging -> ()
        end;
          
        (* Mlet3' *)
        
        begin try
          let merge_list_else_2 = merge_processes process_1 proc_else_2
          and y_diff = Terms.new_var_def type_2
          and fail = Terms.get_fail_term type_2 in
          
          main_result := !main_result @ (List.map (fun (p_else, b_else) -> 
              Let(PatVar(x2),y_diff, proc2_substituted, p_else,new_occurrence ()),
              (y_diff,fail,term2)::b_else
            ) merge_list_else_2)
          
        with 
          No_Merging -> ()
        end;
        
        if !main_result = []
        then raise No_Merging
        else !main_result
        
      end
      end

  | Let(pat1,term1,proc_then_1,proc_else_1,_),_ ->
      (* WARNING : pat1 and pat2 should both be variable *)
      let type_1 = Terms.get_pat_type pat1 in  
      
      let x1 = Terms.new_var Param.def_var_name type_1
      and old_x1 = Terms.term_of_pattern_variable pat1 in
      
      (* Test current_bound_vars *)
      assert (!Terms.current_bound_vars == []);
      
      Terms.link_var old_x1 (TLink (Var x1));
        
      let proc1_substituted = follow_process proc_then_1 in
        
      Terms.cleanup ();
        
      let main_result = ref [] in    
      
      (* Mlet2 *)
        
      begin try
        let merge_list_then_1 = merge_processes proc1_substituted process_2
        and y_diff = Terms.new_var_def type_1
        and c_o = Terms.glet_constant_never_fail_fun type_1 in
          
        main_result := !main_result @ (List.map (fun (p_then, b_then) -> 
            Let(PatVar(x1),y_diff, p_then, proc_else_1,new_occurrence ()),
            (y_diff,term1,FunApp(c_o,[]))::b_then
          ) merge_list_then_1);
          
      with 
        No_Merging -> ()
      end;
          
      (* Mlet3 *)
        
      begin try
        let merge_list_else_1 = merge_processes proc_else_1 process_2
        and y_diff = Terms.new_var_def type_1
        and fail = Terms.get_fail_term type_1 in
          
        main_result := !main_result @ (List.map (fun (p_else, b_else) -> 
            Let(PatVar(x1),y_diff, proc1_substituted, p_else,new_occurrence ()),
            (y_diff,term1,fail)::b_else
          ) merge_list_else_1)
          
      with 
        No_Merging -> ()
      end;
            
      if !main_result = []
      then raise No_Merging
      else !main_result
      
  | _,Let(pat2,term2,proc_then_2,proc_else_2,_) ->
      (* WARNING : pat1 and pat2 should both be variable *)
      let type_2 = Terms.get_pat_type pat2 in  
      
      let x2 = Terms.new_var Param.def_var_name type_2
      and old_x2 = Terms.term_of_pattern_variable pat2 in
      
      (* Test current_bound_vars *)
      assert (!Terms.current_bound_vars == []);
      
      Terms.link_var old_x2 (TLink (Var x2));
        
      let proc2_substituted = follow_process proc_then_2 in
        
      Terms.cleanup ();
        
      let main_result = ref [] in  
               
      (* Mlet2' *)
        
      begin try
        let merge_list_then_2 = merge_processes process_1 proc2_substituted
        and y_diff = Terms.new_var_def type_2
        and c_o = Terms.glet_constant_never_fail_fun type_2 in
          
        main_result := !main_result @ (List.map (fun (p_then, b_then) -> 
            Let(PatVar(x2),y_diff, p_then, proc_else_2,new_occurrence ()),
            (y_diff,FunApp(c_o,[]),term2)::b_then
          ) merge_list_then_2)
          
      with 
        No_Merging -> ()
      end;
            
      (* Mlet3' *)
        
      begin try
        let merge_list_else_2 = merge_processes process_1 proc_else_2
        and y_diff = Terms.new_var_def type_2
        and fail = Terms.get_fail_term type_2 in
          
        main_result := !main_result @ (List.map (fun (p_else, b_else) -> 
            Let(PatVar(x2),y_diff, proc2_substituted, p_else,new_occurrence ()),
            (y_diff,fail,term2)::b_else
          ) merge_list_else_2)
          
      with 
        No_Merging -> ()
      end;
        
      if !main_result = []
      then raise No_Merging
      else !main_result
      
  | Repl(proc_1,_), Repl(proc_2,_) ->
      
      begin try
        (* Mrepl2 *)
        let merge_list = merge_processes proc_1 proc_2 in
        
        List.map (fun (proc,binders) -> Repl(proc, new_occurrence ()),binders)
          merge_list
          
      with No_Merging ->
        
        begin  
          let main_result = ref [] in  
          
          begin try
            (* Mrepl1 *)
            let (name_list,next_repl) = extract_list_name_followed_by_repl proc_1 in
          
            let renamed_list = List.map (fun n -> 
              let n' = rename_private_name n in
              (n,n')
              ) name_list in
              
            let renamed_proc = renaming_process renamed_list next_repl in
          
            let merge_list = merge_processes renamed_proc process_2 in
            
            main_result := !main_result @ (List.map (fun (m_proc,binders) ->
              Repl(
                List.fold_right (fun (_,a) -> fun p' -> Restr(a,p',new_occurrence ())) renamed_list m_proc,
                new_occurrence ()
              ),
              binders
            ) merge_list)
            
          with 
            No_Merging -> ()
          end;
            
          begin try
            (* Mrepl1' *)
            let (name_list,next_repl) = extract_list_name_followed_by_repl proc_2 in
          
            let renamed_list = List.map (fun n -> 
              let n' = rename_private_name n in
              (n,n')
              ) name_list in
            
            let renamed_proc = renaming_process renamed_list next_repl in
          
            let merge_list = merge_processes process_1 renamed_proc  in
            
            main_result := !main_result @ (List.map (fun (m_proc,binders) ->
              Repl(
                List.fold_right (fun (_,a) -> fun p' -> Restr(a,p',new_occurrence ())) renamed_list m_proc,
                new_occurrence ()
              ),
              binders
            ) merge_list)
            
          with 
            No_Merging -> ()
          end;
          
          if !main_result = []
          then raise No_Merging
          else !main_result
        end
      end
  | _, _ -> raise No_Merging
       
  in
  (*
  Printf.printf "---- DEBUG MERGING---\n";
  print_string "\n---------------------\n";
  Printf.printf "Process 1:\n";
  Display.Text.display_process_occ "" process_1;
  Printf.printf "Process 2:\n";
  Display.Text.display_process_occ "" process_2;
  Printf.printf "The merged process: \n";
  let acc = ref 1 in
  List.iter (fun (p,blist) ->
        print_string "\n---------------------\n";
        Printf.printf "Process %d:\n" !acc;
	Display.Text.display_process_occ "" p;
	Display.Text.newline();
	Printf.printf "Binders %d:" !acc;
	List.iter (fun (var,t1,t2) -> 
	  print_string "(";
	  Display.Text.display_term var;
	  print_string ",";
	  Display.Text.display_term t1;
	  print_string ",";
	  Display.Text.display_term t2;
	  print_string ") - "
	) blist;
	Display.Text.newline();
	acc := !acc + 1
      ) process_list;*)
  process_list
      
(* [merge_Par_permutation proc_list permut_proc_list checked_list]
merges the parallel composition of processes in [proc_list] with
the parallel composition of processes in [permut_proc_list @ checked_list].
The head of [proc_list] is merged with a process in [permut_proc_list].
We tried before to merge the head of [proc_list] with a process in 
[checked_list]. *)

and merge_Par_permutation proc_list permut_proc_list checked_list = 
  match permut_proc_list with
    | [] -> internal_error "[merge_Par_permutation] This case should never happen (1)"
    | [p] ->
        begin
          match proc_list with
            |[] -> internal_error "[merge_Par_permutation] This case should never happen (2)"
            |[p'] -> merge_processes p' p
            |p'::q' -> 
               let proc_merged = merge_processes p' p in
                 
               let smaller_list_merged = merge_Par_permutation q' checked_list [] in
                 
               List.fold_left (fun acc1 -> fun (pq, bq_list) ->
                 List.fold_left (fun acc2 -> fun (p,b_list) ->
                   (Par(p,pq),b_list@bq_list)::acc2
                 ) acc1 proc_merged
               ) [] smaller_list_merged
        end
    | p::q -> 
        try 
          let proc_merged = merge_processes (List.hd proc_list) p in
          
          let smaller_list_merged = merge_Par_permutation (List.tl proc_list) (q@checked_list) [] in
            
          let complete_merged = 
            List.fold_left (fun acc1 -> fun (pq, bq_list) ->
              List.fold_left (fun acc2 -> fun (p, b_list) -> 
                (Par(p,pq),b_list@bq_list)::acc2
              ) acc1 proc_merged
            ) [] smaller_list_merged in
              
          try
            (merge_Par_permutation proc_list q (p::checked_list))@complete_merged
          with
            No_Merging ->
              complete_merged
              
        with 
          No_Merging ->
            merge_Par_permutation proc_list q (p::checked_list)
            
            
(*********************************************
               Simplify process 
**********************************************)	 

(* In this section, we can assume that:
- all patterns are only variables
- There is no Test, LetFilter, Event *)

let one_var_pattern_from_pattern pattern = 

  let rec sub_one_var_pattern_from_pattern cor_term = function
    | PatVar(v) -> Terms.link v (TLink cor_term);
        None
    | PatTuple(f,[]) ->
        Some(FunApp(Terms.equal_fun (snd f.f_type),[FunApp(f,[]);cor_term]))
    | PatTuple(f,pat_list) ->
        let cor_term_list = List.map (fun f -> FunApp(f,[cor_term])) (Terms.get_all_projection_fun f) in
        begin
          match sub_one_var_pattern_from_pattern_list cor_term_list pat_list with
          | None -> 
              let t1 = List.hd cor_term_list in
              Some(FunApp(Terms.success_fun (Terms.get_term_type t1),[t1]))
          | Some(test) ->
              let t1 = List.hd cor_term_list in
              Some(FunApp(Terms.and_fun,[FunApp(Terms.success_fun (Terms.get_term_type t1),[t1]);test]))
        end 
    | PatEqual(t) -> 
       Some(FunApp(Terms.equal_fun (Terms.get_term_type t),[t;cor_term]))
    
  and sub_one_var_pattern_from_pattern_list cor_term_list pattern_list = 
    match pattern_list,cor_term_list with
    | [],[] -> None
    | [],_ | _,[] -> internal_error "[one_var_pattern_from_pattern] The two list should have the same size"
    | pat::pat_l, cor::cor_l ->
        let test_1 = sub_one_var_pattern_from_pattern cor pat in
        let test_2 = sub_one_var_pattern_from_pattern_list cor_l pat_l in
        begin
          match test_1,test_2 with
            | None,None -> None
            | Some(t),None -> Some(t)
            | None,Some(t) -> Some(t)
            | Some(t),Some(t') -> Some(FunApp(Terms.and_fun,[t;t']))
        end 
  in
        
  let x = Terms.new_var Param.def_var_name (Terms.get_pat_type pattern) in
  
  let test_success = sub_one_var_pattern_from_pattern (Var(x)) pattern in
  PatVar(x),test_success
  

  
(** [simplify_process] is not a deterministic function and so returns a list of processes *)
let rec simplify_process process free_var = 
  let process_list = match process with
  | Nil -> [Nil]
  | Output(ch_term,term,proc,occ) ->
      List.map (fun p -> Output(ch_term,term, p, occ)) (simplify_process proc free_var)
  | Input(term,pat,proc,occ) ->
      begin match pat with
        | PatVar(x) -> List.map (fun p -> Input(term,pat,p,occ)) (simplify_process proc (x::free_var))
        | _ ->
            (* Test current_bound_vars *)
            assert (!Terms.current_bound_vars == []);
        
            let pat_x,test_success = one_var_pattern_from_pattern pat in
            
            let new_proc = match test_success with
              | None -> proc
              | Some(t) ->
                  let x = Terms.new_var Param.def_var_name Param.bool_type in
                  Let(PatVar x,FunApp(Terms.is_true_fun,[t]),proc, Nil, new_occurrence ()) in
    
            let proc_substituted = follow_process new_proc in      
            Terms.cleanup ();
            let PatVar(z) = pat_x in
            List.map (fun p -> Input(term,pat_x,p,occ)) (simplify_process proc_substituted (z::free_var))
      end  
  | Par(proc_1,proc_2) ->
      let simpl_list_1 = simplify_process proc_1 free_var
      and simpl_list_2 = simplify_process proc_2 free_var in
  
      List.fold_left (fun acc1 -> fun p1 ->
        List.fold_left (fun acc2 -> fun p2 ->
          (Par(p1,p2))::acc2
        ) acc1 simpl_list_2
      ) [] simpl_list_1
      
  | Restr(a,proc,occ) ->
      List.map (fun p -> Restr(a,p,occ)) (simplify_process proc free_var)
  | Repl(proc,occ) ->
      List.map (fun p -> Repl(p,occ)) (simplify_process proc free_var)
  | Let(pat,term,proc_1,proc_2,occ) ->
      (* OK there is something strange here: you include proc_2
	 as part of new_proc_1 in case the test is not empty 
	 -> Correspond to the case where the test fails. I assumed 
	 that a Let cannot get stuck and always execute either the 
	 then branch or the else-branch.
      *)
      let new_pat, new_proc_1 = match pat with
        | PatVar(_) -> pat, proc_1
        | _ -> 
            (* Test current_bound_vars *)
            assert (!Terms.current_bound_vars == []);
        
            let pat_x,test_success = one_var_pattern_from_pattern pat in
            
            let proc_substituted = 
              match test_success with
                | None -> follow_process proc_1 
                | Some t -> 
		    let y = Terms.new_var Param.def_var_name Param.bool_type in
                    follow_process (Let(PatVar y, FunApp(Terms.is_true_fun,[t]), proc_1, proc_2,new_occurrence ()))
             in
            
            Terms.cleanup ();
            pat_x,proc_substituted
      in
      
      let PatVar(z) = new_pat in
      
      let simpl_list_1 = simplify_process new_proc_1 (z::free_var)
      and simpl_list_2 = simplify_process proc_2 free_var in
      
      let type_term = Terms.get_term_type term in
      let var = Terms.term_of_pattern_variable new_pat in
      let glet_symb = Terms.glet_fun type_term in
      
      let simplify_let simpl_proc_1 simpl_proc_2 = 
        try 
          let merge_list_proc = merge_processes simpl_proc_1 simpl_proc_2 in
        
          (* Test current_bound_vars *)
          assert(!Terms.current_bound_vars == []);
        
          List.map (fun (proc,binders) ->
            List.iter (fun (x,m1,m2) ->
              (* Code with gletin 
              let type_m1 = Terms.get_term_type m1 in
              let gletin_symb = get_gletin_symb type_term type_m1 in
              Terms.link_var x (Types.TLink (FunApp(gletin_symb,[var;m1;m2])));
              *)
              
              let type_m1 = Terms.get_term_type m1 in
              let not_caught_symb = Terms.not_caught_fail_fun type_term in
              
              Terms.link_var x (Types.TLink (FunApp(Terms.gtest_fun type_m1,[FunApp(not_caught_symb,[var]);m1;m2])));
            ) binders;
          
            let followed_proc = follow_process proc in
          
            Terms.cleanup ();
          
            Let(new_pat,FunApp(glet_symb,[term]),followed_proc,Nil,occ)
        
          ) merge_list_proc
      
        with
          No_Merging ->  [Let(new_pat,term,simpl_proc_1, simpl_proc_2,occ)] in
          
      List.fold_left (fun acc1 -> fun p1 ->
        List.fold_left (fun acc2 -> fun p2 -> 
          (simplify_let p1 p2) @ acc2
        ) acc1 simpl_list_2
      ) [] simpl_list_1   

  | Test(t,proc_1,proc_2,occ) ->
      let x = Terms.new_var Param.def_var_name Param.bool_type
      and y = Terms.new_var Param.def_var_name Param.bool_type in
      
      let new_proc = 
        Let(PatVar(x),t,
          Let(PatVar(y),FunApp(Terms.is_true_fun,[Var(x)]),
            proc_1,
            proc_2,
            new_occurrence()
          ),
          Nil,
          new_occurrence ()
        ) in
      
      simplify_process new_proc free_var
      
  | Phase(n, proc,occ) -> List.map (fun p -> Phase(n,p,occ)) (simplify_process proc free_var)
  | LetFilter(_,_,_,_,_) -> input_error "Simplify do not support LetFilter in the process" dummy_ext
  | Event(t,proc,occ) -> 
      (* Events can be ignored in proofs of equivalences.
	 Still, the term t is always evaluated. *)
      let v = Terms.new_var Param.def_var_name (Terms.get_term_type t) in
      simplify_process (Let(PatVar v, t, proc, Nil, occ)) free_var

  | Insert(term, proc,occ) -> 
      List.map (fun p -> Insert(term, p, occ)) (simplify_process proc free_var)
  | Get(pat, term, proc, proc_else, occ) -> 
      begin
	let simpl_list_2 = simplify_process proc_else free_var in
	match pat with
	  PatVar x -> 
	    let simpl_list_1 = simplify_process proc (x::free_var) in
	    List.fold_left (fun acc1 -> fun p1 ->
              List.fold_left (fun acc2 -> fun p2 ->
		(Get(pat, term,p1,p2,occ))::acc2
	      ) acc1 simpl_list_2
	    ) [] simpl_list_1
	| _ -> 
            (* Test current_bound_vars *)
            assert(!Terms.current_bound_vars == []);
        
            let pat_x,test_success = one_var_pattern_from_pattern pat in
            
            let new_term = match test_success with
              | None -> term
              | Some(t) ->
		  (* t is true when the pattern-matching succeeds,
		     false or fail otherwise. *)
                  FunApp(Terms.and_fun, [FunApp(Terms.success_fun Param.bool_type, [FunApp(Terms.is_true_fun, [t])]); term])
	    in
            let proc_substituted = follow_process proc in      
	    let term_substituted = Terms.copy_term3 new_term in
            Terms.cleanup ();
            let PatVar(z) = pat_x in
	    let simpl_list_1 = simplify_process proc_substituted (z::free_var) in
	    List.fold_left (fun acc1 -> fun p1 ->
              List.fold_left (fun acc2 -> fun p2 ->
		(Get(pat_x, term_substituted,p1,p2,occ))::acc2
	      ) acc1 simpl_list_2
	    ) [] simpl_list_1
      end
  in
  
  (*Printf.printf "---- DEBUG ---\n";
  print_string "\n---------------------\n";
  Printf.printf "Process:\n";
  Display.Text.display_process_occ "" process;
  Printf.printf "The simplified process: \n";
  let acc = ref 1 in
  List.iter (fun p ->
        print_string "\n---------------------\n";
        Printf.printf "Process %d:\n" !acc;
	Display.Text.display_process_occ "" p;
	Display.Text.newline();
	acc := !acc + 1
      ) process_list;
  process_list*)
  
  List.iter (verify_process free_var) process_list;
  process_list
  
let simplify_processes p = 
  simplify_process p [] 

(*********************************************
           Biprocess from processes 
**********************************************)	
  
(* We define an exception that expresses the impossibility to transform two processes into
   a biprocess. *)
      
exception No_biprocess_possible

(** The processes in argument of this function should not contain any diff.
    The function returns a list of biprocesses. *)
let obtain_biprocess_from_processes process_1 process_2 = 
  let simpl_list_1 = simplify_process process_1 []
  and simpl_list_2 = simplify_process process_2 [] in
  
  let possible_biprocesses = 
    List.fold_left (fun acc1 -> fun p1 ->
      List.fold_left (fun acc2 -> fun p2 ->
        try
          let merge_list = merge_processes p1 p2 in
          
          List.fold_left (fun acc3 -> fun (bi_proc,binders) ->
            assert(!Terms.current_bound_vars == []);
            
            List.iter (fun (x,m1,m2) ->
              let type_m1 = Terms.get_term_type m1 in
              let choice_symb = Param.choice_fun type_m1 in
              Terms.link_var x (Types.TLink (FunApp(choice_symb,[m1;m2])));
            ) binders;
          
            let copied_proc = follow_process bi_proc in
            Terms.cleanup ();
            copied_proc::acc3
          ) acc2 merge_list
        with 
          No_Merging -> acc2
      ) acc1 simpl_list_2
    ) [] simpl_list_1 in
    
  if possible_biprocesses = []
  then raise No_biprocess_possible
  else possible_biprocesses
  
