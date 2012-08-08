module Strict.Plugin
       ( plugin -- :: Plugin
       ) where

import Strict.Pass (strictifyProgram)
import GhcPlugins

plugin :: Plugin
plugin = defaultPlugin {
  installCoreToDos = install
  }

install :: [CommandLineOption] -> [CoreToDo] -> CoreM [CoreToDo]
install _ todos = do
    reinitializeGlobals
    return $ CoreDoPluginPass "Strictify" strictifyProgram : todos