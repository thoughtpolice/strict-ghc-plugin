\begin{code}
{-# LANGUAGE PatternGuards #-}

module Strict.Pass (strictifyProgram) where

import GHCPlugins

import Data.Generics
import Data.Maybe

\end{code}
\begin{code}

strictifyProgram :: [CoreBind] -> CoreM [CoreBind]
strictifyProgram binds = everywhereM (mkM strictifyExpr) binds

strictifyExpr :: CoreExpr -> CoreM CoreExpr
strictifyExpr e@(Let (NonRec b e1) e2) 
  | Type _ <- e1 = return e -- Yes, this can occur!
  | otherwise    = return $ Case e1 b (exprType e2) [(DEFAULT, [], e2)]
strictifyExpr e@(App e1 e2)
  = case e2 of
          App _ _ -> translate
          Case _ _ _ _ -> translate
          Cast _ _ -> translate -- May as well, these two don't
          Note _ _ -> translate -- appear on types anyway
          _ -> return e -- N.b. don't need to consider lets since they will have been eliminated already
  where
    translate = do
            b <- mkSysLocalM (fsLit "strict") (exprType e2)
            return $ Case e2 b (exprType e) [(DEFAULT, [], App e1 (Var b))]
strictifyExpr e = return e

\end{code}