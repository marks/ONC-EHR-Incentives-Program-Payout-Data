require './web_app'

HOSPITAL_COMPARE_GENERAL_ENDPOINT = "http://data.medicare.gov/resource/v287-28n3.json" # aka https://data.medicare.gov/dataset/Hospital-General-Information/v287-28n3

# MAP ELIGIBLE HOSPITALS (~2k)
puts "Number of hospitals in collection: #{Hospital.count}"
hospitals_without_mapping = Hospital.where("compare.general.provider_number" => nil)
puts "Number of hospitals in collection w/o hospital compare mapping: #{hospitals_without_mapping.count}"

hospitals_without_mapping.each do |h|
  # first, let's look for matches
  full_text_search = "#{h["PROVIDER - ORG NAME"]} #{h["PROVIDER CITY"]} #{h["PROVIDER ZIP 5 CD"]}"
  compare_results = JSON.parse(RestClient.get("#{HOSPITAL_COMPARE_GENERAL_ENDPOINT}?$q=#{URI.escape(full_text_search)}"))
  if compare_results.size == 0
    puts "No mapping found for #{h["PROVIDER - ORG NAME"]} (NPI = #{h["PROVIDER NPI"]})"
  elsif compare_results.size > 1
    puts "More than one match found for #{h["PROVIDER - ORG NAME"]} (NPI = #{h["PROVIDER NPI"]})"
  else # one single match... probably a good sign!
    compare_data = {
      "map_source" => "Socrata full text search w/ name+city+zip",
      "map_last_updated" => Time.now,
      "general" => compare_results.first
    }
    h.update_attribute("compare",compare_data)
    puts "One single match found for #{h["PROVIDER - ORG NAME"]} (NPI = #{h["PROVIDER NPI"]})!"
  end

end
