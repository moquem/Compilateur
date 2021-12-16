(* TO DO LIST DE PROJET
- Pour les comparaisons, plutôt que faire des jump un peu lourd, on peut charger la valeur du flag
*)




(* étiquettes
     F_function      entrée fonction
     E_function      sortie fonction
     L_xxx           sauts
     S_xxx           chaîne

   expression calculée avec la pile si besoin, résultat final dans %rdi

   fonction : arguments sur la pile, résultat dans %rax ou sur la pile

            res k
            ...
            res 1
            arg n
            ...
            arg 1
            adr. retour
   rbp ---> ancien rbp
            ...
            var locales
            ...
            calculs
   rsp ---> ...

*)

open Format
open Ast
open Tast
open X86_64
open Typing

let debug = ref false

let tvoid = Tmany []

let strings = Hashtbl.create 32
let alloc_string =
  let r = ref 0 in
  fun s ->
    incr r;
    let l = "S_" ^ string_of_int !r in
    Hashtbl.add strings l s;
    l

let malloc n = movq (imm n) (reg rdi) ++ call "malloc"
let allocz n = movq (imm n) (reg rdi) ++ call "allocz"

let sizeof = Typing.sizeof

let new_label =
  let r = ref 0 in fun () -> incr r; "L_" ^ string_of_int !r

type env = {
  exit_label: string;
  ofs_this: int;
  nb_locals: int ref; (* maximum *)
  next_local: int; (* 0, 1, ... *)
}

let empty_env =
  { exit_label = ""; ofs_this = -1; nb_locals = ref 0; next_local = 0 }

let mk_bool d = { expr_desc = d; expr_typ = Tbool }

(* f reçoit le label correspondant à ``renvoyer vrai'' *)
let compile_bool f =
  let l_true = new_label () and l_end = new_label () in
  f l_true ++
  movq (imm 0) (reg rdi) ++ jmp l_end ++
  label l_true ++ movq (imm 1) (reg rdi) ++ label l_end

