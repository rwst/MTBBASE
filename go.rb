#!/usr/bin/env ruby -w
require 'bio'

data = File.open('TBGO.tab').read
Bio::GO::Phenote_GOA.parser(data) do |entry|
  entry.db = 'UniProt'
  entry.assigned_by = 'ralf@ark.in-berlin.de'
  if entry.evidence == 'IEP' and entry.aspect != 'P' then
    $stderr.print 'Error: IEP+P violated:' + "\n"
    $stderr.print(entry.to_str + "\n")
  end
  unless entry.taxon !~ /organism:1773/      # only M.tb.
    entry.taxon = 'taxon:1773'
    if entry.date =~ /20100701[3-8]/
      entry.date = entry.date.sub(/20100701([3-8])/, '2010071\1')
    end
    $stdout.print(entry.to_str + "\n")
  end
end

