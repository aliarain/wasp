module Cli.Common
    ( WaspProjectDir
    , DotWaspDir
    , CliTemplatesDir
    , dotWaspDirInWaspProjectDir
    , dotWaspRootFileInWaspProjectDir
    , extCodeDirInWaspProjectDir
    , generatedCodeDirInDotWaspDir
    , buildDirInDotWaspDir
    , waspSays
    ) where

import qualified Path             as P

import           Common           (WaspProjectDir)
import           ExternalCode     (SourceExternalCodeDir)
import qualified Generator.Common
import           StrongPath       (Dir, File, Path, Rel)
import qualified StrongPath       as SP
import qualified Util.Terminal    as Term


data DotWaspDir -- Here we put everything that wasp generates.
data CliTemplatesDir


-- TODO: SHould this be renamed to include word "root"?
dotWaspDirInWaspProjectDir :: Path (Rel WaspProjectDir) (Dir DotWaspDir)
dotWaspDirInWaspProjectDir = SP.fromPathRelDir [P.reldir|.wasp|]

-- TODO: Hm this has different name than it has in Generator.
generatedCodeDirInDotWaspDir :: Path (Rel DotWaspDir) (Dir Generator.Common.ProjectRootDir)
generatedCodeDirInDotWaspDir = SP.fromPathRelDir [P.reldir|out|]

buildDirInDotWaspDir :: Path (Rel DotWaspDir) (Dir Generator.Common.ProjectRootDir)
buildDirInDotWaspDir = SP.fromPathRelDir [P.reldir|build|]

dotWaspRootFileInWaspProjectDir :: Path (Rel WaspProjectDir) File
dotWaspRootFileInWaspProjectDir = SP.fromPathRelFile [P.relfile|.wasproot|]

extCodeDirInWaspProjectDir :: Path (Rel WaspProjectDir) (Dir SourceExternalCodeDir)
extCodeDirInWaspProjectDir = SP.fromPathRelDir [P.reldir|ext|]

waspSays :: String -> IO ()
waspSays what = putStrLn $ Term.applyStyles [Term.Yellow] what
