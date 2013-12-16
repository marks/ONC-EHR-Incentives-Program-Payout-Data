# This file contains manual fixes to 9/2013 EP data.
# Often the issue is the incorrect zip code or state is entered which throws geocoders off.

# Alabama
Provider.find_by(:"PROVIDER NPI" => 1023087723).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "35801"})

# Arizona
Provider.find_by(:"PROVIDER NPI" => 1942303565).update_attributes(:geo => {"geometry" => {"location" => {"lng" => -112.17659, "lat" => 33.624556}}})

# Arkansas
Provider.find_by(:"PROVIDER NPI" => 1427010735).update_attributes(:geo => nil, "PROVIDER STATE" => "Illinois")

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
Provider.find_by(:"PROVIDER NPI" => 1750452652).update_attributes(:geo => nil, "PROVIDER STATE" => "Orgeon")
Provider.find_by(:"PROVIDER NPI" => 1336226067).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "92881"})
Provider.find_by(:"PROVIDER NPI" => 1740285485).update_attributes({:geo => nil, "PROVIDER ZIP 5 CD" => "90815"})




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
Provider.find_by(:"PROVIDER NPI" => 1487775813).update_attributes(:geo => nil, "PROVIDER STATE" => "South Carolina")

# Michigan
Provider.find_by(:"PROVIDER NPI" => 1851452403).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "49866")
Provider.find_by(:"PROVIDER NPI" => 1578722757).update_attributes(:geo => nil, "PROVIDER STATE" => "Texas")
Provider.find_by(:"PROVIDER NPI" => 1144200650).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "48162")

# Minnesota
Provider.find_by(:"PROVIDER NPI" => 1538156799).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "56007")

# Missouri
Provider.find_by(:"PROVIDER NPI" => 1689611337).update_attributes(:geo => nil, "PROVIDER STATE" => "California")
Provider.find_by(:"PROVIDER NPI" => 1689614794).update_attributes(:geo => nil, "PROVIDER STATE" => "Minnesota")

# Nevada
Provider.find_by(:"PROVIDER NPI" => 1679605265).update_attributes(:geo => nil, "PROVIDER STATE" => "Colorado")
Provider.find_by(:"PROVIDER NPI" => 1174629083).update_attributes(:geo => nil, "PROVIDER STATE" => "New Jersey")

# New Jersey
Provider.find_by(:"PROVIDER NPI" => 1538156799).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "08822")

# New York
Provider.find_by(:"PROVIDER NPI" => 1215913371).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "13304")
Provider.find_by(:"PROVIDER NPI" => 1992805261).update_attributes(:geo => nil, "PROVIDER STATE" => "Florida")

# North Carolina
Provider.find_by(:"PROVIDER NPI" => 1154543692).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "28112")
Provider.find_by(:"PROVIDER NPI" => 1225125669).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "28345")

# North Dakota
Provider.find_by(:"PROVIDER NPI" => 1003994286).update_attributes(:geo => nil, "PROVIDER STATE" => "North Carolina")

# Ohio
Provider.find_by(:"PROVIDER NPI" => 1417191529).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "43324")
Provider.find_by(:"PROVIDER NPI" => 1164593026).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "97239")

# Oregon
Provider.find_by(:"PROVIDER NPI" => 1851468466).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "99722")
Provider.find_by(:"PROVIDER NPI" => 1427031301).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "97306")
Provider.find_by(:"PROVIDER NPI" => 1851468466).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "97225")


# Pennsylvania
Provider.find_by(:"PROVIDER NPI" => 1124230305).update_attributes(:geo => nil, "PROVIDER STATE" => "Georgia")

# South Carolina
Provider.find_by(:"PROVIDER NPI" => 1093710121).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "29615")
Provider.find_by(:"PROVIDER NPI" => 1073569752).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "29150")

# South Dakota
Provider.find_by(:"PROVIDER NPI" => 1316987209).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "57701")

# Tennesee
Provider.find_by(:"PROVIDER NPI" => 1073564902).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "37813")
Provider.find_by(:"PROVIDER NPI" => 1033115373).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "38555")
Provider.find_by(:"PROVIDER NPI" => 1063504108).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "37421")

# Texas
Provider.find_by(:"PROVIDER NPI" => 1992765655).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "75390")
Provider.find_by(:"PROVIDER NPI" => 1700195138).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "77030")
Provider.find_by(:"PROVIDER NPI" => 1992765655).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "75390")

# Utah
Provider.find_by(:"PROVIDER NPI" => 1790991107).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "84790")

# Virginia
Provider.find_by(:"PROVIDER NPI" => 1588873640).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "23226")
Provider.find_by(:"PROVIDER NPI" => 1801950118).update_attributes(:geo => nil, "PROVIDER STATE" => "Vermont")
Provider.find_by(:"PROVIDER NPI" => 1003817552).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "22801")
Provider.find_by(:"PROVIDER NPI" => 1053643627).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "22801")

# West Virginia
Provider.find_by(:"PROVIDER NPI" => 1043270408).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "26101")

# Wisconsin
Provider.find_by(:"PROVIDER NPI" => 1982665311).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "54601")
Provider.find_by(:"PROVIDER NPI" => 1871689042).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "54449")
Provider.find_by(:"PROVIDER NPI" => 1225071624).update_attributes(:geo => nil, "PROVIDER STATE" => "Seattle")
Provider.find_by(:"PROVIDER NPI" => 1699768259).update_attributes(:geo => nil, "PROVIDER ZIP 5 CD" => "53081")

# ... and then re-geocode (`bundle exec rake geocode`)
