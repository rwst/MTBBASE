What is it?
-----------
• Gene Ontology annotations (GAF 2.0) on Mycobacterium tuberculosis H37Rv (MYCTU)
• paper-centric: nearly all papers from Pubmed search on MYCTU up to and including publication date 2008 (<PMID 19100000)
• private, one-man effort
• updated yearly
• excluding results based on microarrays only

Quality control
---------------
• several manual checks, incl. random rechecks
• using homegrown ruby scripts, several further tests
• using filter-gene-association.pl script from gene-ontology.org
• all passes, except IDA+With (deliberately not corrected)

Statistics
----------
• 885 papers
• 2260 proteins
• 56 per cent of genome
• 5844 annotations using 750 kB

Motivation
----------
• idea came from Indian "Open Source Drug Development" (OSDD) initiative where we participated
• OSDD will likely use data, too
• no MYCTU GOA file at UniProt GOA archive
• no existing paper-centric GOA files at all

Methods and software
--------------------
• Pubmed for title/abstract search of relevant papers among >25,000 MYCTU papers
• Phenote editor for annotations
• Bibdesk bibliography software
• web sites from GO, QuickGO, UniProt, tuberculist.epfl.ch, ChEBI
• added/corrected several GO entries via Sourceforge
• ruby for quality control and translation to GAF 2.0
• perl for quality control

Home:
http://www.ark.in-berlin.de/Site/MTB-GOA.html

Ralf Stephan
MTBBASE
http://www.ark.in-berlin.de/Site/MTBbase.html
