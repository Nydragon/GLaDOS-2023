module Parsing.Ast where

import qualified Parsing.Cpt as Cpt

-- ─── Abstract Syntaxe Tree ───────────────────────────────────────────────────────────────────────

data Expr = ExprList [Expr]
    | Num Integer
    | Boolean Bool
    | Symbole String
    | Call String [Expr] -- Will also be used for the boolean expression
    | Null -- Instead of using Maybe Expr
    deriving (Eq, Show)

-- ─── Parsing ─────────────────────────────────────────────────────────────────────────────────────

-- This function parses lists of expressions, ignoring function calls
-- AT LEAST at first level
-- This means it will only parse function calls in sublists thanks to parseExpr
parseExprList :: [Cpt.Cpt] -> [Expr]
parseExprList [] = []
parseExprList (x : xs) = case x of
    Cpt.Sym str -> Symbole str : parseExprList xs
    Cpt.Val i -> Num i : parseExprList xs
    Cpt.List ls -> parseExpr ls : parseExprList xs
    Cpt.Boolean b -> Boolean b : parseExprList xs

-- Parses a CPT list into a single Expr value
parseExpr :: [Cpt.Cpt] -> Expr
parseExpr (Cpt.Sym str : xs) = if isValidBuiltin str then
    Call str (parseExprList xs) else ExprList (parseExprList original)
    where original = Cpt.Sym str : xs
parseExpr ls = ExprList (parseExprList ls)

-- ─── Utilities ───────────────────────────────────────────────────────────────────────────────────

-- Utility function for execution
-- Converts cpt list to Expr Call
-- IMPORTANT : Returns nothing in case of error
exprListToCall :: [Expr] -> Maybe Expr
exprListToCall [] = Nothing
exprListToCall (Symbole name : xs) = Just (Call name xs)
exprListToCall _ = Nothing

-- This is where we put builtins
isValidBuiltin :: String -> Bool
isValidBuiltin "define" = True
isValidBuiltin "lambda" = True
isValidBuiltin "+" = True
isValidBuiltin "-" = True
isValidBuiltin "/" = True
isValidBuiltin "*" = True
isValidBuiltin "println" = True
isValidBuiltin "noop" = True -- Should be useful in the future, will return list of args
isValidBuiltin _ = False

-- Returns boolean if Expr is atomic. This means it cannot be further reduced.
-- Note: Sym is not atomic as it needs to be reduced to a value
isAtomic :: Expr -> Bool
isAtomic (Num _) = True
isAtomic (Boolean _) = True
isAtomic Null = True
isAtomic _ = False

-- Checks if list is atomic
isListAtomic :: [Expr] -> Bool
isListAtomic = foldr ((&&) . isAtomic) True