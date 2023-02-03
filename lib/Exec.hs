module Exec where

import Control.Exception

import qualified Parsing.Ast as Ast
import Exec.Lookup
import Exec.RuntimeException
import Exec.Builtins

-- ─── Function Execution ──────────────────────────────────────────────────────────────────────────

-- Executes a given function
-- Args : Expr.Call -> Lookup
execFunc :: Ast.Expr -> Lookup -> IO Lookup
execFunc (Ast.Call func ls) reg
    | Ast.isValidBuiltin func = execBuiltin call reg
    | otherwise = throwIO NotYetImplemented
    where   call = Ast.Call func ls

-- ─── Main Function ───────────────────────────────────────────────────────────────────────────────

-- Runs a given list of expressions
--
-- Args : List of expressions (expected to be functions) -> Lookup
-- Expects all base expressions to be valid function calls
run' :: [Ast.Expr] -> Lookup -> IO Lookup
run' [] reg = return reg -- Returns lookup
-- Recursive call on run' using registry returned by the function execution of
run' (Ast.Call func ls:xs) reg = execFunc call reg >>= run' xs
    where   call = Ast.Call func ls
run' (Ast.ExprList ls:xs) reg = case Ast.exprListToCall ls of
    Just x -> execFunc x reg
    Nothing -> throwIO (InvalidFunctionCall "PLACEHOLDER")
        >>= run' xs

-- Entry point function
run :: [Ast.Expr] -> IO Lookup
run ls = run' ls emptyLookup