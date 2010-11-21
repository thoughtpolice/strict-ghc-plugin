{-# LANGUAGE CPP #-}
module Main ( main ) where

#ifdef USE_CHASING_BOTTOMS

import Test.ChasingBottoms

evaluate_and_possibly_timeout what = do
    result <- timeOut'
    case result of
            NonTermination -> putStrLn "Test successful"
            Value val -> putStrLn $ "Test failed due to the thing compiled terminating with value: " ++ show val

#else

import Control.Exception ( evaluate )

evaluate_and_possibly_timeout what = do
    val <- evaluate what
    putStrLn $ "Test failed due to the thing compiled terminating with value: " ++ show val

#endif

foreverFrom :: Int -> [Int]
foreverFrom n = n : foreverFrom (n + 1)

main :: IO ()
main = do
    let xs = foreverFrom 0
    evaluate_and_possibly_timeout (take 10 xs)

    