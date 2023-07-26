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

## Create a new tag and release:

```bash
newtag="9.0-qiime2-2023.5-demo"

gh release create ${newtag} \
  --draft \
  --latest \
  -F release_notes_newest.md \
  --prerelease  \
  --title "Demo! UNITE v9.0 for qiime2-2023.5"
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

