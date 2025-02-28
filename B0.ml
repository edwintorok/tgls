open B0_kit.V000
open B00_std

(* OCaml library names *)

let ctypes = B0_ocaml.libname "ctypes"
let ctypes_foreign = B0_ocaml.libname "ctypes.foreign"
let integers = B0_ocaml.libname "integers" (* dep of ctypes *)
let bigarray_compat = B0_ocaml.libname "bigarray-compat" (* dep of ctypes *)
let tsdl = B0_ocaml.libname "tsdl"

let xmlm = B0_ocaml.libname "xmlm"
let compiler_libs_toplevel = B0_ocaml.libname "compiler-libs.toplevel"

(* tgls libraries *)

(* Libraries *)

let tgl ~id =
  let base = Fmt.str "tgl%s" id in
  let tgl_name = B0_ocaml.libname ("tgls." ^ base) in
  let tgl =
    let srcs = [ `File (Fpath.v (Fmt.str "src/%s.mli" base));
                 `File (Fpath.v (Fmt.str "src/%s.ml" base)) ]
    in
    let requires = [ctypes; ctypes_foreign; integers; bigarray_compat] in
    B0_ocaml.lib tgl_name ~doc:(Fmt.str "The %s library" id) ~srcs ~requires
  in
  let tgl_top_name = B0_ocaml.libname ("tgls." ^ base ^ ".top") in
  let tgl_top =
    let srcs = [ `File (Fpath.v (Fmt.str "src/%s_top.ml" base)) ] in
    let doc = Fmt.str "The %s toplevel library" id in
    B0_ocaml.lib tgl_top_name ~doc ~srcs ~requires:[compiler_libs_toplevel]
  in
  tgl_name, tgl_top_name, tgl, tgl_top

let tgl3, tgl3_top, tgl3_lib, tgl3_top_lib = tgl ~id:"3"
let tgl4, tgl4_top, tgl4_lib, tgl4_top_lib = tgl ~id:"4"
let tgles2, tgles2_top, tgles2_lib, tgles2_top_lib = tgl ~id:"es2"
let tgles3, tgles3_top, tgles3_lib, tgles3_top_lib = tgl ~id:"es3"

(* API generator *)

let gen =
  let srcs = [`Dir (Fpath.v "support") ] in
  let requires = [xmlm] in
  let doc = "Gl OCaml API generation tool" in
  B0_ocaml.exe "gen" ~srcs ~requires ~doc

(* Tests *)

let test kind ?(requires = []) ~id lib =
  let base = Fmt.str "%sgl%s" kind id in
  let srcs = [`File (Fpath.v (Fmt.str "test/%s.ml" base))] in
  let meta = B0_meta.(empty |> tag test) in
  let requires = ctypes :: lib :: requires in
  let doc = Fmt.str "%s test" base in
  B0_ocaml.exe base ~srcs ~doc ~meta ~requires

let lib_tests ~id lib = test "tri" ~id lib ~requires:[tsdl], test "link" ~id lib

let linktgl3, tritgl3 = lib_tests ~id:"3" tgl3
let linktgl4, tritgl4 = lib_tests ~id:"4" tgl4
let linktgles2, tritgles2 = lib_tests ~id:"es2" tgles2
let linktgles3, tritgles3 = lib_tests ~id:"es3" tgles3

(* Packs *)

let default =
  let meta =
    let open B0_meta in
    empty
    |> tag B0_opam.tag
    |> add authors ["The tgls programmers"]
    |> add maintainers ["Daniel Bünzli <daniel.buenzl i@erratique.ch>"]
    |> add homepage "https://erratique.ch/software/tgls"
    |> add online_doc "https://erratique.ch/software/tgls/doc/"
    |> add licenses ["ISC"]
    |> add repo "git+https://erratique.ch/repos/tgls.git"
    |> add issues "https://github.com/dbuenzli/tgls/issues"
    |> add description_tags
      ["bindings"; "opengl"; "opengl-es"; "graphics"; "org:erratique"]
    |> add B0_opam.Meta.depends
      [ "ocaml", {|>= "4.08.0"|};
        "ocamlfind", {|build|};
        "ocamlbuild", {|build|};
        "topkg", {|build & >= "1.0.3"|};
        "ctypes", {|>= "0.4.0"|};
        "ctypes-foreign", "";
(*        "tsdl", {|with-test|}; *)
        "xmlm", {|dev|};
      ]
    |> add B0_opam.Meta.build
      {|[["ocaml" "pkg/pkg.ml" "build" "--dev-pkg" "%{dev}%"]]|}
  in
  B0_pack.v "default" ~doc:"tgls package" ~meta ~locked:true @@
  B0_unit.list ()
