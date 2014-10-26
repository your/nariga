require 'icalendar'
# NB: icalendar gem is modded by me to support X_WR_CALNAME field
require 'time_difference'
require 'date'
require 'json'

### WARN: AVOID CALLING THIS SCRIPT DIRECTLY
### CALL IT FROM nadd.sh WITH 'parseit' DIRECTIVE!

##
# #### iCal to sorted JSONed narigas

# IN: path/to/calendar.ical destinationpath
# OUT: destinationpath/COURSENAMEINBASE64.json
##

######## SET ONLY THIS ONE #############################################################
default_destdir = '../web/jsons/courses' #NB. always one ../ less than icalendarfetcher!
ndata_dir = '../ndata/' #NB. always one ../ less than icalendarfetcher!
########################################################################################

# will only work if calendar path given in
if ARGV.empty?
  puts "Usage...: icalendarparser.rb path/to/calendar.cal"
  exit 1
end

# get calendar location
# then get output path
calendar = ARGV.shift
out_path = ARGV.shift || (default_destdir == ''? '' : default_destdir)

# def json struct for narigas
class Struct
  def to_map
    map = Hash.new
    self.members.each { |m| map[m] = self[m] }
    map
  end

  def to_json(*a)
    to_map.to_json(*a)
  end
end


# nariga how are you composed?
class Nariga < Struct.new(:course, :assign, :deadline, :link, :id); end

# we'll have a list of narigas objs
deadpool = Array.new

# init current id to zero
id = 0


id_narigas = ndata_dir + 'id.narigas'
# open id.narigas and set a id to current
File.open(id_narigas) { |f| id = f.gets.to_i }

# Open a file or pass a string to the parser
cal_file = File.open(calendar)

# Parser returns an array of calendars because a single file
# can have multiple calendars.
cals = Icalendar.parse(cal_file)

calname = 'null'

cals.each { |cal|
	
	# get course name and hash it in base64
	calname = Base64.strict_encode64(cal.x_wr_calname)
	
	#cal = cals.first

	# Now you can access the cal object in just the same way I created it
	events = cal.events
	
	events.each { |event|
	
		end_time = event.dtend
		
		id += 1
		
		# create object
		deadline = Nariga.new(cal.x_wr_calname, event.summary, end_time.to_i, event.location, id)
		# add to deadpool
		deadpool.push(deadline)

		puts "end date-time: #{event.dtend}"
		puts "end date-time timezone: #{event.dtend.ical_params['tzid']}"
		puts "end secs: #{end_time.to_i}"
		puts "location: #{event.location}"
		puts "summary: #{event.summary}"
		puts "ccc: #{cal.x_wr_calname}"
		
		# update id so far!!!!!!!!
		File.open(id_narigas, "w") do |saved_file|
			saved_file.write(id)
		end
	}	

}

# order deadpool objects list by deadline (secs asc)
## TEMP DISABLED: SORTING CLIENT SIDE!
#deadpool = deadpool.sort_by { |nariga| [nariga.deadline] }

# time to write to file

new_path = out_path + (out_path == ''? '' : '/') + calname + '.json'

File.open(new_path, 'w') { |file|

	file.write("[")
	
	deadpool.each_with_index { |deadline, index| 
		
		json = JSON.pretty_generate(deadline)
		file.write(json)		
		# puts json
		index < deadpool.length-1 ? file.write(",") : nil
	}
	
	file.write("]")
}


