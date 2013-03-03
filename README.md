A repo for working with data from [ONC's EHR Incentive Programs Data and Program Reports page.](http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html) after a tweet from [@Cascadia](https://twitter.com/cascadia/status/307973508833615873) and subsequent chat through direct messages inspired me to do something with the data.

Notes
-----
* All files in this repo's `data` directory are from [ONC's EHR Incentive Programs Data and Program Reports page.](http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html). They are included only for convenience to fellow developers looking to get up and running with a copy of the data.
* Using [Data Science Toolkit](http://www.datasciencetoolkit.org/) for geocoding provider addresses but started getting 500 Internal Server Errors when using public DSTK host so I brought up my own instance (m1.medium) on Amazon EC2. 


Procedure
---------
1. New mongo collection for hospitals
  1. Import CSV from ONC into MongoDB: `mongoimport --type csv -d onc -c ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL --headerline --file data/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.csv`
  2. Added 2d geospatial index: `mongo onc --eval "db.ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.ensureIndex({'geo.data.geometry.location':'2d'})"`

2. New mongo collection for eligible providers
  1. Import CSV from ONC into MongoDB: `mongoimport --type csv -d onc -c ProvidersPaidByEHRProgram_Dec2012_EP_FINAL --headerline --file data/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.csv`
  2. Added 2d geospatial index: `mongo onc --eval "db.ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.ensureIndex({'geo.data.geometry.location':'2d'})"`
