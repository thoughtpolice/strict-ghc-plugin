module Strict.Plugin (plugin) where

import Strict.Pass

import GHCPlugins

plugin :: Plugin
plugin = defaultPlugin {
    installCoreToDos = install
  }

install :: [CommandLineOption] -> [CoreToDo] -> CoreM [CoreToDo]
install _option todos = do
    return $ CoreDoPluginPass "Strictify" (ModGutsToBindsPluginPass strictifyProgram) : todos