\begin{code}
{-# LANGUAGE PatternGuards #-}

module Strict.Pass (strictifyProgram) where

import GhcPlugins

import Control.Monad
import Data.Generics

import Strict.Annotation

\end{code}
Strictification of a program based on annotations.
\begin{code}

strictifyProgram :: ModGuts -> CoreM ModGuts
strictifyProgram guts = do
  newBinds <- mapM (strictifyFunc guts) (mg_binds guts)
  return $ guts { mg_binds = newBinds }

strictifyFunc :: ModGuts -> CoreBind -> CoreM CoreBind
strictifyFunc guts x@(NonRec b _) = do 
  b' <- shouldStrictify guts b
  case b' of
    True -> everywhereM (mkM strictifyExpr) x
    False -> return x
strictifyFunc guts x@(Rec bes) = do
  b <- (not . null) `liftM` (filterM (shouldStrictify guts . fst) bes)
  if b then everywhereM (mkM strictifyExpr) x
    else return x

strictifyExpr :: CoreExpr -> CoreM CoreExpr
strictifyExpr e@(Let (NonRec b e1) e2) 
  | Type _ <- e1 = return e -- Yes, this can occur!
  | otherwise    = return $ Case e1 b (exprType e2) [(DEFAULT, [], e2)]
strictifyExpr e@(App e1 e2)
  = case e2 of
          App _ _ -> translate
          Case _ _ _ _ -> translate
          Cast _ _ -> translate -- May as well, these two don't
          Tick _ _ -> translate -- appear on types anyway
          _ -> return e -- N.b. don't need to consider lets since they will have been eliminated already
  where
    translate = do
            b <- mkSysLocalM (fsLit "strict") (exprType e2)
            return $ Case e2 b (exprType e) [(DEFAULT, [], App e1 (Var b))]
strictifyExpr e = return e

\end{code}
Utilities and other miscellanious stuff
\begin{code}

shouldStrictify :: ModGuts -> CoreBndr -> CoreM Bool
shouldStrictify guts bndr = do
  l <- annotationsOn guts bndr :: CoreM [Strictify]
  return $ not $ null l

annotationsOn :: Data a => ModGuts -> CoreBndr -> CoreM [a]
annotationsOn guts bndr = do
  anns <- getAnnotations deserializeWithData guts
  return $ lookupWithDefaultUFM anns [] (varUnique bndr)

\end{code}
