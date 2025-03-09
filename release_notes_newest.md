⚠️ This is a public demo, and has not been validated. I am not affiliated with the UNITE team.

This is a classifier for [Unite v10.0](https://unite.ut.ee/repository.php) Version 19.02.2025 trained for use with [Qiime2 2024.10](https://docs.qiime2.org/2024.10/install/).

These can be used [`qiime feature-classifier classify-sklearn`](https://docs.qiime2.org/2024.10/plugins/available/feature-classifier/classify-sklearn/) like the ones from [resources.qiime2.org](https://resources.qiime2.org/).

UNITE is licensed under CC BY-SA 4.0. If you use it, cite it! 🤝

>Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2025): UNITE QIIME release for Fungi. Version 19.02.2025. UNITE Community **\<DOI GOES HERE>**
>
> DOIs for specific releases are listed here: https://unite.ut.ee/repository.php

---

Changes:

  - Update to Unite ver10 2025-02-19
  - Update to qiime-2024.10 (finally!)
  - Change git release tag to be more similar to the Unite website (file names are the same)

---

There are three levels of classification provided here:

- "97", in which the database is clustered at 97% identity ([not recommended!](https://forum.qiime2.org/t/feature-classifier-classify-sklearn-all-rep-seqs-unassigned/5960/22))
- "99", in which the database is clustered at 99% identity
- "dynamic", which uses 97% to 99% identity as individually recommended by experts

There are two taxa scopes:

- "" Just Fungi
- "all" All eukaryotes

There two versions, with and without an "s":

- "" Includes singletons set as RefS (in dynamic files)
- "s" Includes global and 97% singletons.
  (I'm not sure what that means, but if you do please [let me know!](https://github.com/colinbrislawn/unite-train/issues/new?title=I%20know%20what%20the%20S%20means%21))

---

All feedback is welcome! Please [open an issue! ✅](https://github.com/colinbrislawn/unite-train/issues)
