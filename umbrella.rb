require "http"
require "json"

# Load required keys
google_api_key = ENV["GMAPS_KEY"]
pirate_api_key = ENV["PIRATE_WEATHER_KEY"]

puts
puts "Will you need an umbrella?"
puts 

# Get location
print "Where are you? "
user_location = gets.chomp

# Get latitude and longitude from google API
gmaps_response = HTTP.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{google_api_key}")
parsed_gmaps_data = JSON.parse(gmaps_response)

lat = parsed_gmaps_data["results"].first["geometry"]["location"]["lat"]
lng = parsed_gmaps_data["results"].first["geometry"]["location"]["lng"]

# Get weather from Pirate Weather API
pirate_weather_request_url = "https://api.pirateweather.net/forecast/#{pirate_api_key}/#{lat},#{lng}"
pirate_weather_response = HTTP.get(pirate_weather_request_url) 
parsed_pirate_weather_data = JSON.parse(pirate_weather_response)

temperature = parsed_pirate_weather_data["currently"]["temperature"]
weather_summary = parsed_pirate_weather_data["currently"]["summary"]

next_hour = parsed_pirate_weather_data["hourly"]["summary"]

puts
puts "It is currently #{temperature}°F and for the next hour it will be #{next_hour}"
puts

# Get precipitation for the next twelve hours
next_48_hours = parsed_pirate_weather_data["hourly"]["data"][1..]

umbrella = false
next_48_hours.each_with_index do | this_hour, i |
  rain_probability = (this_hour["precipProbability"] * 100).round

  puts "In #{i + 1} hours there is a #{rain_probability}% chance it will rain." if rain_probability > 10
  umbrella = true if rain_probability > 10
end

puts
puts umbrella ? "You might want to carry an umbrella!" : "You probably won’t need an umbrella today."
puts
