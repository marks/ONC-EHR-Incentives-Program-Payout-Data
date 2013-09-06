def cleanup_string(string) # replace anything that is not alphanumeric, a space, or a comma, with a blank space.
  string.gsub(/[^a-zA-Z\d\s,]/," ")
end

def dstk_geocode(string)
  address_to_lookup = cleanup_string(string)
  print "Geocoding: #{address_to_lookup}"
  geo_results = JSON.parse(RestClient.get("http://#{settings.dstk_host}/maps/api/geocode/json?sensor=false&address="+URI.encode(address_to_lookup)))
  if geo_results["status"] == "OK"
    if geo_results["results"].first["geometry"]["location"]["lng"].to_i >= -45
      print " ... This doesn't look like a U.S.A. location... let's try again later\n"
    else
      print " ... found results\n"
      return {"_source" => "DSTK", "_updated_at" => Time.now}.merge(geo_results["results"].first)
    end
  else
    print " ... !! did not find results !!\n"
    return nil
  end
end

def to_geojson_point(doc,keys_to_exclude = [])
  hash = doc.as_document.to_hash
  hash["has_hcahps"] = true unless hash["hcahps"].nil?
  coordinates = [hash["geo"]["geometry"]["location"]["lng"],hash["geo"]["geometry"]["location"]["lat"]]
  keys_to_exclude.each{|k| hash.delete(k)}
  {"type" => "Feature", "id" => hash["_id"].to_s, "properties" => hash, "geometry" => {"type" => "Point", "coordinates" => coordinates}}
end

def add_leading_zeros(original,n,zeros_to_add = "")
  n = n.to_i 
  if original.to_s.length < n
    (n - original.to_s.length).times {zeros_to_add += "0"} # Integer*"0" doesn't seem to work
  end
  return "#{zeros_to_add}#{original}"
end

def format_ccn(ccn)
  zeros_to_add = ""
  if ccn.to_s.length < 6
    (6 - ccn.to_s.length).times {zeros_to_add += "0"} # Integer*"0" doesn't seem to work
  end
  "#{zeros_to_add}#{ccn}"
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
