# unite-train

A pipeline to `fit-classifier-naive-bayes` to the [UNITE database](https://unite.ut.ee/repository.php).

There's a `.sh` script and a work-in-progress Snakemake workflow.

# Snakemake workflow

Set up:
 - Set up your [Qiime2 conda environment](https://docs.qiime2.org/2021.11/install/)
 - Install [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) **inside** your Qiime2 conda environment
 - Install any Unix software needed (wget, tar, awk, tr)

```bash
conda activate qiime2-2021.11

snakemake --cores 8

snakemake --report results/report.html
```

Reports:
```bash
snakemake --report results/report.html

snakemake --forceall --dag --dryrun | dot -Tpdf > results/dag.pdf
```
