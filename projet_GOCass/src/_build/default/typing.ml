 
open Format
open Lib
open Ast
open Tast

open Hashtbl

let debug = ref false

let dummy_loc = Lexing.dummy_pos, Lexing.dummy_pos

exception Error of Ast.location * string

let error loc e = raise (Error (loc, e))

(* TODO environnement pour les types structure *)

let context_struct = create 10

(* TODO environnement pour les fonctions *)

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
    (* TODO *) TEconstant c, tvoid, false
  | PEbinop (op, e1, e2) ->
    (* TODO *) assert false
  | PEunop (Uamp, e1) ->
    (* TODO *) assert false
  | PEunop (Uneg | Unot | Ustar as op, e1) ->
    (* TODO *) assert false
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
     (* TODO *) assert false
  | PEif (e1, e2, e3) ->
     (* TODO *) assert false
  | PEnil ->
     (* TODO *) assert false
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
      let _ = List.map (expr env) el in (); TEblock [], tvoid, false
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
