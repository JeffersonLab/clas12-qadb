#!/usr/bin/env ruby
# produce a raw ASCII table file from qaTree.json + chargeTree.json

require 'json'

# all possible column names, their types (integer or real), and descriptions
COLUMN_DEFS = {
  'runnum'              => { :type => :integer, :desc => 'Run number' },
  'binnum'              => { :type => :integer, :desc => 'QA bin number' },
  'evnumMin'            => { :type => :integer, :desc => 'Event number minimum' },
  'evnumMax'            => { :type => :integer, :desc => 'Event number maximum' },
  'sectorDefects_1'     => { :type => :integer, :desc => 'Defect bit field for sector 1' },
  'sectorDefects_2'     => { :type => :integer, :desc => 'Defect bit field for sector 2' },
  'sectorDefects_3'     => { :type => :integer, :desc => 'Defect bit field for sector 3' },
  'sectorDefects_4'     => { :type => :integer, :desc => 'Defect bit field for sector 4' },
  'sectorDefects_5'     => { :type => :integer, :desc => 'Defect bit field for sector 5' },
  'sectorDefects_6'     => { :type => :integer, :desc => 'Defect bit field for sector 6' },
  'defect'              => { :type => :integer, :desc => 'Full defect bit field: <code>OR</code> of sectors\' defect bit fields' },
  'fcChargeMin'         => { :type => :real,    :desc => 'DAQ-gated integrated FC charge [nC] at bin lower boundary, or zero for newer DBs, or bin minimum for older DBs' },
  'fcChargeMax'         => { :type => :real,    :desc => 'DAQ-gated integrated FC charge [nC] at bin upper boundary, or bin maximum for older DBs; subtract <code>fcChargeMin</code> for total bin\'s charge' },
  'ufcChargeMin'        => { :type => :real,    :desc => 'Full (ungated) integrated FC charge [nC] at bin lower boundary, or zero for newer DBs, or bin minimum for older DBs' },
  'ufcChargeMax'        => { :type => :real,    :desc => 'Full (ungated) integrated FC charge [nC] at bin upper boundary, or bin maximum for older DBs; subtract <code>ufcChargeMin</code> for total bin\'s charge' },
  'livetime'            => { :type => :real,    :desc => 'Live time' },
  'nElec_1'             => { :type => :integer, :desc => 'Number of FD trigger electrons for sector 1' },
  'nElec_2'             => { :type => :integer, :desc => 'Number of FD trigger electrons for sector 2' },
  'nElec_3'             => { :type => :integer, :desc => 'Number of FD trigger electrons for sector 3' },
  'nElec_4'             => { :type => :integer, :desc => 'Number of FD trigger electrons for sector 4' },
  'nElec_5'             => { :type => :integer, :desc => 'Number of FD trigger electrons for sector 5' },
  'nElec_6'             => { :type => :integer, :desc => 'Number of FD trigger electrons for sector 6' },
  'fcChargeHelicity_-1' => { :type => :real,    :desc => 'DAQ-gated charge [nC] latched to negative beam helicity states' },
  'fcChargeHelicity_0'  => { :type => :real,    :desc => 'DAQ-gated charge [nC] latched to invalid/undefined beam helicity states' },
  'fcChargeHelicity_1'  => { :type => :real,    :desc => 'DAQ-gated charge [nC] latched to positive beam helicity states' },
}

##################################################################################

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

    # stringify the values
    val_strings = flat_hash.map do |col_name, val|
      raise "unknown column name '#{col_name}'" unless COLUMN_DEFS.has_key? col_name
      case COLUMN_DEFS[col_name][:type]
      when :integer then val.to_i.to_s
      when :real    then val.to_f.to_s
      else raise "unknown column type for column '#{col_name}'"
      end
    end

    # append to output rows
    raw_rows << [runnum.to_i.to_s, binnum.to_i.to_s] + val_strings
  end
end

# prepend run number and bin number to `col_names`
col_names.prepend 'runnum', 'binnum'

# output columns
File.open("#{out_basename}.columns.md", 'w') do |o|
  o.puts """# Raw Table Columns for `#{dataset}`

<table>
  <colgroup>
    <col style=\"width: 5%\">
    <col style=\"width: 30%\">
    <col style=\"width: 65%\">
  </colgroup>
  <thead>
    <tr>
      <th>Column</th>
      <th>Name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>"""
  col_names.each_with_index do |col_name, idx|
    raise "unknown column name '#{col_name}'" unless COLUMN_DEFS.has_key? col_name
    o.puts "    <tr>"
    o.puts "      <td>#{idx+1}</td>"
    o.puts "      <td><code>#{col_name}</code></td>"
    o.puts "      <td>#{COLUMN_DEFS[col_name][:desc]}</td>"
    o.puts "    </tr>"
  end
  o.puts """  </tbody>
</table>"""
end

# output rows
File.open("#{out_basename}.table.txt", 'w') do |o|
  raw_rows.each do |row|
    o.puts row.join(' ')
  end
end
