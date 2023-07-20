# SCC Cryptomining Detection Program 

Google Cloud will offer to eligible Security Command Center (SCC) Premium customers financial protection to defray the costs of undetected cryptomining attacks in their Google Cloud environment.


## How to run the script?

The following steps should be executed in Cloud Shell in the Google Cloud Console. 


## Get the bash script
Clone this github repository go get the script.

``` 
git clone https://github.com/GCP-Architecture-Guides/SCC-Cryptomining-Detection.git

```


## Run the SCC config script

From the root folder, run the following commands:

``` 
git clone https://github.com/GCP-Architecture-Guides/SCC-Cryptomining-Detection.git
cd SCC-Cryptomining-Detection
export working_proj="YOUR-PROJECT-ID"
sh SCC-Config-SCAN-SCRIPT.sh
```

Note: The project id can be updated within the script file. The project should have Essential Contact API enabled.


## Output Report

The script exports a report that outlines the organization level configuration as well as project level configuration. 
