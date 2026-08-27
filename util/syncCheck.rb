#!/usr/bin/env ruby
# highlights where we have a QADB syncing problem:
# eventnumMax of bin N is larger than eventnumMin of bin N+1

require 'json'

if ARGV.empty?
  puts "USAGE: #{$0} [dataset]"
  exit(2)
end
raise 'source environment variables first' if ENV['QADB'].nil?
dataset = ARGV.first

qa_tree_file = File.join ENV['QADB'], 'qadb', dataset.split('/'), 'qaTree.json'
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
    if evnumMin > evnumMax
      $stderr.puts "ERROR run=#{runnum} bin=#{binnum}: evnumMin > evnumMax: #{evnumMin} > #{evnumMax}"
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

if found_issue_anywhere
  if [ # datasets which used DST 5-files as QA bins
      "pass1/rga_fa18_inbending",
      "pass1/rga_fa18_outbending",
      "pass1/rga_sp19",
      "pass1/rgb_fa19",
      "pass1/rgb_sp19",
      "pass1/rgb_wi20",
      "pass1/rgk_fa18_6.5GeV",
      "pass1/rgk_fa18_7.5GeV",
      "pass1/rgm_fa21",
  ].include? dataset
    $stderr.puts "WARNING: this dataset was done using DST 5-files as QA bins, which inherently causes SYNC ERRORS; now exitting with 0"
    exit 0
  else
    $stderr.puts "ERROR: this dataset should not have any errors"
    exit 1
  end
end
