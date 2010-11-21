{-# LANGUAGE DeriveDataTypeable #-}
module Strict.Annotation where
import Data.Data

-- | Programs which want to 'strictify' their functions should annotate them with the following
-- datatype
-- TODO: move this into a separate package perhaps?
data Strictify = Strictify deriving (Typeable, Data)