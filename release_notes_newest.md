⚠️ This is a public demo, and has not been validated. I am not affiliated with the UNITE team. Use at your own risk!

This is a classifier for version 9.0 of the [UNITE database](https://unite.ut.ee/repository.php)
trained for use with [Qiime2 2023.5](https://docs.qiime2.org/2023.5/install/).
These can be used with `q2-feature-classifier` like those found on
the [Data resources page](https://docs.qiime2.org/2023.5/data-resources/).

UNITE is licensed under CC BY-SA 4.0. If you use it, cite it! 🤝

>Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2022): UNITE QIIME release for Fungi. Version 16.10.2022. UNITE Community **\<DOI GOES HERE>**
>
> DOIs for specific releases are listed here: https://unite.ut.ee/repository.php

---

Changes:

- Update Qiime2 to 2023.5

---

There are two levels of classification provided here:

- "99", which is 99% identity between taxa
- "dynamic", which uses 97% to 99% identity between taxa, as individually recommended by experts in the field.

There are two taxa scopes:

- "" Just Fungi
- "all" All eukaryotes

There two versions, with and without an "s":

- "" Includes singletons set as RefS (in dynamic files).
- "s" Includes global and 97% singletons.
  (I'm not sure what that means.)

---

Notes on dates:

On the main [UNITE download page](https://unite.ut.ee/repository.php),
Version number 9.0 has a Release date of 2022-10-16.

However, that DOI leads to three, progressively newer files
([webpage](https://doi.plutof.ut.ee/doi/10.15156/BIO/2483915),
[api](https://api.plutof.ut.ee/v1/public/dois/?format=api&identifier=10.15156/BIO/2483915))

- sh_qiime_release_16.10.2022.tgz
- sh_qiime_release_27.10.2022.tgz
- sh_qiime_release_29.11.2022.tgz

I've used the newest file (29.11.2022), which is why the file dates are newer than the release date.

---

All feedback is welcome! Please [open an issue! ✅](https://github.com/colinbrislawn/unite-train/issues)
