{-# LANGUAGE CPP #-}
module Main ( main ) where
import Strict.Annotation

import Control.Exception ( evaluate )

evaluate_and_possibly_timeout what = do
    val <- evaluate what
    putStrLn $ "Test failed due to the thing compiled terminating with value: " ++ show val

{-# ANN foreverFrom Strictify #-}
foreverFrom :: Int -> [Int]
foreverFrom n = n : foreverFrom (n + 1)

main :: IO ()
main = do
    let xs = foreverFrom 0
    evaluate_and_possibly_timeout (take 10 xs)
