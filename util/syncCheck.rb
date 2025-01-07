#!/usr/bin/env ruby
# highlights where we have a QADB syncing problem:
# eventnumMax of bin N is larger than eventnumMin of bin N+1

require 'json'

if ARGV.empty?
  puts "USAGE: #{$0} [dataset]"
  exit(2)
end
raise 'source environment variables first' if ENV['QADB'].nil?

qa_tree_file = File.join ENV['QADB'], 'qadb', ARGV.first.split('/'), 'qaTree.json'
raise "#{qa_tree_file} does not exist" unless File.exist? qa_tree_file
qa_tree = JSON.load_file qa_tree_file

# true if any issue found
found_issue_anywhere = false

# loop over runs
qa_tree.sort{ |a,b| a.first.to_i <=> b.first.to_i }.each do |runnum, run_tree|

  binnum_prev = nil
  found_issue_in_run = false

  # loop over QA bins
  run_tree.sort{ |a,b| a.first.to_i <=> b.first.to_i }.each do |binnum, bin_tree|

    # check that min event number < max
    evnumMin = bin_tree['evnumMin']
    evnumMax = bin_tree['evnumMax']
    if evnumMin >= evnumMax
      $stderr.puts "ERROR run=#{runnum} bin=#{binnum}: evnumMin >= evnumMax: #{evnumMin} >= #{evnumMax}"
      found_issue_anywhere = true
      found_issue_in_run = true
    end

    # check for overlap with previous bin
    unless binnum_prev.nil?
      evnumMin_prev = run_tree[binnum_prev]['evnumMin']
      evnumMax_prev = run_tree[binnum_prev]['evnumMax']
      if evnumMax_prev > evnumMin
        $stderr.puts """SYNC ERROR: run=#{runnum} bin=#{binnum}: previous bin's evnumMax > this bin's evnumMin:
  prev bin:  binnum=#{binnum_prev}\tevnumMin=#{evnumMin_prev}\tevnumMax=#{evnumMax_prev}
  this bin:  binnum=#{binnum}\tevnumMin=#{evnumMin}\tevnumMax=#{evnumMax}"""
        found_issue_anywhere = true
        found_issue_in_run = true
      end
    end

    binnum_prev = binnum

  end

  puts "RUN #{runnum} #{found_issue_in_run ? "has issues (see stderr)" : "is okay"}"
end

exit 1 if found_issue_anywhere
