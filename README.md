# SCC cryptomining detection best practices validation script

This script checks metadata in your Google Cloud environment to see if the best practices for detecting cryptocurrency mining (cryptomining) attacks are implemented in the environment.

The correct and complete implementation of these best practices helps to ensure that your organization meets the requirements of the Security Command Center Cryptomining Protection Program, which may provide credits of up to $1,000,000 USD for Google Cloud Compute Engine costs that are attributed to an undetected cryptomining attack.



## How to run the script?

The following steps should be executed in your organization in Cloud Shell in the Google Cloud Console.


## Get the bash script
Clone this github repository go get the script.

``` 
git clone https://github.com/GCP-Architecture-Guides/SCC-Cryptomining-Detection.git

```


## Prerequisites

You need the following Identity and Access Management (IAM) permissions to run this script in your Google Cloud environment.

``` 
To Be Updated
```


## Run the SCC config script

From the root folder, run the following commands:

``` 
git clone https://github.com/GCP-Architecture-Guides/SCC-cryptomining-detection.git
cd SCC-Cryptomining-Detection
export working_proj="YOUR-PROJECT-ID"
sh SCC-CONFIG-SCAN-SCRIPT.sh
```

Note: The project id can be updated within the script file. The project should have Essential Contact API enabled.


## Output Report

The script exports a report that outlines the organization level configuration as well as project level configuration. 
