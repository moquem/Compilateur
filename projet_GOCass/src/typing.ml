 
open Format
open Lib
open Ast
open Tast

open Hashtbl

let debug = ref false

let dummy_loc = Lexing.dummy_pos, Lexing.dummy_pos

exception Error of Ast.location * string

let error loc e = raise (Error (loc, e))

let context_struct = create 10

let context_func = create 10


let rec type_type loc = function
  | PTident { id = "int" } -> Tint
  | PTident { id = "bool" } -> Tbool
  | PTident { id = "string" } -> Tstring
  | PTident { id } when mem context_struct id -> Tstruct(find context_struct id)
  | PTptr ty -> Tptr (type_type loc ty)
  | _ -> raise (Error (loc, "Type non défini")) 

let rec eq_type ty1 ty2 = match ty1, ty2 with
  | Tint, Tint | Tbool, Tbool | Tstring, Tstring -> true
  | Tstruct s1, Tstruct s2 -> s1 == s2
  | Tptr ty1, Tptr ty2 -> eq_type ty1 ty2
  | _ -> false
    (* TODO autres types *)


let fmt_used = ref false
let fmt_imported = ref false

let evar v = { expr_desc = TEident v; expr_typ = v.v_typ }

let new_var =
  let id = ref 0 in
  fun x loc ?(used=false) ty ->
    incr id;
    { v_name = x; v_id = !id; v_loc = loc; v_typ = ty; v_used = used; v_addr = false }

module Env = struct
  module M = Map.Make(String)
  type t = var M.t
  let empty = M.empty
  let find = M.find
  let add env v = M.add v.v_name v env

  let all_vars = ref []
  let check_unused () =
    let check v =
      if v.v_name <> "_" && v.v_used = false then error v.v_loc "unused variable" in
    List.iter check !all_vars


  let var x loc ?used ty env =
    let v = new_var x loc ?used ty in
    all_vars := v :: !all_vars;
    add env v, v

  (* TODO type () et vecteur de types *)
end

let tvoid = Tmany []
let make d ty = { expr_desc = d; expr_typ = ty }
let stmt d = make d tvoid

let rec expr env e =
 let e, ty, rt = expr_desc env e.pexpr_loc e.pexpr_desc in
  { expr_desc = e; expr_typ = ty }, rt

