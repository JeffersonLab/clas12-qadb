#!/usr/bin/env ruby

# generates a Markdown table of the defect bits and their descriptions

require 'json'

unless ENV.has_key? 'QADB'
  $stderr.puts 'you need to source environment variables'
  exit 1
end

if ARGV.empty?
  puts "USAGE: #{$PROGRAM_NAME} [OUTPUT]"
  exit 1
end
outfile = ARGV[0]

File.open(outfile, 'w') do |o|

  o.puts """# Defect Bit Definitions

- QA information is stored for each **QA bin**, in the form of **defect bits**
    - the user needs only the run number and event number to query the QADB
- A **QA bin** is:
    - the set of events between a fixed number of scaler readouts (roughly a time bin, although
      there are fluctuations in a bin's duration)
    - for older QADBs, Run Groups A, B, K, and M of Pass 1 data, the QA bins were DST 5-files
- A **defect bit** is:
    - a bit (of a binary number) that is `1` if the QA bin exhibits the corresponding defect or `0` if not
    - each defect bit corresponds to a different defect, as shown in the table below
    - many defects check the value of N/q, defined as the trigger electron yield N, normalized by the DAQ-gated Faraday Cup charge q

<table>
  <colgroup>
    <col style=\"width: 5%\">
    <col style=\"width: 25%\">
    <col style=\"width: 35%\">
    <col style=\"width: 35%\">
  </colgroup>
  <thead>
    <tr>
      <th>Bit</th>
      <th>Name</th>
      <th>Description</th>
      <th>Additional Notes</th>
    </tr>
  </thead>
  <tbody>"""

  bits_with_footnotes = {
    'SectorLoss' => 1,
    'LossFT' => 1,
  }
  footnotes = {
    1 => 'this bit may not be reliably defined in later datasets; use the other outlier bits instead'
  }

  File.open("#{ENV['QADB']}/qadb/defect_definitions.json") do |defect_file|
    defect_defs = JSON.load defect_file
    defect_defs.each do |defect_def|
      defect_cols = ['bit_number', 'bit_name', 'description', 'documentation'].map do |k|
        if k == 'bit_name'
          subscript = bits_with_footnotes.has_key?(defect_def[k]) ? "<sup>#{bits_with_footnotes[defect_def[k]]}</sup>" : ''
          "`#{defect_def[k]}`#{subscript}"
        else
          defect_def[k].to_s
        end
      end
      columns_html = defect_cols
        .map{ |it| "<td>#{it}</td>" }
        .map{ |it| it.gsub(/`([^`]+)`/, '<code>\1</code>') }
        .map{ |it| it.gsub(/__([^`]+)__/, '<strong>\1</strong>') }
        .map{ |it| it.gsub(/_([^`]+)_/, '<em>\1</em>') }
      o.puts "    <tr>"
      o.puts "      " + columns_html.join("\n      ")
      o.puts "    </tr>"
    end
  end

  o.puts "  </tbody>"
  o.puts "</table>"
  o.puts ''
  footnotes.each do |num, footnote|
    o.puts "> #{num}. #{footnote}"
  end
end
