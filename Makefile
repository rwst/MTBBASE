all: goa pkg upl

.PHONY: goa pkg upl

pkg :
	rm -f MTB-GOA.zip
	zip MTB-GOA gene_association.MTBBASE README.txt Changelog.txt Caveat.txt
	cp MTB-GOA.zip archiv/MTB-GOA-`cat version`-`date +%Y-%m-%d`.zip

goa :
	echo Making version `cat version`
	ruby go.rb >t
	sort -u t >out.tab
	perl filter-gene-association.pl -p MTBBASE -d <out.tab >perllog
	cp out.tab gene_association.MTBBASE

upl :
	sh add_version.sh
	scp -i ../.ssh/kudu MTB-GOA.zip MTB-GOA.html ark@kudu.in-berlin.de:
	ssh -i ../.ssh/kudu ark@kudu.in-berlin.de ./newmtbgoa.sh
	
