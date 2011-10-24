require 'bio'

data = File.read('P04637.txt')
obj = Bio::UniProt.new(data)
p obj.gene_name
