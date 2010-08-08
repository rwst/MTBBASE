#!/usr/bin/env ruby -w
require 'bio'

# first read synonyms from UniProt flat file
syn = Hash.new
synfile = File.open('1773.txt').read
$stderr.print("Reading names from UniProt file...\n")
id = ""
ac = ""
keys = []
names = []
synfile.each_line("\n") {|line|
  next if /^ID|^AC|^GN/ !~ line
  case line[0,2]
    when 'ID' then
      if !keys.empty? then
        keys.each {|key|
          if syn.has_key?(key)
            $stderr.print("Error: duplicate name: '" + key + "'\n")
          else
            syn[key] = (names << ac << id)
          end }
        id = ""    # never assume id = ac = "" will succeed
        ac = ""
        keys = []
        names = []
      end
      id = line.sub(/ID +/, '').sub(/ +.*\n/, '')
    when 'AC' then
      ac = line.sub(/AC +/, '').sub(/[,;].*\n/, '')
    when 'GN' then
      gn = line.chomp.split(/[= ,;\/]/)
      gn.each {|word|
        if !word.empty? and
           word !~ /GN|and|Name|Synonyms|OrderedLocusNames|ORFNames/ then
          if word =~ /^Rv/
            keys << word
          end
          names << word
        end }
    else $stderr.print("Can't happen: " + line[0,2] + "\n")
  end
  }

h = Hash.new
data = File.open('TBGO.tab').read
Bio::GO::Phenote_GOA.parser(data) do |entry|
  entry.db = 'UniProt'
  entry.assigned_by = 'UniProt'
  if entry.evidence == 'IEP' and entry.aspect != 'P' then
    $stderr.print 'Error: IEP+P violated:' + "\n"
    $stderr.print(entry.to_str + "\n")
  end
  if entry.goid == '0005515' then
    if entry.with.empty? then
      $stderr.print 'Error: protein binding+with violated:' + "\n"
      $stderr.print(entry.to_str + "\n")
    else
      entry.evidence = 'IPI'
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
    obid = entry.db_object_id
    if obid =~ /^Rv/
      if !syn.has_key?(obid)
        $stderr.print("Error: Unknown RvID: '" + obid + "'\n")
      else
        syns = syn[obid]
        id = syns[-1]
        ac = syns[-2]
        syns = syns[0..-3]
        entry.db_object_id = 'UniProt:' + ac
        entry.db_object_symbol = id
        entry.db_object_synonym = syns.flatten
      end
    end
    withs = []
    entry.with.each {|with|
      if !with.empty? then
        if !syn.has_key?(with)
          $stderr.print('Error: Unknown With RvID:' + with + "\n")
        else
          syns = syn[with]
          withs << ['UniProt:' + syns[-2]]
#          $stderr.print("With RvID: '" + with + "'\n")
        end
      end }
    entry.with = withs
    $stdout.print(entry.to_str + "\n")
  end
end

  h.each_key {|key|
    tmp = key.chomp.split(/\t/)
    revkey = tmp[1] + "\t" + tmp[0] + "\t" + tmp[2]
    if !h.has_key?(revkey)
#      $stderr.print 'Warning: protein binding reverse entry missing:' + "\n"
#      $stderr.print(revkey + "\n")
    end
  }

