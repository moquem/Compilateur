 
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

let context_struct = create 10;;

let context_field = create 10;;

(* TODO environnement pour les fonctions *)

let context_func = create 10;;

let rec struct_corresp l name = match l with
  | ({s_name;s_fields} as res)::q when s_name = name -> res
  | h::q -> struct_corresp q name
  | [] -> error dummy_loc ("unknown struct ") 

let rec type_type = function
  | PTident { id = "int" } -> Tint
  | PTident { id = "bool" } -> Tbool
  | PTident { id = "string" } -> Tstring
  | PTident { id } -> Tstruct(struct_corresp !context_struct id)
  | PTptr ty -> Tptr (type_type ty)
  | _ -> error dummy_loc ("unknown struct ") 

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
     (* TODO *) assert false




let found_main = ref false

(* 1. declare structures *)

let rec exist_struct l name = match l with
  | [] -> false
  | {s_name;s_fields}::q when s_name = name -> true
  | h::q -> exist_struct q name

let field_to_tfield l_field = 
  let rec aux l_anc l_nv = match l_anc with
    | [] -> l_nv
    | ({id;loc},typ)::q -> aux q ({f_name = id; f_typ = typ; f_ofs = 0}::l_nv)
  in aux l_field []

let phase1 = function
  | PDstruct { ps_name = { id = id; loc = loc }} -> 
      begin
        if exist_struct !context_struct id then raise (Error (loc,"Structure déjà définie"))
        else ()
      end
  | PDfunction _ -> ()

let show_phase1 = function
  | {id = id; loc = loc} -> (print_string(id);print_string("\n"))

let sizeof = function
  | Tint | Tbool | Tstring | Tptr _ -> ()
  | _ -> (* TODO *) assert false 

(* 2. declare functions and type fields *)

let rec param_used l name = match l with
  | [] -> false
  | ({loc;id},_):: q when id = name -> true
  | h::q -> param_used q name

let rec param_distinct l_param = match l_param with
  | [] -> true
  | ({loc;id},_)::q -> if param_used q id then false else param_distinct q

let rec typ_param l_param = match l_param with
  | [] -> true
  | ({loc = loc1 ;id = id1},PTident {loc = loc;id = id})::q when (id = "bool" || id = "int" || id = "id") -> typ_param q
  | ({loc = loc1 ;id = id1},PTident {loc = loc;id = id})::q when List.mem id !context_struct -> typ_param q
  | ({loc;id},PTptr (typ))::q -> typ_param (({loc;id},typ)::q)
  | _ -> false
  
let rec typ_func l = match l with
  | [] -> true
  | (PTident {id;loc})::q when (id = "bool" || id = "int" || id = "id") -> typ_func q
  | (PTident {id;loc})::q when List.mem id !context_struct -> typ_func q
  | (PTptr (typ))::q -> typ_func (typ::q)
  | _ -> false

let phase2 = function
  | PDfunction { pf_name=({id; loc}) as res ; pf_params=pl; pf_typ=tyl; } ->
      begin
        if id = "main" then found_main := true;
        if name_used !context_func id then raise (Error (loc,"Fonction déjà déclarée"))
        else context_func := res::(!context_func);
        if not(param_distinct pl) then raise (Error (loc,"Paramètre passé en double"));
        if not(typ_param pl) then raise (Error (loc,"Paramètre mal typé (type inexistant)"));
        if not(typ_func tyl) then raise (Error (loc,"Fonction mal typée (type inexistant)"))
      end
  | PDstruct { ps_name = {id;loc}; ps_fields = fl } ->
      begin
        if not(param_distinct fl) then raise (Error (loc,"Champs passé en double"));
        if not(typ_param fl) then raise (Error (loc,"Champs mal typé (type inexistant)"));
        context_field := fl::(!context_field)
      end

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
