# Release to GitHub

After running this pipeline, we have database files we need to store somewhere accessible.

Somewhere like [a GitHub release](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).
(See [this post](https://stackoverflow.com/questions/64936180/how-to-release-on-github-through-the-command-line-and-to-attach-a-large-file) for an overview of the process.)

Software Setup:

```bash
conda update conda
conda install gh --channel conda-forge
gh auth login
```


## Search for old IDs in the files

Using ripgrep to search for the strings. Only these two should be found

```bash
# old unite date. Should only find this line
rg "04.04.2024" -g '!benchmarks/'

# old qiime2 date. Should only find this line
rg "2026.1" -g '!benchmarks/' -g '!workflow/envs'
```

## Create a new tag and release:

```bash
newtag="v10.0-2025-02-19-qiime2-2026.1"

gh release create ${newtag} \
  --draft \
  --latest \
  -F release_notes_newest.md \
  --prerelease  \
  --title "UNITE v10.0 2025-02-19 for qiime2-2026.1"
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
gh release upload ${newtag} results/unite_*2026.1.qza

gh release upload ${newtag} results/example.qza
```

## Review draft on GitHub and publish it!

Open [unite-train releases](https://github.com/colinbrislawn/unite-train/releases)

(Drafts won’t be seen by the public unless they are published.)

