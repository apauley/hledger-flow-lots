# Working in this ledger

Run commands from the ledger root (the folder containing `import/`). Start with
`hledger-flow status` to see the accounts, pending work and suggested next step.
Use `hledger-flow status --json` when reading status programmatically.

## Where to make changes

- Keep original statements in `import/<owner>/<bank>/<account>/1-in/<year>/`.
  Use the transaction year and avoid overlapping exports, which duplicate entries.
- Prefer plain hledger CSV rules for mapping fields and classifying transactions.
  They are easier to maintain and can make repeated imports much faster because
  hledger-flow can reuse unchanged journals without running a script per statement.
  Check for shared bank rules and account-specific rules before adding new ones.
  For a new account, `hledger-flow rules OWNER/BANK/ACCOUNT` creates starter rules.
- Add a script hook in the account directory only when rules alone cannot do the job.
  Use `preprocess` to turn input such as malformed rows into CSV the rules can read.
  Use `construct` to write journal entries to stdout when rules cannot express the postings.
  Run `hledger-flow import --verbose` to see which rules and hooks a statement uses.
- Record entries missing from statements in `_manual_/<year>/pre-import.journal`
  or `post-import.journal` at the relevant account, bank, owner or import level.
  Use the account's `<year>-opening.journal` for its opening balance.
- Put ledger-wide declarations in `directives.journal` and market prices under
  `prices/<year>/`. Follow the account names and commodities already in use.

## Rebuild and verify

1. For faster repeat imports with hledger 1.52.4 or later, run `hledger-flow import --incremental`.
   The first run records conversion inputs. Later runs can reuse unchanged rules-based
   journals. This mode still runs script hooks on every selected statement.
   Use `hledger-flow import` for a full rebuild. Both commands maintain the include files.
   Changes made directly in `2-preprocessed/`, `3-journal/` or generated indexes can be lost.
2. Run `hledger -f all-years.journal check` to validate the assembled journal.
   Use `hledger -f all-years.journal register assets:Wallet:WalletA` to inspect
   postings (substitute the actual account), and `hledger -f all-years.journal balance`
   to compare balances with the statements.
3. Run `hledger-flow report` to refresh `reports/`, then check `hledger-flow status`
   for unknown transactions or transfers to review. Correct their source rules or
   manual entries and rerun the workflow.

## References

- [hledger-flow documentation](https://hledger-flow.github.io/go/docs/) for ledger layout and the import and report workflow.
- [hledger-flow rules files](https://hledger-flow.github.io/go/rules-files/) for rules lookup, sharing and statement-specific overrides.
- [hledger manual](https://hledger.org/hledger.html) for CSV rule syntax, journal entries and queries.
