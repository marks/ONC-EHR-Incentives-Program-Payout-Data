A repo for working with data from http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html after a tweet from [@Cascadia](https://twitter.com/cascadia/status/307973508833615873) and subsequent chat through direct messages inspired me to do something with the data.

Eligible Professional Public Use File
-------------------------------------
Search for and download [EP Recipients of Medicare EHR Incentive Program Payments](http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/Downloads/EP_ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.zip) from [ONC's EHR Incentive Programs Data and Program Reports page.](http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html)

Used to import CSV from ONC into local MongoDB: `mongoimport --type csv -d onc -c paid_by_ehr_program --headerline --file data/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.csv`

Notes
-----
* Using [Data Science Toolkit](http://www.datasciencetoolkit.org/) for geocoding provider addresses but started getting 500 Internal Server Errors when using public DSTK host so I brought up my own instance (m1.medium) on Amazon EC2. 
