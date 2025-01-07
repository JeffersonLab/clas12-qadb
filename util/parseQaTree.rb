#!/usr/bin/env ruby
# parses qa/qaTree.json into human readable format

require 'json'

if ARGV.empty?
  puts "USAGE: #{$0} [qaTree.json file]"
  exit 2
end
raise 'source environment variables first' if ENV['QADB'].nil?
defect_defs_file = "#{ENV['QADB']}/qadb/defect_definitions.json"

# parse arguments
qa_tree_file  = ARGV[0]
[qa_tree_file, defect_defs_file].each do |f|
  raise "#{f} does not exist" unless File.exist? f
end
qa_tree     = JSON.load_file qa_tree_file
defect_defs = JSON.load_file defect_defs_file

# define output file
out_file_name = qa_tree_file + '.table'
out_file      = File.open out_file_name, 'w'

# define defect bit hash: bit number -> defect name
defect_hash = defect_defs.map do |defect|
  [ defect['bit_number'], defect['bit_name'] ]
end.to_h

# loop over runs
qa_tree.sort{ |a,b| a.first.to_i <=> b.first.to_i }.each do |run, run_tree|
  out_file.puts "RUN: #{run}"

  # loop over QA bins
  run_tree.sort{ |a,b| a.first.to_i <=> b.first.to_i }.each do |bin, bin_tree|

    out_row = ["#{run} #{bin}"]

    # handle defects
    bin_defect = bin_tree['defect']
    if bin_defect > 0
      defect_hash.each do |bit, bit_name|
        if bin_defect >> bit & 0x1 == 1
          sector_list = bin_tree['sectorDefects'].filter_map do |sector, sector_defects|
            sector if sector_defects.include? bit
          end
          sector_list = ['all'] if sector_list.length == 6
          out_row << "#{bit}-#{bit_name}[#{sector_list.join ', '}]"
        end
      end
    else
      out_row << 'GOLDEN'
    end

    # handle comment
    bin_comment = bin_tree['comment']
    unless bin_comment.nil?
      out_row << ":: #{bin_comment}" unless bin_comment.empty?
    end

    # stream
    out_file.puts out_row.join('  ')

  end
  out_file.puts ''
end

# close
out_file.close
puts "produced #{out_file_name}"
