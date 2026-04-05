This is a classifier for [Unite v10.0](https://unite.ut.ee/repository.php) Version 19.02.2025 trained for use with **qiime2-amplicon-2026.4** -- [install](https://library.qiime2.org/quickstart/amplicon) [docs](https://amplicon-docs.qiime2.org/en/latest/).

These can be used with [`qiime feature-classifier classify-sklearn`](https://amplicon-docs.qiime2.org/en/stable/references/plugins/feature-classifier.html#q2-action-feature-classifier-classify-sklearn) like the ones on the [Taxonomic classifiers page](https://library.qiime2.org/data-resources/).

UNITE is licensed under CC BY-SA 4.0. If you use it, cite it! 🤝

>Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2025): UNITE QIIME release for Fungi. Version 19.02.2025. UNITE Community **\<DOI GOES HERE>**
>
> DOIs for specific releases are listed here: https://unite.ut.ee/repository.php

Please review the database evaluation inside `eval_unite_*.qzv` file and the software [License](https://github.com/colinbrislawn/unite-train?tab=BSD-3-Clause-1-ov-file).

---

Changes:

  - Update to `qiime2-amplicon-2026.4`
  - Update to `scikit-learn=1.7.1` ⚠ This is new! Update now!
  - include F-score results in `eval_unite_ver2025-02-19.qzv`

---

There are three levels of classification provided here:

- "97", in which the database is clustered at 97% identity ([see](https://forum.qiime2.org/t/feature-classifier-classify-sklearn-all-rep-seqs-unassigned/5960/22))
- "99", in which the database is clustered at 99% identity
- "dynamic", which uses 97% to 99% identity as individually recommended by experts

There are two taxa scopes:

- Only **fungi** or
- All **eukaryotes**

I no longer build and distribute the "s" versions of the classifier, as they are uniformly worse, see [#17](https://github.com/colinbrislawn/unite-train/issues/17#issuecomment-3836231283). You can change the `singletons` parameter in the `nextflow.config` file, if you want them.

---

All feedback is welcome! Please [open an issue! ✅](https://github.com/colinbrislawn/unite-train/issues)
