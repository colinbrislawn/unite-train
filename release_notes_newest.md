⚠️ This is a public demo, and has not been validated. I am not affiliated with the UNITE team.

This is a classifier for [Unite v9.0](https://unite.ut.ee/repository.php) Version 18.07.2023 trained for use with [Qiime2 2023.9](https://docs.qiime2.org/2023.9/install/).
These can be used with `q2-feature-classifier` like those found on the [Data resources page](https://docs.qiime2.org/2023.9/data-resources/).

UNITE is licensed under CC BY-SA 4.0. If you use it, cite it! 🤝

>Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2023): UNITE QIIME release for Fungi. Version 18.07.2023. UNITE Community **\<DOI GOES HERE>**
>
> DOIs for specific releases are listed here: https://unite.ut.ee/repository.php

---

Changes:

- Update Qiime2 to version 2023.9
- This should work with all three distributions: amplicon, shotgun, and tidy. If not, please [open an issue! ✅](https://github.com/colinbrislawn/unite-train/issues)

---

There are two levels of classification provided here:

- "99", in which the database is clustered at 99% identity between taxa
- "dynamic", which uses 97% to 99% identity between taxa, as individually recommended by experts in the field

There are two taxa scopes:

- "" Just Fungi
- "all" All eukaryotes

There two versions, with and without an "s":

- "" Includes singletons set as RefS (in dynamic files)
- "s" Includes global and 97% singletons.
  (I'm not sure what that means)

---

Notes on dates:

On the main [UNITE download page](https://unite.ut.ee/repository.php), Version number 9.0 has a Release date of 2023-07-18.

However, the notes and file name say 'Version 18.07.2023' which is when it was updated ([webpage](https://doi.plutof.ut.ee/doi/10.15156/BIO/2938079), [api](https://api.plutof.ut.ee/v1/public/dois/?format=api&identifier=10.15156/BIO/2938079))

I'm using the newer file.

---

All feedback is welcome! Please [open an issue! ✅](https://github.com/colinbrislawn/unite-train/issues)
