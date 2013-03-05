require './web_app'

SOCRATA_APP_TOKEN = "c1qN0TO6e65zh9oxVD6XrVJyT"
# HOSPITAL_COMPARE_GENERAL_ENDPOINT = "http://data.medicare.gov/resource/v287-28n3.json?" # aka https://data.medicare.gov/dataset/Hospital-General-Information/v287-28n3
HOSPITAL_COMPARE_GENERAL_ENDPOINT += "?$$app_token=#{SOCRATA_APP_TOKEN}&"

# MAP ELIGIBLE HOSPITALS (~2k)
puts "Number of hospitals in collection: #{Hospital.count}"
hospitals_without_mapping = Hospital.where("compare.general.provider_number" => nil)
puts "Number of hospitals in collection w/o hospital compare mapping: #{hospitals_without_mapping.count}"

hospitals_without_mapping.skip(400).each do |h|
  # first, let's look for matches
  full_text_search = cleanup_string("#{h["PROVIDER - ORG NAME"]} #{h["PROVIDER CITY"]} #{h["PROVIDER ZIP 5 CD"]}")
  request_url = "#{HOSPITAL_COMPARE_GENERAL_ENDPOINT}$q=#{URI.escape(full_text_search)}"
  compare_results = JSON.parse(RestClient.get(request_url))
  if compare_results.size == 0
    puts "No mapping found for #{h["PROVIDER - ORG NAME"]} (NPI = #{h["PROVIDER NPI"]})"
  elsif compare_results.size > 1
    puts "More than one match found for #{h["PROVIDER - ORG NAME"]} (NPI = #{h["PROVIDER NPI"]})"
  else # one single match... probably a good sign!
    puts "One single match found for #{h["PROVIDER - ORG NAME"]} (NPI = #{h["PROVIDER NPI"]})!"
    compare_data = {
      "map_source" => "Socrata full text search w/ name+city+zip",
      "map_last_updated" => Time.now,
      "general" => compare_results.first
    }
    h.update_attribute("compare",compare_data)
  end
end
