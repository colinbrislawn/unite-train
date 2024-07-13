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
module load qiime2
# This makes a ./tmp/ folder in the working directory

rm -rf results/test/
mkdir -p results/test/

testfile="unite_ver10_dynamic_04.04.2024-Q2-2024.5"
qiime tools peek results/${testfile}.qza

qiime feature-classifier classify-sklearn \
  --i-reads benchmarks/dada2-single-end-rep-seqs.qza \
  --p-n-jobs 4 \
  --i-classifier     results/${testfile}.qza \
  --o-classification results/test/${testfile}.qza
qiime taxa barplot \
  --i-table        benchmarks/dada2-single-end-table.qza \
  --m-metadata-file benchmarks/mock-25-sample-metadata.tsv \
  --i-taxonomy      results/test/${testfile}.qza \
  --o-visualization results/test/${testfile}.qzv
rm -f results/test/${testfile}.qza # Keep viz only

# Cleanup
rm -rf results/test/
rm -rf tmp/
```

## Create a new tag and release:

```bash
newtag="v10.0-v04.04.2024-qiime2-2024.5"

gh release create ${newtag} \
  --draft \
  --latest \
  -F release_notes_newest.md \
  --prerelease  \
  --title "UNITE v10.0 v04.04.2024 for qiime2-2024.5"
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

