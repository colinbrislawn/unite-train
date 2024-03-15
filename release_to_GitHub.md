# Release to GitHub

After running this pipeline, we have database files we need to store somewhere accessible.

Somewhere like [a GitHub release](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).
(See [this post](https://stackoverflow.com/questions/64936180/how-to-release-on-github-through-the-command-line-and-to-attach-a-large-file) for an overview of the process.)

Software Setup:

```bash
mamba update mamba
mamba install gh --channel conda-forge
gh auth login
```

## But first, spot-check one classifier

```bash
mkdir -p /tmp/qiime2tmp
export TMPDIR="/tmp/qiime2tmp/"
module load qiime2

time qiime feature-classifier classify-sklearn \
  --i-classifier results/unite_ver9_dynamic_25.07.2023-Q2-2024.2.qza \
  --i-reads benchmarks/dada2-single-end-rep-seqs.qza \
  --p-n-jobs 4 \
  --o-classification results/test-tax.qza

qiime taxa barplot \
  --i-table benchmarks/dada2-single-end-table.qza \
  --i-taxonomy results/test-tax.qza \
  --m-metadata-file benchmarks/mock-25-sample-metadata.tsv \
  --o-visualization results/test-tax.qzv

# Cleanup
rm -rf test-tax*
```

## Create a new tag and release:

```bash
newtag="v9.0-v25.07.2023-qiime2-2024.2"

gh release create ${newtag} \
  --draft \
  --latest \
  -F release_notes_newest.md \
  --prerelease  \
  --title "UNITE v9.0 v25.07.2023 for qiime2-2024.2"
```

## Push files to this new release:

```bash
gh release upload ${newtag} --clobber results/dag.pdf
gh release upload ${newtag} --clobber results/report.html
```

## Example output files to push:

TODO: Investigate and fill this list with real files

When using a wildcard like `results/*.qza`, if any of the files already exist, then the full command will fail.

```bash
gh release upload ${newtag} results/*.qza

gh release upload ${newtag} results/example.qza
```

## Review draft on GitHub and publish it!

Open [unite-train releases](https://github.com/colinbrislawn/unite-train/releases)

(Drafts won’t be seen by the public unless they are published.)

