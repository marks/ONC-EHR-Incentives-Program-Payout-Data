def cleanup_string(string) # replace anything that is not alphanumeric, a space, or a comma, with a blank space.
  string.gsub(/[^a-zA-Z\d\s,]/," ")
end

def dstk_geocode(string)
  # mongoimport drops leading "0" in zip codes; we need to geocode with the leading "0" though
  original_zip = string.split(" ").last
  if original_zip.to_s.length < 5
    zeros_to_add = ""
    (5 - original_zip.to_s.length).times {zeros_to_add += "0"} # Integer*"0" doesn't seem to work
    zip5 = " #{zeros_to_add}#{original_zip}"
    string.gsub!(/ #{original_zip}\Z/,zip5)
  end

  address_to_lookup = cleanup_string(string)
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

def to_geojson_point(doc)
  hash = doc.as_document.to_hash
  coordinates = [hash["geo"]["data"]["geometry"]["location"]["lng"],hash["geo"]["data"]["geometry"]["location"]["lat"]]
  hash.delete("geo")  # do not want to transmit hash["geo"] as part of properties hash
  {"type" => "Feature", "id" => hash["_id"].to_s, "properties" => hash, "geometry" => {"type" => "Point", "coordinates" => coordinates}}
end

def ensure_proper_ccn_format(h)
  original_ccn = h["PROVIDER CCN"]
  if original_ccn.to_s.length < 6
    zeros_to_add = ""
    (6 - original_ccn.to_s.length).times {zeros_to_add += "0"} # Integer*"0" doesn't seem to work
    h.update_attribute("PROVIDER CCN","#{zeros_to_add}#{original_ccn}")
  end
end
