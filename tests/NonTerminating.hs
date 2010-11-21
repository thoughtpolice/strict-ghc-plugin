{-# LANGUAGE CPP #-}
module Main ( main ) where
import Strict.Annotation

{-# ANN foreverFrom Strictify #-}
foreverFrom :: Int -> [Int]
foreverFrom n = n : foreverFrom (n + 1)

main :: IO ()
main = do
  let xs = foreverFrom 0
  print (take 10 xs)