and expr_desc env loc = function
  | PEskip ->
     TEskip, tvoid, false

  | PEconstant c -> 
    begin 
    match c with
    | Cbool _ -> TEconstant c, Tbool, false
    | Cint _ ->  TEconstant c, Tint, false
    | Cstring _ -> TEconstant c, Tstring, false
    end

  | PEbinop (op, e1, e2) ->
    let exp1,typ1,rt1 = expr_desc env e1.pexpr_loc e1.pexpr_desc and exp2,typ2,rt2 = expr_desc env e2.pexpr_loc e2.pexpr_desc in
      begin
        if not(eq_type typ1 typ2) then raise (Error (loc,"Different types")) 
        else match op with | Badd | Bsub | Bmul | Bdiv | Bmod | Blt | Ble | Bgt | Bge when not(eq_type typ1 Tint) -> error loc ("Type incompatible avec l'opérateur")
                           | Band | Bor when not(eq_type typ1 Tbool) -> error loc ("Type incompatible avec l'opérateur")
                           | Beq | Bne when eq_type typ1 Tbool || eq_type typ1 Tint -> 
                              begin
                              match exp1,exp2 with 
                                | TEnil,TEnil -> error loc ("Empty expressions")
                                | _ ->  TEbinop (op, {expr_desc = exp1; expr_typ = typ1}, {expr_desc = exp2; expr_typ = typ2}),Tbool,false
                              end
                           | Blt | Ble | Bgt | Bge -> TEbinop (op, {expr_desc = exp1; expr_typ = typ1}, {expr_desc = exp2; expr_typ = typ2}),Tbool,false
                           | _ -> TEbinop (op, {expr_desc = exp1; expr_typ = typ1}, {expr_desc = exp2; expr_typ = typ2}),typ1,false
      end

  | PEunop (Uamp, e1) -> 
    begin
    let exp1,typ1,rt1 = expr_desc env e1.pexpr_loc e1.pexpr_desc in 
          match exp1,typ1 with
            | TEnil,_ -> error loc "Empty expression" 
            | _,Tptr t -> TEunop (Uamp, {expr_desc = exp1; expr_typ = typ1}), t, false 
            | _ -> error loc "Expected : pointeur type"
    end

  | PEunop (Uneg, e1) -> 
    begin 
    let exp1,typ1,rt1 = expr_desc env e1.pexpr_loc e1.pexpr_desc in
      if eq_type typ1 Tint then TEunop (Uneg, {expr_desc = exp1; expr_typ = typ1}), Tint, false
      else error loc "Expected : int type"
    end

  | PEunop (Unot, e1) ->
    begin 
      let exp1,typ1,rt1 = expr_desc env e1.pexpr_loc e1.pexpr_desc in
        if eq_type typ1 Tbool then TEunop (Uneg, {expr_desc = exp1; expr_typ = typ1}), Tbool, false
        else error loc "Expected : bool type"
    end
  
  | PEunop (Ustar as op, e1) ->
    begin
      let exp1,typ1,rt1 = expr_desc env e1.pexpr_loc e1.pexpr_desc in
        TEunop (Ustar, {expr_desc = exp1; expr_typ = typ1}), Tptr typ1, false
    end

  | PEcall ({id = "fmt.Print"}, el) -> (fmt_used := true; TEprint [], tvoid, false)

  | PEcall ({id="new"}, [{pexpr_desc=PEident {id}}]) ->
     let ty = match id with
       | "int" -> Tint | "bool" -> Tbool | "string" -> Tstring
       | _ -> (* TODO *) error loc ("no such type " ^ id) in
     TEnew ty, Tptr ty, false

  | PEcall ({id="new"}, _) ->
     error loc "new expects a type"

  | PEcall (id, el) ->
     (* TODO *) assert false

  | PEfor (e, b) ->
    begin
      let exp1,typ1,rt1 = expr_desc env e.pexpr_loc e.pexpr_desc and exp2,typ2,rt2 = expr_desc env b.pexpr_loc b.pexpr_desc in
        if not(eq_type typ1 Tbool) then error loc "Expected : boolean expression for the condition"
        else TEfor ({expr_desc = exp1; expr_typ = typ1},{expr_desc = exp2; expr_typ = typ2}), tvoid, false
    end

  | PEif (e1, e2, e3) ->
    let exp1,typ1,rt1 = expr_desc env e1.pexpr_loc e1.pexpr_desc 
      and exp2,typ2,rt2 = expr_desc env e2.pexpr_loc e2.pexpr_desc
      and exp3,typ3,rt3 = expr_desc env e3.pexpr_loc e3.pexpr_desc in
      if eq_type typ1 Tbool then 
        TEif ({expr_desc = exp1; expr_typ = typ1},{expr_desc = exp2; expr_typ = typ2},{expr_desc = exp3; expr_typ = typ3}),tvoid,rt2&&rt3
      else raise (Error (loc, "Expected : boolean expressions"))

  | PEnil -> TEnil, tvoid, false

  | PEident {id=id} ->
     (* TODO *) (try let v = Env.find id env in TEident v, v.v_typ, false
      with Not_found -> error loc ("unbound variable " ^ id))

  | PEdot (e, id) ->
     (* TODO *) assert false

  | PEassign (lvl, el) ->
     (* TODO *) TEassign ([], []), tvoid, false 

  | PEreturn el ->
     (* TODO *) TEreturn [], tvoid, true

  | PEblock el ->
      (*TODO*) let _ = List.map (expr env) el in (); TEblock [], tvoid, false

  | PEincdec (e, op) ->
     (* TODO *) assert false

  | PEvars _ -> 
     (* TODO *) TEvars [], tvoid, false


let found_main = ref false

(* 1. declare structures *)

let rec exist_struct l name = match l with
  | [] -> false
  | {s_name;s_fields}::q when s_name = name -> true
  | h::q -> exist_struct q name

