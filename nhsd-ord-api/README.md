# Using the NHS Digital ODS API

Results are returned in JSON format by default, to neatly format this when retrieved using **curl** pipe like this: `curl https://directory.spineservices.nhs.uk/ORD/2-0-0/roles | json_pp -json_opt pretty,canonical`

## Return all NHS Trusts

<https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations?PrimaryRoleId=RO197&Limit=1000>

## Return all organisation role IDs

<https://directory.spineservices.nhs.uk/ORD/2-0-0/roles>

## Official documentation

<https://digital.nhs.uk/developer/api-catalogue/organisation-data-service-ord>
