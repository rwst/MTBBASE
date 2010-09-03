all: goa pkg upl

.PHONY: goa pkg upl

pkg :
	rm -f MTB-GOA.zip
	zip MTB-GOA gene_association.MTBBASE README.txt Changelog.txt Caveat.txt

goa :
	ruby go.rb >t
	sort -u t >out.tab
	perl filter-gene-association.pl -p MTBBASE -d <out.tab >perllog
	cp out.tab gene_association.MTBBASE

upl :
	scp -o "IdentityFile ../.ssh/kudu" MTB-GOA.zip ark@kudu.in-berlin.de:
	ssh -o "IdentityFile ../.ssh/kudu" ark@kudu.in-berlin.de ./newmtbgoa.sh
	
