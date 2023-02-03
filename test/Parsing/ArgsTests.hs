module Parsing.ArgsTests where

import Parsing ()
import Parsing.Args (Args (..), parse)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@=?))

parseArgsTest :: String -> [String] -> Args -> [String] -> TestTree
parseArgsTest testName arr restest nonargs = testCase testName $ do
  (res, fs) <- parse arr
  restest @=? res
  nonargs @=? fs

argsSuite :: TestTree
argsSuite =
  testGroup
    "Parsing.Args Test Suite"
    [ noArgs,
      fileNonArg,
      shortDebugFlagWithFile,
      fileViaLongFlag,
      longDebugFlag
    ]
  where
    noArgs = parseArgsTest "Empty Args" [] Args {file = Nothing, help = False, debug = False} []
    fileNonArg = parseArgsTest "File via non flag params" ["file.scm"] Args {file = Nothing, help = False, debug = False} ["file.scm"]
    shortDebugFlagWithFile = parseArgsTest "Short debug flag with File" ["file.scm", "-d"] Args {file = Nothing, help = False, debug = True} ["file.scm"]
    fileViaLongFlag = parseArgsTest "Filename via flag" ["--file=filename"] Args {file = Just "filename", help = False, debug = False} []
    longDebugFlag = parseArgsTest "Long debug flag" ["--debug"] Args {file = Nothing, help = False, debug = True} []
