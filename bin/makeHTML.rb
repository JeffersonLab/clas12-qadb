#!/usr/bin/env ruby

require 'json'

defect_defs_file = 'qadb/defect_definitions.json'
if ARGV.empty?
  puts "USAGE: #{$0} [qaTree.json file] [defect_definitions (default=#{defect_defs_file}]"
  exit 2
end

# parse arguments
qa_tree_file     = ARGV[0]
defect_defs_file = ARGV[1] if ARGV.length > 1
[qa_tree_file, defect_defs_file].each do |f|
  raise "#{f} does not exist" unless File.exist? f
end
qa_tree     = JSON.load_file qa_tree_file
defect_defs = JSON.load_file defect_defs_file

# get the bit number for 'Misc'
Misc = defect_defs.find{ |d| d['bit_name'] == 'Misc' }['bit_number']

# return whether or not `defect` has defect bit `bit` set
def has_defect(bit, defect)
  (defect >> bit) & 0x1 == 1
end

# table header
puts """
For each run, the table shows:
- `Misc` defect?:
  - \"yes\" if _any_ of the QA bins in this runs has the `Misc` defect
  - this does not mean this defect is present for the entire run
- Unique Comments:
  - each QA bin can have its own comment, which is usually set when a bin has the `Misc` defect
  - not all bins have to have the same comment
  - this table shows the _unique_ comments that are found for this run

See the QA file for more detailed, bin-by-bin information: `#{qa_tree_file}.table`

### Misc Comments

| Run | `Misc` defect? | Unique Comments |
| --- | ---            | ---             |
"""

# loop over runs
qa_tree.each do |runnum, qa_tree_run|

  comments     = Array.new
  has_misc_bit = false

  # loop over QA bins
  qa_tree_run.each do |binnum, qa_tree_bin|
    comments << qa_tree_bin['comment'] unless comments.include? qa_tree_bin['comment']
    has_misc_bit |= has_defect Misc, qa_tree_bin['defect']
  end

  # remove empty comments
  comments.reject!{ |comment| comment.empty? }

  # dump the table
  has_misc_bit_str = has_misc_bit ? "yes" : "no"
  puts '| ' + [
    runnum.ljust(10),
    has_misc_bit_str.ljust(5),
    comments.join('; '),
  ].join(' | ') + ' |'

end
