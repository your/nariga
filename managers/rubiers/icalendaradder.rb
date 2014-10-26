require "rubygems"
require "json"

### WARN: AVOID CALLING THIS SCRIPT DIRECTLY
### CALL IT FROM nadd.sh WITH 'parseit' DIRECTIVE!

##
# #### Utility to add a json to jsons dir listing courses by b64 names only
#
# IN: COURSENAMEINBASE64
# OUT: [ "VGhlIERhdGEgU2NpZW50aXN04oCZcyBUb29sYm94", "VGhlIERhdGEgU2NpZW50aXN04oCZcyBUb29sYm94" ]
# (at location default_dest)
##

######## SET ONLY THIS ONE #############################################################
default_dest = '../web/jsons/courses/courses.json'
########################################################################################

# will only work if calendar path given in
if ARGV.empty?
  puts "Usage...: COURSENAMEINBASE64"
  exit 1
end

hash = ARGV.shift

# def json struct for course
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

course_list = Array.new

# course how are you composed?
class Course < Struct.new(:course); end

# Read existing courses and load in memory
file = File.open(default_dest, "r")

parsed = JSON.parse(file.read)

parsed.each do |course|
	currcourse = course["course"]
	courseobj = Course.new(currcourse)
	course_list.push(courseobj)
	puts currcourse
end

file.close

# Add also the new course
coursenew = Course.new(hash)
course_list.push(coursenew)

# Remove duplicates if any
course_list = course_list.uniq

puts course_list.length
# Time to generate a new json
file = File.open(default_dest, "w")

json = JSON.pretty_generate(course_list)
file.write(json)
file.close

#file.write("]")
#course_list.each_with_index { |course, index|

#	json = JSON.pretty_generate(course)

#	file.write(json)
#	puts json
#	index < course_list.length-1 ? file.write(",") : nil
#}
#file.write("]")

