#!/bin/bash

## Based on this Gist: https://gist.github.com/telatin/f626d22108bc75f3515b84bc9fe0bc45

# Download
## Version, date, taxon, refS, repS, status, DOI
## Other wildcards: URI folder path / prefix, filename
# 8.3	2021-05-10	Fungi	14 097	44 343	Current	https://doi.org/10.15156/BIO/1264708
wget -P step1_download https://files.plutof.ut.ee/public/orig/C5/54/C5547B97AAA979E45F79DC4C8C4B12113389343D7588716B5AD330F8BDB300C9.tgz
# 8.3	2021-05-10	Fungi	14 097	83 993	Current	https://doi.org/10.15156/BIO/1264763
#wget -P step1_download https://files.plutof.ut.ee/public/orig/B3/05/B3054DF783AC61A0C3BD0FDEB0516EC394934809AAE43CA0F3081C0A184FAA39.tgz
# 8.3	2021-05-10	All eukaryotes	14 237	96 423	Current	https://doi.org/10.15156/BIO/1264819
#wget -P step1_download https://files.plutof.ut.ee/public/orig/48/29/4829D91F763E20F0F4376A60AA53FC9FBE6029A7D1BDC1B45347DD64EDE5D560.tgz
# 8.3	2021-05-10	All eukaryotes	14 237	190 888	Current	https://doi.org/10.15156/BIO/1264861
#wget -P step1_download https://files.plutof.ut.ee/public/orig/1D/31/1D31FA3A308BDC2FB2750D62C0AA40C5058C15405A3CC5C626CC3A3F5E3903ED.tgz


#Decompress. The downloaded file is actually a tar.gz file and so needs to be decompressed with:
# These each go into seperate folders, so we should track that
## Wildcards: filename, output folder
tar xzf step1_download/C5547B97AAA979E45F79DC4C8C4B12113389343D7588716B5AD330F8BDB300C9.tgz -C step2_extract
#tar xzf step1_download/B3054DF783AC61A0C3BD0FDEB0516EC394934809AAE43CA0F3081C0A184FAA39.tgz -C step2_extract
#tar xzf step1_download/4829D91F763E20F0F4376A60AA53FC9FBE6029A7D1BDC1B45347DD64EDE5D560.tgz -C step2_extract
#tar xzf step1_download/1D31FA3A308BDC2FB2750D62C0AA40C5058C15405A3CC5C626CC3A3F5E3903ED.tgz -C step2_extract


#Move into the developer directory for one project
## Wildcards: output folder
cd step2_extract/sh_qiime_release_10.05.2021/developer/

#Fix formatting errors that prevent importation of the reference sequences into QIIME2. 
#There are white spaces that interfere, and possibly some lower case letters that need to be converted to upper case.
# Related blog post: https://john-quensen.com/tutorials/training-the-qiime2-classifier-with-unite-its-reference-sequences/
## Wildcards: output folder, percent ID, date
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' step2_extract/sh_qiime_release_10.05.2021/developer/sh_refs_qiime_ver8_99_10.05.2021_dev.fasta | \
	 tr -d ' ' > step3_format/sh_refs_qiime_ver8_99_10.05.2021_dev.fasta

# Explicitely activate a Qiime2 conda environment
conda activate qiime2-2021.11

# Import the UNITE reference sequences into QIIME2.
qiime tools import \
	--type FeatureData[Sequence] \
	--input-path  step3_format/sh_refs_qiime_ver8_99_10.05.2021_dev.fasta \
	--output-path step4_import/sh_refs_qiime_ver8_99_10.05.2021_dev.qza

# Import the taxonomy file.
qiime tools import \
	--type FeatureData[Taxonomy] \
	--input-path  step2_extract/sh_qiime_release_10.05.2021/developer/sh_taxonomy_qiime_ver8_99_10.05.2021_dev.txt \
	--output-path step4_import/sh_taxonomy_qiime_ver8_99_10.05.2021_dev.qza \
	--input-format HeaderlessTSVTaxonomyFormat

# Train the classifier.
time qiime feature-classifier fit-classifier-naive-bayes \
	--i-reference-reads    step4_import/sh_refs_qiime_ver8_99_10.05.2021_dev.qza \
	--i-reference-taxonomy step4_import/sh_taxonomy_qiime_ver8_99_10.05.2021_dev.qza \
	--o-classifier         step5_export/unite_ver8_99_10.05.2021_dev.qza

#See Processing ITS Sequences with QIIME2 and DADA2 for how to use the classifier file.

