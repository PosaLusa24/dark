open! Tc
open Jest
open Expect
open Types
module B = Blank
module D = Defaults
module R = Refactor

let handler1 =
  { ast = F (ID "ast1", Variable "request")
  ; spec =
      {module_ = B.newF "HTTP"; name = B.newF "/src"; modifier = B.newF "POST"}
  ; tlid = TLID "handler1" }


let () =
  describe "renameDBReferences" (fun () ->
      let db0 =
        { dbTLID = TLID "db0"
        ; dbName = B.newF "ElmCode"
        ; cols = []
        ; version = 0
        ; oldMigrations = []
        ; activeMigration = None }
      in
      test "database renamed, handler updates variable" (fun () ->
          let h =
            { ast = F (ID "ast1", Variable "ElmCode")
            ; spec =
                { module_ = B.newF "HTTP"
                ; name = B.newF "/src"
                ; modifier = B.newF "POST" }
            ; tlid = TLID "handler1" }
          in
          let model =
            { D.defaultModel with
              toplevels =
                [ {id = TLID "tl-1"; pos = D.origin; data = TLDB db0}
                ; {id = TLID "tl-2"; pos = D.centerPos; data = TLHandler h} ]
            }
          in
          let ops = R.renameDBReferences model "ElmCode" "WeirdCode" in
          let res =
            match ops with
            | [SetHandler (_, _, h)] ->
              ( match h.ast with
              | F (_, Variable "WeirdCode") ->
                  true
              | _ ->
                  false )
            | _ ->
                false
          in
          expect res |> toEqual true ) ;
      test "database renamed, handler does not change" (fun () ->
          let h =
            { ast = F (ID "ast1", Variable "request")
            ; spec =
                { module_ = B.newF "HTTP"
                ; name = B.newF "/src"
                ; modifier = B.newF "POST" }
            ; tlid = TLID "handler1" }
          in
          let model =
            { D.defaultModel with
              toplevels =
                [ {id = TLID "tl-1"; pos = D.origin; data = TLDB db0}
                ; {id = TLID "tl-2"; pos = D.centerPos; data = TLHandler h} ]
            }
          in
          let ops = R.renameDBReferences model "ElmCode" "WeirdCode" in
          expect ops |> toEqual [] ) ) ;
  ()