let rec expr env e = match e.expr_desc with
  | TEskip ->
    nop
  | TEconstant (Cbool true) ->
    movq (imm 1) (reg rdi)
  | TEconstant (Cbool false) ->
    movq (imm 0) (reg rdi)
  | TEconstant (Cint x) ->
    movq (imm64 x) (reg rdi)
  | TEnil ->
    xorq (reg rdi) (reg rdi)
  | TEconstant (Cstring s) ->
    (* TODO code pour constante string *) assert false 
  | TEbinop (Band, e1, e2) ->
    let l1,l2 = new_label(),new_label() in
    (expr env e1) 
    ++ movq (imm 0) (reg rbx) 
    ++ cmpq (reg rdi) (reg rbx) 
    ++ je l1 
    ++ (expr env e2)
    ++ movq (imm 0) (reg rbx)
    ++ cmpq (reg rdi) (reg rbx) 
    ++ je l1 
    ++ movq (imm 1) (reg rdi) ++ jmp l2
    ++ label l1 ++ movq (imm 0) (reg rdi) 
    ++ label l2
  | TEbinop (Bor, e1, e2) ->
    let l1,l2 = new_label(),new_label() in
    (expr env e1)
    ++ movq (imm 0) (reg rbx)
    ++ cmpq (reg rdi) (reg rbx)
    ++ jne l1
    ++ (expr env e2)
    ++ movq (imm 0) (reg rbx)
    ++ cmpq (reg rdi) (reg rbx) 
    ++ jne l1 
    ++ movq (imm 0) (reg rdi) ++ jmp l2
    ++ label l1 ++ movq (imm 1) (reg rdi) 
    ++ label l2
  | TEbinop (Blt | Ble | Bgt | Bge as op, e1, e2) ->
    begin
    let t1 = (expr env e1) 
            ++ pushq (reg rdi) 
            ++ (expr env e2) 
            ++ popq rbx 
            ++ cmpq (reg rdi) (reg rbx) 
    and l1,l2 = new_label (),new_label () in
      let t2 = movq (imm 0) (reg rdi) 
            ++ jmp l2 
            ++ label l1 
            ++ movq (imm 1) (reg rdi) 
            ++ label l2 in
      match op with
        | Blt -> t1 ++ jl l1 ++ t2
        | Ble -> t1 ++ jle l1 ++ t2
        | Bgt -> t1 ++ jg l1 ++ t2
        | Bge -> t1 ++ jge l1 ++ t2
    end
  | TEbinop (Badd | Bsub | Bmul | Bdiv | Bmod as op, e1, e2) ->
    begin
    let t = (expr env e1) ++ pushq (reg rdi) ++ (expr env e2) in
    match op with
      | Badd -> t ++ popq rbx ++ addq (reg rbx) (reg rdi)
      | Bsub -> t ++ movq (reg rdi) (reg rbx) ++ popq rdi ++ subq (reg rbx) (reg rdi)
      | Bmul -> t ++ popq rbx ++ imulq (reg rbx) (reg rdi)
      | Bdiv -> t ++ popq rax ++ movq (imm 0) (reg rdx) ++ idivq (reg rdi) ++ movq (reg rax) (reg rdi)
      | Bmod -> t ++ popq rax ++ movq (imm 0) (reg rdx) ++ idivq (reg rdi) ++ movq (reg rdx) (reg rdi)
    end
  | TEbinop (Beq | Bne as op, e1, e2) ->
    (* TODO code pour egalite toute valeur *) assert false 
  | TEunop (Uneg, e1) ->
    (expr env e1) ++ negq (reg rdi) 
  | TEunop (Unot, e1) ->
    (expr env e1) ++ notq (reg rdi)
  | TEunop (Uamp, e1) ->
    (* TODO code pour & *) assert false 
  | TEunop (Ustar, e1) ->
    (* TODO code pour * *) assert false 
  | TEprint el -> 
    begin 
      match el with
      | [] -> nop
      | h::q ->
      begin
      match h.expr_typ with
        | Tint | Tbool -> (expr env h) 
                          ++ (call "print_int") 
                          ++ (expr env {expr_desc=(TEprint q);expr_typ=tvoid})
        | _ -> assert false
      end
    end
  | TEident x ->
    (* TODO code pour x *) assert false 
  | TEassign ([{expr_desc=TEident x}], [e1]) ->
    (* TODO code pour x := e *) assert false 
  | TEassign ([lv], [e1]) ->
    (* TODO code pour x1,... := e1,... *) assert false 
  | TEassign (_, _) ->
     assert false
  | TEblock el -> 
  begin
  match el with 
      | [] -> nop
      | h::q -> (expr env h) ++ (expr env {expr_desc = TEblock q; expr_typ = tvoid})
  end
  | TEif (e1, e2, e3) ->
    let l1,l2 = new_label(),new_label() in
    (expr env e1) 
    ++ movq (imm 0) (reg rbx) 
    ++ cmpq (reg rdi) (reg rbx) 
    ++ jne l1 ++ (expr env e3) 
    ++ jmp l2 ++ label l1 
    ++ (expr env e2) 
    ++ label l2
  | TEfor (e1, e2) ->
    let l1,l2 = new_label(),new_label() in
    label l1 ++ (expr env e1) 
    ++ movq (imm 0) (reg rbx) 
    ++ cmpq (reg rdi) (reg rbx) 
    ++ je l2 
    ++ (expr env e2) 
    ++ jmp l1 
    ++ label l2
  | TEnew ty ->
     (* TODO code pour new S *) assert false
  | TEcall (f, el) ->
     (* TODO code pour appel fonction *) assert false
  | TEdot (e1, {f_ofs=ofs}) ->
     (* TODO code pour e.f *) assert false
  | TEvars _ ->
     assert false (* fait dans block *)
  | TEreturn [] ->
    (* TODO code pour return e *) assert false
  | TEreturn [e1] ->
    (* TODO code pour return e1,... *) assert false
  | TEreturn _ ->
     assert false
  | TEincdec (e1, op) ->
    (* TODO code pour return e++, e-- *) assert false

let function_ f e =
  if !debug then eprintf "function %s:@." f.fn_name;
  let text = expr Env.empty e in 
  let s = f.fn_name in ( label ("F_" ^ s) ++ text ++ inline "ret" )

let decl code = function
  | TDfunction (f, e) -> code ++ function_ f e
  | TDstruct _ -> code

let file ?debug:(b=false) dl =
  debug := b;
  (* TODO calcul offset champs *)
  (* TODO code fonctions *) let funs = List.fold_left decl nop dl in
  { text =
      globl "main" ++ label "main" ++
      call "F_main" ++
      xorq (reg rax) (reg rax) ++
      ret ++
      funs ++
      inline "
print_int:
        movq    %rdi, %rsi
        movq    $S_int, %rdi
        xorq    %rax, %rax
        call    printf
        ret
"; (* TODO print pour d'autres valeurs *)
   (* TODO appel malloc de stdlib *)
    data =
      label "S_int" ++ string "%ld" ++
      (Hashtbl.fold (fun l s d -> label l ++ string s ++ d) strings nop)
    ;
  }
