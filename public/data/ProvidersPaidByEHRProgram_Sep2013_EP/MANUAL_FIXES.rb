# This file contains manual fixes to 9/2013 EP data.
# Often the issue is the incorrect zip code or state is entered which throws geocoders off.

# Alabama
Provider.find_by(:"PROVIDER NPI" => 1023087723).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "35801"})

# Arizona
Provider.find_by(:"PROVIDER NPI" => 1942303565).update_attributes(:geo => {"geometry" => {"location" => {"lng" => -112.17659, "lat" => 33.624556}}})

# Arkansas
# Sole outlier is http://www.bloomapi.com/search#/npis/1427010735 which does not seem to be in Arkansas anymore anyway

# California
Provider.find_by(:"PROVIDER NPI" => 1053571828).update_attributes(:geo => nil, "PROVIDER STATE" => "Maine")
Provider.find_by(:"PROVIDER NPI" => 1821281866).update_attributes(:geo => nil, "PROVIDER STATE" => "Connecticut")
Provider.find_by(:"PROVIDER NPI" => 1396941852).update_attributes(:geo => nil, "PROVIDER STATE" => "New Jersey")
Provider.find_by(:"PROVIDER NPI" => 1700925211).update_attributes(:geo => nil, "PROVIDER STATE" => "Illinois")
Provider.find_by(:"PROVIDER NPI" => 1114183464).update_attributes(:geo => nil, "PROVIDER STATE" => "Florida")
Provider.find_by(:"PROVIDER NPI" => 1538245279).update_attributes(:geo => nil, "PROVIDER STATE" => "Nebraska")
Provider.find_by(:"PROVIDER NPI" => 1710086533).update_attributes(:geo => nil, "PROVIDER STATE" => "Kansas")
Provider.find_by(:"PROVIDER NPI" => 1972763878).update_attributes(:geo => nil, "PROVIDER STATE" => "Louisiana")
Provider.find_by(:"PROVIDER NPI" => 1740424480).update_attributes(:geo => nil, "PROVIDER STATE" => "Texas")
Provider.find_by(:"PROVIDER NPI" => 1629195508).update_attributes(:geo => nil, "PROVIDER STATE" => "Washington")
Provider.find_by(:"PROVIDER NPI" => 1316916125).update_attributes(:geo => nil, "PROVIDER STATE" => "Arizona")

# Colorado
Provider.find_by(:"PROVIDER NPI" => 1699878959).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "80534"})
Provider.find_by(:"PROVIDER NPI" => 1366601700).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "80534"})
Provider.find_by(:"PROVIDER NPI" => 1073502027).update_attributes({:geo => nil, "PROVIDER STATE" => "Texas"})
Provider.find_by(:"PROVIDER NPI" => 1295737526).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "80528"})

# Connecticut
Provider.find_by(:"PROVIDER NPI" => 1013174697).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "06831"})
Provider.find_by(:"PROVIDER NPI" => 1811096670).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "06033"})
Provider.find_by(:"PROVIDER NPI" => 1841466042).update_attributes({:geo => nil, "PROVIDER STATE" => "New York"})

# Delaware
Provider.find_by(:"PROVIDER NPI" => 1023074796).update_attributes({:geo => nil, "PROVIDER STATE" => "Connecticut"})
Provider.find_by(:"PROVIDER NPI" => 1629070370).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "19806"})

# Florida
Provider.find_by(:"PROVIDER NPI" => 1396726162).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "34232"})
Provider.find_by(:"PROVIDER NPI" => 1801904347).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "33617"})

# Idaho
Provider.find_by(:"PROVIDER NPI" => 1417066911).update_attributes(:geo => nil, "PROVIDER STATE" => "Illinois")

# Illinois
Provider.find_by(:"PROVIDER NPI" => 1003806514).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "61801"})
Provider.find_by(:"PROVIDER NPI" => 1750491288).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "60617"})
Provider.find_by(:"PROVIDER NPI" => 1316971153).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "61801"})
Provider.find_by(:"PROVIDER NPI" => 1184624249).update_attributes(:geo => nil, "PROVIDER STATE" => "Indiana")
Provider.find_by(:"PROVIDER NPI" => 1184624249).update_attributes(:geo => nil, "PROVIDER STATE" => "Indiana")
Provider.find_by(:"PROVIDER NPI" => 1184610875).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "60689")
Provider.find_by(:"PROVIDER NPI" => 1144206301).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "60101")

# Indiana
Provider.find_by(:"PROVIDER NPI" => 1366556300).update_attributes(:geo => nil, "PROVIDER STATE" => "Arizona")
Provider.find_by(:"PROVIDER NPI" => 1164445433).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "46514")

# Iowa
Provider.find_by(:"PROVIDER NPI" => 1457518532).update_attributes(:geo => nil, "PROVIDER STATE" => "Wisconsin")
Provider.find_by(:"PROVIDER NPI" => 1851500995).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "52401")

# Kansas
Provider.find_by(:"PROVIDER NPI" => 1932167574).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "66211")
Provider.find_by(:"PROVIDER NPI" => 1982613261).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "66103")
Provider.find_by(:"PROVIDER NPI" => 1003956038).update_attributes(:geo => nil, "PROVIDER STATE" => "Kentucky")

# Louisiana
Provider.find_by(:"PROVIDER NPI" => 1073714358).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "70121")

# Maryland
Provider.find_by(:"PROVIDER NPI" => 1831126572).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "21045")

# Massachusetts
Provider.find_by(:"PROVIDER NPI" => 1508035841).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "02445")
Provider.find_by(:"PROVIDER NPI" => 1326120247).update_attributes(:geo => nil, "PROVIDER STATE" => "Michigan")
Provider.find_by(:"PROVIDER NPI" => 1255428025).update_attributes(:geo => nil, "PROVIDER STATE" => "Michigan")



