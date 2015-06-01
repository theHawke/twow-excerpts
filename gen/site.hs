{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Data.Monoid ((<>))

main :: IO ()
main = hakyllWith (defaultConfiguration { destinationDirectory = "../"}) $ do
  match "css/*.css" $ do
    route   idRoute
    compile compressCssCompiler

  match "chapters/*.md" $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  match "index.md" $ do
    route   $ setExtension "html"
    compile $ do
      chapters <- {-chronological =<<-} (loadAll "chapters/*" :: Compiler [Item String])
      let indexCtx =
            listField "chapters" defaultContext (return chapters) <>
            constField "title" "Index"                           <>
            defaultContext
      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= renderPandoc
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls
  
  match "templates/*" $ compile templateCompiler

 
