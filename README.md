# unite-train

A pipeline to `fit-classifier-naive-bayes` to the [UNITE database](https://unite.ut.ee/repository.php).

There's a `.sh` script and a work-in-progress Snakemake workflow.

# Snakemake workflow

Set up:
 - Install [mamba](https://mamba.readthedocs.io/en/latest/installation.html), [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html), and activate snakemake environment

Run:
```bash
conda activate snakemake
snakemake --cores 8 --use-conda --conda-create-envs-only
 # Connect to a worker node, if needed
snakemake --cores 8 --use-conda --resources mem_mb=9000
```

Reports:
```bash
snakemake --report results/report.html

snakemake --forceall --dag --dryrun | dot -Tpdf > results/dag.pdf
```
