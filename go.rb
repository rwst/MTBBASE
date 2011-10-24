#!/usr/bin/env ruby -w
require 'bio'

# first read synonyms from UniProt flat file
syn = Hash.new
synfile = File.open('1773.txt').read
$stderr.print("Reading names from UniProt file...\n")
id = ""
ac = ""
names = []
synfile.each_line("\n") {|line|
  next if /^ID|^AC|^GN/ !~ line
  case line[0,2]
    when 'ID' then
		  n = (names << ac << id)
      names.each {|key| syn[key] = n if key =~ /^Rv/ or key =~ /^MT/ }
      ac = ""
      names = []
      id = line.sub(/ID +/, '').sub(/ +.*\n/, '')
    when 'AC' then
      ac = line.sub(/AC +/, '').sub(/[,;].*\n/, '') unless !ac.empty?
    when 'GN' then
      gn = line.chomp.split(/[= ,;\/]/)
      gn.each {|word|
        if !word.empty? and
           word !~ /GN|and|Name|Synonyms|OrderedLocusNames|ORFNames/ then
          names << word
        end }
    else $stderr.print("Can't happen: " + line[0,2] + "\n")
  end
  }

h = Hash.new
data = File.open('TBGO.tab').read
Bio::GO::Phenote_GOA.parser(data) do |entry|
  entry.db = 'UniProtKB'
  entry.assigned_by = 'MTBBASE'
  if entry.evidence == 'IEP' and entry.aspect != 'P' then
    $stderr.print 'Error: IEP+P violated:' + "\n"
    $stderr.print(entry.to_str + "\n")
  end
  # homodi-, oligomerization
  if ["0042803", "0070207", "0051289", "0051260"].include?(entry.goid) 
  then
    entry.evidence = 'IPI' if entry.evidence == 'IDA'
    $stderr.print 'Adding With and IPI to homodi-/oligomer' + "\n"
    entry.with = entry.db_object_id
  end
  # protein binding and children
  if ["0005515", "0046982", "0046789"].include?(entry.goid) then
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
  else
    if entry.evidence == 'IDA' or entry.evidence == 'IEP' then
      if !entry.with.empty? then
        $stderr.print 'Warning: IDA/IEP+!with violated:' + "\n"
        $stderr.print(entry.to_str + "\n")
        entry.with = ''
      end
    end
  end
  unless entry.taxon !~ /organism:1773/      # only M.tb.
    entry.taxon = 'taxon:1773'
    if entry.date =~ /20100701[3-8]/
      entry.date = entry.date.sub(/20100701([3-8])/, '2010071\1')
    end
    obid = entry.db_object_id
    if obid =~ /^Rv/ or obid =~ /^MT/ then
      if !syn.has_key?(obid)
        $stderr.print("Error: Unknown RvID: '" + obid + "'\n")
      else
        syns = syn[obid]
        id = syns[-1]
        ac = syns[-2]
        syns = syns[0..-3]
        entry.db_object_id = ac
        entry.db_object_symbol = id
        entry.db_object_synonym = syns.flatten
      end
    else
        $stderr.print('Error: Empty RvID' + "\n")
		end
    withs = []
    entry.with.each {|with|
      if !with.empty? then
        if !syn.has_key?(with)
          $stderr.print('Error: Unknown With RvID:' + with + "\n")
          withs << with
        else
          syns = syn[with]
          withs << ['UniProtKB:' + syns[-2]]
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

