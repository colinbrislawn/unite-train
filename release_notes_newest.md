⚠️ This is a public demo, and has not been validated. I am not affiliated with the UNITE team.

This is a classifier for [Unite v10.0](https://unite.ut.ee/repository.php) Version 19.02.2025 trained for use with **qiime2-amplicon-2026.1** -- [install](https://library.qiime2.org/quickstart/amplicon) [docs](https://amplicon-docs.qiime2.org/en/latest/).

These can be used with [`qiime feature-classifier classify-sklearn`](https://amplicon-docs.qiime2.org/en/latest/references/plugins/feature-classifier.html#q2-action-feature-classifier-classify-sklearn) like the ones on the [Taxonomic classifiers page](https://library.qiime2.org/data-resources/).

UNITE is licensed under CC BY-SA 4.0. If you use it, cite it! 🤝

>Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2025): UNITE QIIME release for Fungi. Version 19.02.2025. UNITE Community **\<DOI GOES HERE>**
>
> DOIs for specific releases are listed here: https://unite.ut.ee/repository.php

---

Changes:

  - Rewrite the pipeline in Nextflow
  - use RESCRIPt plugin to get data
  - Remove sup-species IDs from database; no more `';sh__.*'`
  - Add reclassify as an easy check, and collate with `rescript evaluate-classifications`
  - benchmark (see [#17](https://github.com/colinbrislawn/unite-train/issues/17)) singletons, derep mode, and Eukaryotes
  - Update to qiime-2026.1 (same SKL library, so this is still compatible)
  - New file names, again:
  -

```text
         vvvvvvvvvv publication date
                    vv clustering ID
                      _s_ for including singletons
unite_ver2025-02-19_97_eukaryotes-Q2-2026.1.qza
unite_ver2025-02-19_97_fungi-Q2-2026.1.qza
unite_ver2025-02-19_97_s_fungi-Q2-2026.1.qza
unite_ver2025-02-19_99_eukaryotes-Q2-2026.1.qza
unite_ver2025-02-19_99_fungi-Q2-2026.1.qza
unite_ver2025-02-19_99_s_fungi-Q2-2026.1.qza
unite_ver2025-02-19_dynamic_eukaryotes-Q2-2026.1.qza
unite_ver2025-02-19_dynamic_fungi-Q2-2026.1.qza
unite_ver2025-02-19_dynamic_s_fungi-Q2-2026.1.qza

```

---

There are three levels of classification provided here:

- "97", in which the database is clustered at 97% identity ([not recommended!](https://forum.qiime2.org/t/feature-classifier-classify-sklearn-all-rep-seqs-unassigned/5960/22))
- "99", in which the database is clustered at 99% identity
- "dynamic", which uses 97% to 99% identity as individually recommended by experts

There are two taxa scopes:

- Only **fungi** or
- All **eukaryotes**

There two versions, with and without an "s":

- "" Includes singletons set as RefS (in dynamic files)
- "s" Includes global and 97% singletons.
  (I'm not sure what that means, but if you do please [let me know!](https://github.com/colinbrislawn/unite-train/issues/new?title=I%20know%20what%20the%20S%20means%21))
  (These are uniformly worse by a few percent, see [#17](https://github.com/colinbrislawn/unite-train/issues/17#issuecomment-3836231283))

---

All feedback is welcome! Please [open an issue! ✅](https://github.com/colinbrislawn/unite-train/issues)
