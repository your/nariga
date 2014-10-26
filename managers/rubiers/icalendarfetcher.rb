require 'icalendar'
# NB: icalendar gem is modded by me to support X_WR_CALNAME field
require 'open-uri'

### WARN: AVOID CALLING THIS SCRIPT DIRECTLY
### CALL IT FROM nupdate.sh WITH 'parseit' DIRECTIVE!

##
# #### Coursera iCal fetcher

# IN: path/to/calendar.ical destinationpath
# OUT: destinationpath/COURSENAMEINBASE64.ical
## NB: [parseit] should be used only when calling from nadd.sh in parent dir!
##

######## SET ONLY THIS ONE ########
default_destdir = '../../calendars'
###################################

# will only work if calendar path given in
if ARGV.empty?
  puts "Usage...: icalendarfetcher.rb URL destinationpath [parseit]"
  exit 1
end

# get calendar location
# then get output path
url = ARGV.shift

#output to same dir of rb if none else given
out_path = ARGV.shift || (default_destdir == ''? '' : default_destdir) 

# optional THIRD arg
parse_it = ARGV.shift

# check for third optional param conflict
if out_path == 'parseit'
	out_path = default_destdir
	parse_it = 'parseit'
end

temporary_now = Time.now.to_i + Random.rand(0...1000)

calendar = out_path + (out_path == ''? '' : '/') + "temp_" + temporary_now.to_s + '.cal'

File.open(calendar, "wb") do |saved_file|
  # the following "open" is provided by open-uri
  open(url, "rb") do |read_file|
    saved_file.write(read_file.read)
  end
end

# Open a file or pass a string to the parser
cal_file = File.open(calendar)

# Parser returns an array of calendars because a single file
# can have multiple calendars.
cals = Icalendar.parse(cal_file)

calname = 'null'

calname = Base64.strict_encode64(cals.first.x_wr_calname)

new_path = out_path + (out_path == ''? '' : '/') + calname + '.cal'

File.rename(calendar, new_path)

puts "#{new_path}"

### OPTIONAL: parse this new calendar NOW!
parse_it == 'parseit'? system("ruby", "rubiers/icalendarparser.rb", new_path) : nil

### ALWAYS DO: add to courses.json
system("ruby", "rubiers/icalendaradder.rb", calname)
