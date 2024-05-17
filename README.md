# unite-train

A pipeline to build [Qiime2](https://qiime2.org/) taxonomy [classifiers](https://docs.qiime2.org/2021.11/data-resources/) for the [UNITE database](https://unite.ut.ee/repository.php).

## [Download a pre-trained classifier here! 🎁](https://github.com/colinbrislawn/unite-train/releases)

[![Issues](https://img.shields.io/github/issues/colinbrislawn/unite-train?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/issues)
![pre-releases](https://img.shields.io/github/release-date-pre/colinbrislawn/unite-train?display_date=published_at&style=for-the-badge)
[![Downloads](https://img.shields.io/github/downloads/colinbrislawn/unite-train/total.svg?style=for-the-badge)](https://github.com/colinbrislawn/unite-train/releases)

### What is this?

If you are interested in Fungi 🍄🍄‍🟫 you could use their genomic fingerprint to identify them. Affordable PCR amplification and sequencing of the ITS gene gives you these nucleic acid fingerprints, and the UNITE team provides a database to gives these sequences a name.

We can predict the taxonomy of our fungal fingerprints using an old-school machine learning method: a supervised [k-mer](https://en.wikipedia.org/wiki/K-mer) [nb-classifier](https://scikit-learn.org/stable/modules/naive_bayes.html). But first, we need to prepare our database in a process called 'training.'

This is a pipeline that trains the UNITE ITS taxonomy database for use with Qiime2. You can run this pipeline yourself, but you don't have to! I've provided a [ready to use pre-trained classifiers](https://github.com/colinbrislawn/unite-train/releases) so you can simply run [`qiime feature-classifier classify-sklearn`](https://docs.qiime2.org/2024.2/plugins/available/feature-classifier/classify-sklearn/).

If you have questions about using Qiime2, ask on [the Qiime2 forums](https://forum.qiime2.org/).

If you have questions about the UNITE ITS database, [contact the UNITE team](https://unite.ut.ee/contact.php).

If you have questions about this pipeline, please [open a new issue](https://github.com/colinbrislawn/unite-train/issues/new)!

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

Run:

```bash
snakemake --cores 8 --use-conda --resources mem_mb=10000
```

Training one classifier takes 1-9 hours on an [AMD EPYC 75F3 Milan](https://www.amd.com/en/products/cpu/amd-epyc-75f3), depending on the size and complexity of the data.

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
snakemake --jobs 12 \
  --rerun-incomplete --retries 3 \
  --use-singularity \
  --default-resources
```

</details>

Reports:

```bash
snakemake --report results/report.html
snakemake --forceall --dag --dryrun | dot -Tpdf > results/dag.pdf
```
