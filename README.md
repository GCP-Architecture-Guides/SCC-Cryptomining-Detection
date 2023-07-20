# SCC Cryptomining Detection Program 

Google provides Security Command Center Premium customers with financial protection to defray the Compute Engine VM costs related to undetected and unauthorized cryptomining attacks in their Compute Engine VM environment.


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
sh SCC-CONFIG-SCAN-SCRIPT.sh
```

Note: The project id can be updated within the script file. The project should have Essential Contact API enabled.


## Output Report

The script exports a report that outlines the organization level configuration as well as project level configuration. 
