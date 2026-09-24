#!/usr/bin/env ruby
# produce a raw ASCII table file from qaTree.json + chargeTree.json

require 'json'

# parse arguments
if ARGV.length != 3
  warn "Usage: #{$PROGRAM_NAME} [dataset] [input_dir] [output_basename]"
  exit 1
end
dataset, in_dir, out_basename = ARGV
qa_file = "#{in_dir}/qaTree.json"
ch_file = "#{in_dir}/chargeTree.json"
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

# debug printer
def debug(msg)
  puts msg if false
end

# flatten one bin's hash into an ordered { column_name => number } hash; ignores comments
def flatten_bin(fields)
  out = {}
  fields.each do |key, val|
    debug "key=#{key} val=#{val}"
    case val
    when Numeric
      out[key] = val
      debug "  write(L1) #{key} => #{val}"
    when Hash
      val.each do |sub_key, sub_val|
        debug "sub_key=#{sub_key} sub_val=#{sub_val}"
        out_key = "#{key}_#{sub_key}"
        case sub_val
        when Numeric
          out[out_key] = sub_val
          debug "  write(L2) #{out_key} => #{sub_val}"
        when Array
          case key
          when 'sectorDefects'
            out[out_key] = bits2mask(sub_val)
            debug "  write(L2) #{out_key} => bits2mask(#{sub_val})"
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

# output columns
File.open("#{out_basename}.columns.md", 'w') do |o|
  col_desc = {
    'runnum'              => 'Run number',
    'binnum'              => 'QA bin number',
    'evnumMin'            => 'Event number minimum',
    'evnumMax'            => 'Event number maximum',
    'sectorDefects_1'     => 'Defect bit field for sector 1',
    'sectorDefects_2'     => 'Defect bit field for sector 2',
    'sectorDefects_3'     => 'Defect bit field for sector 3',
    'sectorDefects_4'     => 'Defect bit field for sector 4',
    'sectorDefects_5'     => 'Defect bit field for sector 5',
    'sectorDefects_6'     => 'Defect bit field for sector 6',
    'defect'              => 'Full defect bit field: OR of sectors\' defect bit fields',
    'fcChargeMin'         => 'DAQ-gated DSC2-scalers FC charge at lower bin boundary (or minimum, for older DBs)',
    'fcChargeMax'         => 'DAQ-gated DSC2-scalers FC charge at upper bin boundary (or maximum, for older DBs)',
    'ufcChargeMin'        => 'Ungated DSC2-scalers FC charge at lower bin boundary (or minimum, for older DBs)',
    'ufcChargeMax'        => 'Ungated DSC2-scalers FC charge at upper bin boundary (or maximum, for older DBs)',
    'livetime'            => 'Live time',
    'nElec_1'             => 'Number of FD trigger electrons for sector 1',
    'nElec_2'             => 'Number of FD trigger electrons for sector 2',
    'nElec_3'             => 'Number of FD trigger electrons for sector 3',
    'nElec_4'             => 'Number of FD trigger electrons for sector 4',
    'nElec_5'             => 'Number of FD trigger electrons for sector 5',
    'nElec_6'             => 'Number of FD trigger electrons for sector 6',
    'fcChargeHelicity_-1' => 'DAQ-gated STRUCK-scalers charge latched to helicity = -1',
    'fcChargeHelicity_0'  => 'DAQ-gated STRUCK-scalers charge latched to helicity = 0',
    'fcChargeHelicity_1'  => 'DAQ-gated STRUCK-scalers charge latched to helicity = +1',
  }
  o.puts """# Raw Table Columns for `#{dataset}`

  | Column | Description |
  | --- | --- |"""
  col_names.each_with_index do |col,idx|
    raise "unknown column name '#{col}'" unless col_desc.has_key? col
    o.puts "| #{(idx+1).to_s} | #{col_desc[col]} |"
  end
end

# output rows
File.open("#{out_basename}.table.txt", 'w') do |o|
  raw_rows.each do |row|
    o.puts row.join(' ')
  end
end
