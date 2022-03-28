#!/usr/bin/env ruby
# perform T-test, to determine if <asym> differs between specified run ranges

require 'pycall/import'
include PyCall::Import
pyimport 'scipy',       as: :sp
pyimport 'scipy.stats', as: :stats

sampleA = []
sampleB = []
File.open('bsa.dat','r').each_line do |line|
  runNum, asym, asymErr = line.chomp.split.map(&:to_f)

  if (6736..6757)===runNum.to_i # sampleB: runs with FADC failure in ECAL sector 6
    sampleB << asym
  else
    sampleA << asym # sampleA = not sampleB
  end
end

tTest = stats.ttest_ind( sampleA, sampleB, equal_var: false )
puts "sampleA <asym> = #{sp.mean(sampleA)}"
puts "sampleB <asym> = #{sp.mean(sampleB)}"
puts "t-statistic = #{tTest.statistic}"
puts "p-value     = #{tTest.pvalue}"
