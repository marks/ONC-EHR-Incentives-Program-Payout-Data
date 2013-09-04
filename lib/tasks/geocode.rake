task :geocode do
  # configure data science toolkit host.
  DSTK_HOST = "www.datasciencetoolkit.org" # "www.datasciencetoolkit.org"

  # GEOCODE ELIGIBLE HOSPITALS (~2k)
  puts "Number of hospitals in collection: #{Hospital.count}"
  hospitals_without_geo = Hospital.where("geo" => nil)
  puts "Number of hospitals in collection w/o geolocation: #{hospitals_without_geo.count}"

  hospitals_without_geo.each do |h|
    if h["PROVIDER  ADDRESS"] # use data from incentive data dump
      address = "#{h["PROVIDER  ADDRESS"]}, #{h["PROVIDER CITY"]}, #{h["PROVIDER STATE"]}, USA #{h["PROVIDER ZIP 5 CD"]}"
    else # resort to general info (for providers with no incentives)
      address = "#{h["general"]["address_1"]}, #{h["general"]["city"]}, #{h["general"]["state"]}, USA #{h["general"]["zip_code"]}"
    end
    geo_results = dstk_geocode(address)
    h.update_attribute("geo",geo_results) if geo_results
  end

  # GEOCODE ELIGIBLE PROVIDERS (~106k)
  puts "Number of providers in collection: #{Provider.count}"
  providers_without_geo = Provider.where("geo" => nil)
  puts "Number of providers in collection w/o geolocation: #{providers_without_geo.count}"

  providers_without_geo.each do |p|
    geo_results = dstk_geocode("#{p["PROVIDER  ADDRESS"]}, #{p["PROVIDER CITY"]}, #{p["PROVIDER STATE"]} #{p["PROVIDER ZIP 5 CD"]}")
    p.update_attribute("geo",geo_results) if geo_results
  end
end
