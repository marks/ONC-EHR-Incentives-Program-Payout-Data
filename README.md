A repo for working with data from http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html after a tweet from @Cascadia (https://twitter.com/cascadia/status/307973508833615873) and subsequent chat through direct messages inspired me to do something with the data.

Eligible Professional Public Use File
-------------------------------------
Search for and download "Eligible Professional Public Use File" from http://www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html

Used to import CSV from ONC into local MongoDB: `mongoimport --type csv -d onc -c paid_by_ehr_program --headerline --file data/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.csv`
