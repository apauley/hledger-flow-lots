-- From a built hledger PR checkout, run
-- stack exec -- runghc /path/to/CompareIndexes.hs /path/to/all-years.journal
import Control.Monad.Trans.Except (runExceptT)
import Hledger
import System.Environment (getArgs)
import System.Exit (die)

main :: IO ()
main = do
    [path] <- getArgs
    journal <- either die pure =<< runExceptT (readJournalFile definputopts{ignore_lots_ = True} path)
    let classified = journalClassifyLotPostings False journal
        report label transactions = do
            result <- either die pure (journalCalculateLots False classified{jtxns = transactions})
            putStrLn label
            mapM_ (print . (\t -> (tindex t, tdescription t))) (jtxns result)
    report "Reader indexes" (jtxns classified)
    report "All indexes zero" [t{tindex = 0} | t <- jtxns classified]
