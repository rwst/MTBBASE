#!/usr/bin/env ruby -w
require 'bio'

data = File.open('TBGO.tab').read
Bio::GO::Phenote_GOA.parser(data) do |entry|
  str = entry.to_str
  str = str.sub(/rwst1/, 'ralf@ark.in-berlin.de')
  str = str.sub(/rwst/, 'ralf@ark.in-berlin.de')
  unless entry.taxon !~ /organism:1773/      # only M.tb.
    p "TBGO" + str
  end
end

