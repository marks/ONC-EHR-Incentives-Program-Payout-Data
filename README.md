A repo for working with data from [ONC's EHR Incentive Programs Data and Program Reports page.](http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html) after a tweet from [@Cascadia](https://twitter.com/cascadia/status/307973508833615873) and subsequent chat through direct messages inspired me to do something with the data.

Screenshot
----------
![iPad (Landscape) Screenshot](public/screenshots/ipad-landscape-2013-03-04 at 9.19.43 PM.png "iPad (Landscape) Screenshot")
*Screenshot last updated 3/4/2013 at 9pm EST*

Notes
-----
* All files in this repo's `data` directory are from [ONC's EHR Incentive Programs Data and Program Reports page](http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html). They are included only for convenience to fellow developers looking to get up and running with a copy of the data.
* Using [Data Science Toolkit](http://www.datasciencetoolkit.org/) for geocoding provider addresses but started getting 500 Internal Server Errors when using public DSTK host so I brought up my own instance (m1.medium) on Amazon EC2. 


Procedure
---------
1. **New mongo collection for hospitals**
  1. Import CSV from ONC into MongoDB: `mongoimport --type csv -d onc -c ProvidersPaidByEHRProgram_June2013_EH --headerline --file public/data/ProvidersPaidByEHRProgram_June2013_EH.csv`
  2. Added 2d geospatial index: `mongo onc --eval "db.ProvidersPaidByEHRProgram_June2013_EH.ensureIndex({'geo.data.geometry.location':'2d'})"`
  3. Geocoded locations using `bundle exec rake geocode`
  4. Exported relevant information to CSV using `mongoexport --csv -d onc -c ProvidersPaidByEHRProgram_June2013_EH -o public/data/ProvidersPaidByEHRProgram_June2013_EH-geocoded.csv -f "PROVIDER NPI,PROVIDER CCN,PROVIDER - ORG NAME,PROVIDER STATE,PROVIDER CITY,PROVIDER  ADDRESS,PROVIDER ZIP 5 CD,PROVIDER ZIP 4 CD,PROVIDER PHONE NUM,PROVIDER PHONE EXT,PROGRAM YEAR 2011,PROGRAM YEAR 2012,geo.provider,geo.updated_at,geo.data.types.0,geo.data.geometry.location.lat,geo.data.geometry.location.lng,geo.data.formatted_address"`
  5. Bring in additional data from the General Hospital Information data set on Socrata: `bundle exec rake hospital_general_info:add_all_hospitals_with_general_info`
  6. Bring in additional data from the HCAHPS (Patient Experience) data set on Socrata: `bundle exec rake hcahps:ingest && bundle exec rake hcahps:add_all_hcahps_to_db`

2. **New mongo collection for eligible providers (~106,000 rows)**
  1. Import CSV from ONC into MongoDB: `mongoimport --type csv -d onc -c ProvidersPaidByEHRProgram_June2013_EP --headerline --file public/data/ProvidersPaidByEHRProgram_June2013_EP.csv`
  2. Added 2d geospatial index: `mongo onc --eval "db.ProvidersPaidByEHRProgram_June2013_EH.ensureIndex({'geo.data.geometry.location':'2d'})"`
  3. Geocoded locations using `bundle exec rake geocode`
  4. Exported relevant information to CSV using `mongoexport --csv -d onc -c ProvidersPaidByEHRProgram_June2013_EP -o public/data/ProvidersPaidByEHRProgram_June2013_EP-geocoded.csv -f "PROVIDER NPI,PROVIDER STATE,PROVIDER CITY,PROVIDER  ADDRESS,PROVIDER ZIP 5 CD,PROVIDER ZIP 4 CD,PROVIDER PHONE NUM,PROVIDER PHONE EXT,PROGRAM YEAR,geo.provider,geo.updated_at,geo.data.types.0,geo.data.geometry.location.lat,geo.data.geometry.location.lng,geo.data.formatted_address"`

Dump to local bson: `mongodump -d onc -c <collection>`
Restore to mongohq: `mongorestore -h <server>.mongohq.com --port XXXX -d XXXXX -u <user> -p <collection>.bson`
