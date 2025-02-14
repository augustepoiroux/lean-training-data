import Mathlib.Lean.CoreM
import Mathlib.Lean.Expr.Basic
import Batteries.Lean.HashMap

open Lean Meta

def Lean.ConstantInfo.kind : ConstantInfo → String
  | .axiomInfo  _ => "axiom"
  | .defnInfo   _ => "def"
  | .thmInfo    _ => "theorem"
  | .opaqueInfo _ => "opaque"
  | .quotInfo   _ => "quot" -- Not sure what this is!
  | .inductInfo _ => "inductive"
  | .ctorInfo   _ => "constructor"
  | .recInfo    _ => "recursor"

def main (args : List String) : IO UInt32 := do
  unsafe enableInitializersExecution
  let modules := match args with
  | [] => #[`Mathlib]
  | args => args.toArray.map fun s => s.toName
  initSearchPath (← findSysroot)
  CoreM.withImportModules modules do
    for (n, c) in (← getEnv).constants.map₁ do
      if ! (← n.isBlackListed) then
        IO.println "---"
        IO.println c.kind
        IO.println n
        IO.println (← MetaM.run' do ppExpr c.type)
  return 0
