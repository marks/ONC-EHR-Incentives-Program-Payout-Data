def dstk_geocode(string)
  # mongoimport drops leading "0" in zip codes; we need to geocode with the leading "0" though
  original_zip = string.split(" ").last
  if original_zip.to_s.length < 5
    zeros_to_add = ""
    (5 - original_zip.to_s.length).times {zeros_to_add += "0"} # Integer*"0" doesn't seem to work
    zip5 = " #{zeros_to_add}#{original_zip}"
    string.gsub!(/ #{original_zip}\Z/,zip5)
  end

  address_to_lookup = string.gsub(/[^a-zA-Z\d\s,]/," ") # replace anything that is not alphanumeric, a space, or a comma, with a blank space.
  print "Geocoding: #{address_to_lookup}"
  geo_results = JSON.parse(RestClient.get("http://#{DSTK_HOST}/maps/api/geocode/json?sensor=false&address="+URI.encode(address_to_lookup)))
  if geo_results["status"] == "OK"
    print " ... found results\n"
    return {"provider" => "DSTK", "updated_at" => Time.now, "data" => geo_results["results"].first }
  else
    print " ... !! did not find results !!\n"
    return nil
  end
end
