# Salesforce Managed Package Update Agent Prompt

## Overview
This prompt will guide you to update a set of Salesforce managed packages in an `sfdx-project.json` file based on the latest package information from the provided CSV data. You will match packages by their subscriber ID and update only existing packages with new version information. Additionally, you will generate a markdown summary of all updates made.

## Input Files
1. **sfdx-project.json** - Contains the current package configurations in the `plugins.dependencies` array
2. **CSV file with package information** - Contains the updated package information

### CSV File Selection
Since the CSV file name changes monthly, you should determine which file to use based on one of the following methods (in order of priority):

1. **Command Line Argument**: If a specific CSV filename is provided as an argument when running the agent, use that file
2. **Pattern Matching**: Look for the most recent file matching the pattern `PackageManager__Release_Version__*.csv` in the repository root
3. **User Input**: If multiple matching files are found and no argument was provided, prompt the user to select which CSV file to use

## Field Mapping
Update the following fields in the JSON using these mappings:

| JSON Key | CSV Field |
|----------|-----------|
| name | PackageManager__Package_Version__r.PackageManager__Full_Name__c |
| namespace | PackageManager__Package_Version__r.PackageManager__Package__r.PackageManager__Namespace_Prefix__c |
| subscriberPackageId | PackageManager__Package_Version__r.PackageManager__Package__r.PackageManager__Metadata_Package_Id__c |
| packageGeneration | PackageManager__Package_Version__r.PackageManager__Package_Generation__c |
| password | PackageManager__Package_Version__r.PackageManager__Password__c |
| version | PackageManager__Package_Version__r.Name |
| metadataPackageVersionId | PackageManager__Package_Version__r.PackageManager__Metadata_Package_Version_Id__c |

## Instructions

1. Identify and read the appropriate CSV file using the selection method described above
2. Read the `sfdx-project.json` file
2. For each package in the `plugins.dependencies` array of the JSON file:
   - Extract the `subscriberPackageId` value
   - Find a matching record in the CSV where `PackageManager__Package_Version__r.PackageManager__Package__r.PackageManager__Metadata_Package_Id__c` equals the `subscriberPackageId`
   - If a match is found, update the following fields in the JSON package object:
     - name
     - namespace
     - packageGeneration
     - password
     - version
     - metadataPackageVersionId
   - Keep all other fields (like `enableFirstTimeInstall`) unchanged
   - Track the package name, previous version, and new version for the summary report
3. If no match is found for a package, leave it unchanged
4. Do not add any new packages - only update existing ones
5. Preserve the structure and order of the JSON file
6. Ensure proper JSON formatting in the output

## Example Entry (Before/After)

**Before:**
```json
{
  "name": "nDESIGN",
  "namespace": "nDESIGN",
  "subscriberPackageId": "033d00000009kZj",
  "packageGeneration": "1GP",
  "password": "73RtzMqB2EMkcMR1",
  "version": "2.52",
  "metadataPackageVersionId": "04t6T000001lWL7QAM",
  "enableFirstTimeInstall": true
}
```

**After (if updated data is found):**
```json
{
  "name": "nDESIGN",
  "namespace": "nDESIGN",
  "subscriberPackageId": "033d00000009kZj",
  "packageGeneration": "1GP",
  "password": "NewPasswordFromCSV",
  "version": "2.60",
  "metadataPackageVersionId": "NewMetadataPackageVersionIdFromCSV",
  "enableFirstTimeInstall": true
}
```

## Generate Summary Report

Generate a markdown file named `package_update_summary.md` that provides a summary of all updates made. The summary should include:

1. A timestamp of when the update was executed
2. Total number of packages in the sfdx-project.json file
3. Number of packages that were updated
4. A table with the following columns:
   - Package Name
   - Previous Version
   - New Version
   - Status (Updated/Not Updated)

Only include packages that were found in the CSV in the detailed table. For packages that were not found in the CSV, list them in a separate section as "Packages Not Updated".

## Example Summary Report

```markdown
# Salesforce Managed Package Update Summary
**Date**: April 8, 2025
**Time**: 14:30:00 UTC
**Source file**: PackageManager__Release_Version__c4_8_2025.csv

## Overview
- Total packages in sfdx-project.json: 30
- Packages updated: 25
- Packages not updated: 5

## Updated Packages

| Package Name | Previous Version | New Version | Status |
|-------------|-----------------|------------|--------|
| nDESIGN     | 2.52            | 2.60       | Updated |
| nFORCE      | 2.2940          | 2.2950     | Updated |
| LLC_BI      | 2.3775          | 2.3789     | Updated |
| ...         | ...             | ...        | ...    |

## Packages Not Updated
The following packages were not found in the provided CSV:
- Package Name 1
- Package Name 2
- ...
```

## Output
1. The complete updated `sfdx-project.json` file with all necessary changes applied
2. A `package_update_summary.md` file with the summary of all updates as specified above
3. Include the name of the CSV file that was used for the update in the summary report