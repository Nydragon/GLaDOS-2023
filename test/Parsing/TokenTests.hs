module Parsing.TokenTests where

import Test.Tasty
import Test.Tasty.HUnit

import Parsing.Token

listTokenizeTests = [
        ("empty input", "", []),
        ("space", " ", []),
        ("new line", "\n", []),
        ("single digit", "1", [Num 1]),
        ("mulitple digit", "123", [Num 123]),
        ("single Keyword", "keyword", [Keyword "keyword"]),
        ("open scope", "(", [OpenScope]),
        ("close Scope", ")", [CloseScope]),
        ("1 keyword ( 123 )", "1 keyword ( 123 )", [Num 1, Keyword "keyword", OpenScope, Num 123, CloseScope]),
        ("(define x 2)\\n(+ 3 x)", "(define x 2)\n(+ 3 x)", [OpenScope, Keyword "define", Keyword "x", Num 2, CloseScope, OpenScope, Keyword "+", Num 3, Keyword "x", CloseScope])
    ]

parseTokenTests :: TestTree
parseTokenTests = testGroup "parseToken tests"
  [ testCase "OpenScope" $ parseToken "(" @?= OpenScope
  , testCase "CloseScope" $ parseToken ")" @?= CloseScope
  , testCase "Num" $ parseToken "123" @?= Num 123
  , testCase "Negative Num" $ parseToken "-123" @?= Num (-123)
  , testCase "Keyword" $ parseToken "keyword" @?= Keyword "keyword"
  ]

tokenizeTests :: (String, String, [Token]) -> TestTree
tokenizeTests (name, input, output) = testCase ("Test Tokenize " ++ name)  $
        tokenize input @?= output

tokenize'Tests :: (String, String, [Token]) -> TestTree
tokenize'Tests (name, input, output) = testCase ("Test Tokenize' " ++ name)  $
        tokenize' input "" @?= output

loop :: [(String, String, [Token])] -> [TestTree]
loop [] = []
loop (x:[]) = [tokenize'Tests x, tokenizeTests x]
loop (x:xs) = (tokenize'Tests x:tokenizeTests x: loop xs)

tokenizeSuite :: TestTree
tokenizeSuite = testGroup "tokenize tests" (loop listTokenizeTests)

tokenSuite :: TestTree
tokenSuite = testGroup "Parsing.Token Test Suite" [
        parseTokenTests,
        tokenizeSuite
    ]