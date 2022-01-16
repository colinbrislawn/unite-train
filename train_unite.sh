## From this Gist: https://gist.github.com/telatin/f626d22108bc75f3515b84bc9fe0bc45

#!/bin/bash
#wget https://files.plutof.ut.ee/public/orig/98/AE/98AE96C6593FC9C52D1C46B96C2D9064291F4DBA625EF189FEC1CCAFCF4A1691.gz

#Decompress. The downloaded file is actually a tar.gz file and so needs to be decompressed with:
tar xzf 98AE96C6593FC9C52D1C46B96C2D9064291F4DBA625EF189FEC1CCAFCF4A1691.gz

#Move into the developer directory.
cd sh_qiime_release_04.02.2020/developer/

#Fix formatting errors that prevent importation of the reference sequences into QIIME2. 
#There are white spaces that interfere, and possibly some lower case letters that need to be converted to upper case.
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' sh_refs_qiime_ver8_99_04.02.2020_dev.fasta | \
	 tr -d ' ' > sh_refs_qiime_ver8_99_04.02.2020_dev_uppercase.fasta

# Import the UNITE reference sequences into QIIME2.
qiime tools import \
	--type FeatureData[Sequence] \
	--input-path sh_refs_qiime_ver8_99_04.02.2020_dev_uppercase.fasta \
	--output-path unite-ver8-seqs_99_04.02.2020.qza

# Import the taxonomy file.
qiime tools import \
	--type FeatureData[Taxonomy] \
	--input-path sh_taxonomy_qiime_ver8_99_04.02.2020_dev.txt \
	--output-path unite-ver8-taxonomy_99_04.02.2020.qza \
	--input-format HeaderlessTSVTaxonomyFormat

# Train the classifier.
qiime feature-classifier fit-classifier-naive-bayes \
	--i-reference-reads unite-ver8-seqs_99_04.02.2020.qza \
	--i-reference-taxonomy unite-ver8-taxonomy_99_04.02.2020.qza \
	--o-classifier unite-ver8-99-classifier-04.02.2020.qza

#See Processing ITS Sequences with QIIME2 and DADA2 for how to use the classifier file.

