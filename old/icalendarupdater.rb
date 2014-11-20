# Read JSON from file, iterate over objects
file = File.read(default_destdir)

parsed = JSON.parse(file)

# all I need is urls
parsed.each do |course|
  p course["calurl"]
end
