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

def to_geojson_point(doc,keys_to_exclude = [])
  hash = doc.as_document.to_hash
  coordinates = [hash["geo"]["data"]["geometry"]["location"]["lng"],hash["geo"]["data"]["geometry"]["location"]["lat"]]
  keys_to_exclude.each{|k| hash.delete(k)}
  {"type" => "Feature", "id" => hash["_id"].to_s, "properties" => hash, "geometry" => {"type" => "Point", "coordinates" => coordinates}}
end

def ensure_proper_ccn_format(h)
  original_ccn = h["PROVIDER CCN"]
  zeros_to_add = ""
  if original_ccn.to_s.length < 6
    (6 - original_ccn.to_s.length).times {zeros_to_add += "0"} # Integer*"0" doesn't seem to work
  end
  h.update_attribute("PROVIDER CCN","#{zeros_to_add}#{original_ccn}")
end

def fetch_whole_socrata_dataset(endpoint, token, per_page = 1000)
  all_results = []
  page = 1
  request_url = "#{endpoint}?$limit=#{per_page}&$offset=#{per_page*page}"
  page_results = JSON.parse(RestClient.get(request_url), {"X-App-Token" => token})
  until page_results.empty?
    all_results = all_results + page_results
    puts "Added #{page_results.size} results from page #{page} for a total of #{all_results.size}"
    page = page + 1
    request_url = "#{endpoint}?$limit=#{per_page}&$offset=#{per_page*page}"
    page_results = JSON.parse(RestClient.get(request_url), {"X-App-Token" => SOCRATA_APP_TOKEN})
  end
  puts "Collected a total of #{all_results.size} records"
  return all_results
end
