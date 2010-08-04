#!/usr/bin/env ruby -w
require 'bio'

data = File.open('TBGO.tab').read
Bio::GO::Phenote_GOA.parser(data) do |entry|
  str = entry.to_str
  unless entry.taxon !~ /organism:1773/      # only M.tb.
    p str
  end
end

