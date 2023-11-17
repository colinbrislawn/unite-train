# unite-train

A pipeline to build [Qiime2](https://qiime2.org/) taxonomy [classifiers](https://docs.qiime2.org/2021.11/data-resources/) for the [UNITE database](https://unite.ut.ee/repository.php).

## [Download a pre-trained classifier here! 🎁](https://github.com/colinbrislawn/unite-train/releases)

[![Issues](https://img.shields.io/github/issues/colinbrislawn/unite-train?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/issues)
[![release](https://img.shields.io/github/release-date-pre/colinbrislawn/unite-train?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/releases)
[![Downloads](https://img.shields.io/github/downloads/colinbrislawn/unite-train/total.svg?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/releases)

---

## Running Snakemake workflow

Set up:

- Install [Mambaforge](https://github.com/conda-forge/miniforge#mambaforge) and configure [Bioconda](https://bioconda.github.io/).
- Install the version of [Qiime2](https://docs.qiime2.org/) you want using the recomended environment name.
  (For a faster install, you can replace `conda` with `mamba`.)
- Install [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) into an environment, then activate that environment.

Configure:

- Open up `config/config.yaml` and configure it to your liking.
  (For example, you may need to update the name of your Qiime2 environment.)

Run the full pipeline, as configured:

```bash
snakemake --cores 8 --use-conda --resources mem_mb=10000
```

Dry run (solves and prints and DAG, without running it):

```bash
snakemake --rerun-incomplete -n
```

This takes about 15 hours on my machine

<details>
  <summary>Run on a slurm cluster:</summary>

More specifically, The University of Florida HiPerGator supercomputer,
with access generously provided by the [Kawahara Lab](https://www.floridamuseum.ufl.edu/kawahara-lab/)!

```bash
screen    # We connect to a random login node, so we may not be able...
screen -r # to reconnect with this later on.

snakemake --jobs 24 --slurm \
  --rerun-incomplete --retries 3 \
  --use-envmodules --latency-wait 10 \
  --default-resources slurm_account=kawahara slurm_partition=hpg-milan
```

</details>

<details>
  <summary>Run with Docker:</summary>

Say, in 'the cloud' using [FlowDeploy](https://flowdeploy.com/).

```bash
# Snakemake folder name for run:
# unite-train # default

# Snakefile location
# workflow/Snakefile # default

# Command-line arguments:
--rerun-incomplete --retries 1 --use-singularity
# Note that the `snakemake` command and `--jobs` are not needed on FlowDeploy
# And maybe `--default-resources` is also not needed?
```

</details>

Reports:

```bash
snakemake --report results/report.html
snakemake --forceall --dag --dryrun | dot -Tpdf > results/dag.pdf
```
