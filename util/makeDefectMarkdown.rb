#!/usr/bin/env ruby

# generates a Markdown table of the defect bits and their descriptions

require 'json'

unless ENV.has_key? 'QADB'
  $stderr.puts 'you need to source environment variables'
  exit 1
end

def puts_row(columns)
  puts "| #{columns.join ' | '} |"
end

puts_row ['Bit', 'Name', 'Description', 'Additional Notes']
puts_row 4.times.map{|i|'---'}

File.open("#{ENV['QADB']}/qadb/defect_definitions.json") do |defect_file|
  defect_defs = JSON.load defect_file
  defect_defs.each do |defect_def|
    defect_cols = ['bit_number', 'bit_name', 'description', 'documentation'].map do |k|
      if k == 'bit_name'
        "`#{defect_def[k]}`"
      else
        defect_def[k].to_s
      end
    end
    puts_row defect_cols
  end
end
