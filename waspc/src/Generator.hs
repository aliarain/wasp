module Generator
       ( writeWebAppCode
       , Generator.Setup.setup
       , Generator.Start.start
       ) where

import qualified Data.Text
import qualified Data.Text.IO
import           Data.Time.Clock
import qualified Data.Version
import qualified Path                      as P
import qualified Paths_waspc

import           CompileOptions            (CompileOptions)
import           Generator.Common          (ProjectRootDir)
import           Generator.DbGenerator     (genDb)
import           Generator.FileDraft       (FileDraft, write)
import           Generator.ServerGenerator (genServer)
import qualified Generator.ServerGenerator as ServerGenerator
import           Generator.DockerGenerator (genDockerFiles)
import qualified Generator.Setup
import qualified Generator.Start
import           Generator.WebAppGenerator (generateWebApp)
import           StrongPath                (Abs, Dir, Path, (</>))
import qualified StrongPath                as SP
import           Wasp                      (Wasp)


-- | Generates web app code from given Wasp and writes it to given destination directory.
--   If dstDir does not exist yet, it will be created.
--   NOTE(martin): What if there is already smth in the dstDir? It is probably best
--     if we clean it up first? But we don't want this to end up with us deleting stuff
--     from user's machine. Maybe we just overwrite and we are good?
writeWebAppCode :: Wasp -> Path Abs (Dir ProjectRootDir) -> CompileOptions -> IO ()
writeWebAppCode wasp dstDir compileOptions = do
    writeFileDrafts dstDir (generateWebApp wasp compileOptions)
    ServerGenerator.preCleanup wasp dstDir compileOptions
    writeFileDrafts dstDir (genServer wasp compileOptions)
    writeFileDrafts dstDir (genDb wasp compileOptions)
    writeFileDrafts dstDir (genDockerFiles wasp compileOptions)
    writeDotWaspInfo dstDir

-- | Writes file drafts while using given destination dir as root dir.
--   TODO(martin): We could/should parallelize this.
--     We could also skip writing files that are already on the disk with same checksum.
writeFileDrafts :: Path Abs (Dir ProjectRootDir) -> [FileDraft] -> IO ()
writeFileDrafts dstDir = mapM_ (write dstDir)

-- | Writes .waspinfo, which contains some basic metadata about how/when wasp generated the code.
writeDotWaspInfo :: Path Abs (Dir ProjectRootDir) -> IO ()
writeDotWaspInfo dstDir = do
    currentTime <- getCurrentTime
    let version = Data.Version.showVersion Paths_waspc.version
    let content = "Generated on " ++ (show currentTime) ++ " by waspc version " ++ (show version) ++ " ."
    let dstPath = dstDir </> SP.fromPathRelFile [P.relfile|.waspinfo|]
    Data.Text.IO.writeFile (SP.toFilePath dstPath) (Data.Text.pack content)
