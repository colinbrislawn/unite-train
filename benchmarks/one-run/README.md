This now contains log files from TWO runs

```sh
# check if jobs are done
squeue -u cbrislawn

cd /home/cbrislawn/gitrepos/unite-train

# old db, old qiime2
ll logs/train_ver9_*_25.07.2023-Q2-2023.5.tsv
cp logs/train_ver9_*_25.07.2023-Q2-2023.5.tsv benchmarks/one-run/

# new db, old qiime2
ll logs/train_ver10_*_04.04.2024-Q2-2023.5.tsv
cp logs/train_ver10_*_04.04.2024-Q2-2023.5.tsv benchmarks/one-run/

# new db, new qiime2
ll logs/train_ver10_*_04.04.2024-Q2-2024.5.tsv
cp logs/train_ver10_*_04.04.2024-Q2-2024.5.tsv benchmarks/one-run/

```