let field_to_tfield l_field = 
  let hs_tbl_field = create (List.length l_field) in
    let rec aux = function
      | [] -> ()
      | ({id;loc},typ)::q -> if mem hs_tbl_field id then raise (Error (loc, "Champs passé en double"))
                             else add hs_tbl_field id {f_name = id;f_typ = type_type loc typ;f_ofs = 0}; aux q
    in aux l_field; hs_tbl_field

let phase1 = function
  | PDstruct { ps_name = { id ; loc }; ps_fields} -> 
      begin
        if mem context_struct id then raise (Error (loc,"Structure déjà définie"))
        else add context_struct id { s_name = id; s_fields = (field_to_tfield ps_fields)} 
      end
  | PDfunction _ -> ()


let sizeof = function
  | Tint | Tbool | Tstring | Tptr _ -> ()
  | _ -> (* TODO *) assert false 

(* 2. declare functions and type fields *)

let pparam_to_tparam l_var =
  let rec aux l nv_l = match l with
    | [] -> nv_l
    | ({loc;id},typ)::q -> aux q ((new_var id loc (type_type loc typ))::nv_l)
  in aux l_var []
  
let ptyp_to_ttyp loc l_typ =
  let rec aux l nv_l = match l with
    | [] -> nv_l
    | h::q -> aux q ((type_type loc h)::nv_l)
  in aux l_typ []

let rec name_param_used l_param name = match l_param with
  | [] -> false
  | {v_name}::q when v_name = name -> true
  | h::q -> name_param_used q name 

let rec param_distinct = function
  | [] -> true
  | {v_name}::q -> if name_param_used q v_name then false else param_distinct q

let rec type_well_founded = function
  | Tint | Tbool | Tstring -> true 
  | Tstruct({s_name;_}) when mem context_struct s_name -> true
  | Tptr(t) -> type_well_founded t
  | _ -> false

let rec typ_param = function 
  | [] -> true
  | {v_typ}::q when type_well_founded v_typ -> typ_param q
  | _ -> false

let rec typ_func = function
  | [] -> true
  | typ::q when typ = Tint || typ = Tbool || typ = Tstring -> typ_func q
  | Tstruct({s_name;_})::q when mem context_struct s_name  -> typ_func q
  | Tptr(t)::q -> typ_func (t::q)
  | _ -> false


let rec typ_field l_fields = match l_fields with
  | [] -> true 
  | ({id;loc},typ)::q when type_well_founded (type_type loc typ) -> typ_field q
  | _::q -> false

let phase2 = function
  | PDfunction { pf_name={id; loc} ; pf_params=pl; pf_typ=tyl; pf_body} ->
      begin
        if id = "main" then found_main := true;
        if mem context_func id then raise (Error (loc,"Fonction déjà déclarée"))
        else let new_pl = pparam_to_tparam pl and new_typ = ptyp_to_ttyp loc tyl in
          let f = {fn_name = id; fn_params = (pparam_to_tparam pl); fn_typ = (ptyp_to_ttyp loc tyl)} in
            add context_func id (f,pf_body);
          if not(param_distinct new_pl) then raise (Error (loc,"Paramètre passé en double"))
      end
  | PDstruct { ps_name = {id;loc}; ps_fields = fl } -> 
      if not(typ_field fl) then raise (Error (loc,"Champs mal typé (type inexistant)"))


(* 3. type check function bodies *)
let decl = function
  | PDfunction { pf_name={id; loc}; pf_body = e; pf_typ=tyl; pf_params=pl } ->
    begin
      let f = { fn_name = id; fn_params = []; fn_typ = []} in
      let e, rt = expr Env.empty e in (* TODO *) TDfunction (f, e);
    end

  | PDstruct {ps_name={id}} ->
    (* TODO *) let s = { s_name = id; s_fields = Hashtbl.create 5 } in
     TDstruct s

let file ~debug:b (imp, dl) =
  debug := b;
  (* fmt_imported := imp; *)
  List.iter phase1 dl;
  List.iter phase2 dl;
  if not !found_main then error dummy_loc "missing method main";
  let dl = List.map decl dl in
  Env.check_unused (); (* TODO variables non utilisees *)
  if imp && not !fmt_used then error dummy_loc "fmt imported but not used";
  dl
