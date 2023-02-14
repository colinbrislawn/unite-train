# unite-train

A pipeline to build [Qiime2](https://qiime2.org/) taxonomy [classifiers](https://docs.qiime2.org/2021.11/data-resources/) for the [UNITE database](https://unite.ut.ee/repository.php).

### [Download a pre-trained classifier here! 🎁](https://github.com/colinbrislawn/unite-train/releases)

[![Issues](https://img.shields.io/github/issues/colinbrislawn/unite-train?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/issues)
[![release](https://img.shields.io/github/release-date-pre/colinbrislawn/unite-train?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/releases)
[![Downloads](https://img.shields.io/github/downloads/colinbrislawn/unite-train/total.svg?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/releases)

# Running Snakemake workflow

Set up:
 - Install [mamba](https://mamba.readthedocs.io/en/latest/installation.html) and configure [Bioconda](https://bioconda.github.io/). Then install [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) and activate the Snakemake environment.

Run:
```bash
snakemake --cores 8 --use-conda --conda-create-envs-only
# Connect to a worker node, if needed, then
snakemake --cores 8 --use-conda --resources mem_mb=9000
# This takes about 11 hours on my machine
```

Reports:
```bash
snakemake --report results/report.html
snakemake --forceall --dag --dryrun | dot -Tpdf > results/dag.pdf
```
