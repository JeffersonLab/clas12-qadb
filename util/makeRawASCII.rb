#!/usr/bin/env ruby
# produce raw ASCII file from qaTree.json + chargeTree.json

require 'json'

# parse arguments
if ARGV.length < 2
  warn "Usage: #{$PROGRAM_NAME} [qaTree.json] [chargeTree.json] [output.txt]"
  exit 1
end
qa_file, ch_file, out_file = ARGV
qa_json = JSON.parse(File.read(qa_file))
ch_json = JSON.parse(File.read(ch_file))

# make sure the files agree on their runs and QA bins
unless ch_json.keys.sort == qa_json.keys.sort
  abort "ERROR: Run numbers differ between files:\n" \
        "  only in #{ch_file}: #{(ch_json.keys - qa_json.keys).inspect}\n" \
        "  only in #{qa_file}: #{(qa_json.keys - ch_json.keys).inspect}"
end
ch_json.each do |runnum, bins|
  next if bins.keys.sort == qa_json[runnum].keys.sort
  abort "ERROR: Bin numbers differ for run #{runnum}:\n" \
        "  only in #{ch_file}: #{(bins.keys - qa_json[runnum].keys).inspect}\n" \
        "  only in #{qa_file}: #{(qa_json[runnum].keys - bins.keys).inspect}"
end

##################################################################################
# helper functions
##################################################################################

# convert array of defect bit numbers -> bitmask
def bits2mask(list)
  list.reduce(0) do |mask, n|
    mask | (1 << Integer(n))
  end
end

# flatten one bin's hash into an ordered { column_name => number } hash; ignores comments
def flatten_bin(fields)
  out = {}
  fields.each do |key, val|
    case val
    when Numeric
      out[key] = val
    when Hash
      val.each do |sub_key, sub_val|
        out_key = "#{key}_#{sub_key}"
        case sub_val
        when Numeric
          out[out_key] = sub_val
        when Array
          case sub_key
          when 'sectorDefects'
            out[out_key] = bits2mask(sub_val)
          else
            raise "unknown Array-type for key '#{sub_key}'"
          end
        end
      end
    when String
      raise "unknown String-type value for key '#{key}'" unless key == 'comment'
    end
  end
  out
end

# sort keys numerically when they look like integers, otherwise as strings
def key_sort(hash)
  hash.keys.sort_by do |k|
    k =~ /\A-?\d+\z/ ? [0, k.to_i, ''] : [1, 0, k]
  end
end

##################################################################################
# main
##################################################################################

# raw output columns and rows
col_names = nil
raw_rows  = []

# loop over each run and its QA bins
key_sort(qa_json).each do |runnum|
  key_sort(qa_json[runnum]).each do |binnum|

    # flatten and merge this bin's hashes from `qaTree.json` and `chargeTree.json`
    flat_hash = flatten_bin(qa_json[runnum][binnum])
      .merge(flatten_bin(ch_json[runnum][binnum]))

    # verify the flattened keys are consistent
    col_names ||= flat_hash.keys
    unless flat_hash.keys == col_names
      abort "ERROR: Inconsistent columns at run #{runnum}, bin #{binnum}:\n" \
            "  expected #{col_names.inspect}\n  got      #{flat_hash.keys.inspect}"
    end

    # append to output rows
    raw_rows << [runnum.to_i, binnum.to_i] + flat_hash.values
  end
end

# prepend run number and bin number to `col_names`
col_names.prepend 'runnum', 'binnum'








# Format every cell as text, then right-align each column.
table  = [col_names] + raw_rows.map { |r| r.map(&:to_s) }
widths = col_names.each_index.map { |i| table.map { |r| r[i].length }.max }

lines = table.each_with_index.map do |r, idx|
  line = r.each_with_index.map { |cell, i| cell.rjust(widths[i]) }.join('  ')
  idx.zero? ? "# #{line}" : "  #{line}"   # '#' marks the col_names as a comment
end

if out_file
  File.write(out_file, lines.join("\n") + "\n")
  warn "Wrote #{raw_rows.length} rows x #{col_names.length} columns to #{out_file}"
else
  puts lines
end
