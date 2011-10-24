sed 's/.*PMID:\(........\).*/\1/g' <gene_association.MTBBASE |sort|uniq >papers.txt
sed 's/^UniProtKB.\(......\).*/\1/g' <gene_association.MTBBASE |sort|uniq >proteins.txt
