task :geocode do
  
  # GEOCODE ELIGIBLE HOSPITALS (~2k)
  puts "Number of hospitals in collection: #{Hospital.count}"
  hospitals_without_geo = Hospital.where("geo" => nil)
  puts "Number of hospitals in collection w/o geolocation: #{hospitals_without_geo.count}"

  hospitals_without_geo.each do |h|
    # Let's not deal with non-US 50
    next if h["general"]["state"] == "PR"
    next if h["general"]["state"] == "VI" 
    next if h["general"]["state"] == "MP" 
    next if h["general"]["state"] == "GU" 
    next if h["PROVIDER STATE"] == "Guam" 

    begin
      geo_results = dstk_geocode(h.full_address)
      h.update_attribute("geo",geo_results) if geo_results
    rescue => e 
      puts "\n   GEOCODE ERROR: #{e}"
    end
  end

  # GEOCODE ELIGIBLE PROVIDERS (~106k)
  puts "Number of providers in collection: #{Provider.count}"
  providers_without_geo = Provider.where("geo" => nil)
  puts "Number of providers in collection w/o geolocation: #{providers_without_geo.count}"

  providers_without_geo.each do |p|
    begin
      geo_results = dstk_geocode("#{p["PROVIDER  ADDRESS"]}, #{p["PROVIDER CITY"]}, #{p["PROVIDER STATE"]} #{p["PROVIDER ZIP 5 CD"]}")
      p.update_attribute("geo",geo_results) if geo_results
    rescue => e 
      puts "\n   GEOCODE ERROR: #{e}"
    end
  end
end
