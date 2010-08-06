#!/usr/bin/env ruby -w
require 'bio'

h = Hash.new
data = File.open('TBGO.tab').read
Bio::GO::Phenote_GOA.parser(data) do |entry|
  entry.db = 'UniProt'
  entry.assigned_by = 'ralf@ark.in-berlin.de'
  if entry.evidence == 'IEP' and entry.aspect != 'P' then
    $stderr.print 'Error: IEP+P violated:' + "\n"
    $stderr.print(entry.to_str + "\n")
  end
  if entry.goid == '0005515' then
    if entry.with.empty? then
      $stderr.print 'Error: protein binding+with violated:' + "\n"
      $stderr.print(entry.to_str + "\n")
    else
      key = entry.db_object_id.to_s + "\t" +
            entry.with.join('|') + "\t" +
            entry.db_reference.join('|')
      h[key] = true
    end
  end
  unless entry.taxon !~ /organism:1773/      # only M.tb.
    entry.taxon = 'taxon:1773'
    if entry.date =~ /20100701[3-8]/
      entry.date = entry.date.sub(/20100701([3-8])/, '2010071\1')
    end
    $stdout.print(entry.to_str + "\n")
  end
end

  h.each_key {|key|
    tmp = key.chomp.split(/\t/)
    revkey = tmp[1] + "\t" + tmp[0] + "\t" + tmp[2]
    if !h.has_key?(revkey)
      $stderr.print 'Warning: protein binding reverse entry missing:' + "\n"
      $stderr.print(revkey + "\n")
    end
  }

