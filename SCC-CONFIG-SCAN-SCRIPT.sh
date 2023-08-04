##  Copyright 2023 Google LLC
##  
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##  
##      https://www.apache.org/licenses/LICENSE-2.0
##  
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.


##  This script checks your Google Cloud organization for the
##  implementation of the best practices for detecting cryptocurrency
##  mining (cryptomining) attacks.
##  Use this script to help check that your Google Cloud organization
##  meets the eligibility requirements for the Security Command Center
##  cryptomining protection program 


##  This script relies on the IAM privileges of the user or service 
##  account running it. IAM access or security controls (e.g., VPC-SC) 
##  may prevent you from getting detailed information on each project's 
##  evaluation status. Where applicable, the script output will 
##  state if it's unable to evaluate a project.


#!/bin/bash

# Update the working_proj with Project ID #
# The project should have essential API #
# working_proj="XXXXXXXXXX" 

now=`date +"%Y-%m-%d"`
compliance_state="not determined yet"
echo  "Cryptomining detection best practices report dated:${now}" > scc-report-${now}.txt
$(gcloud config set project $working_proj)
count=( $(gcloud projects get-ancestors $working_proj | awk 'END{print NR}') )
count="$(($count - 2))"
org_id=( $(gcloud projects get-ancestors $working_proj | awk '(NR > '$count')' | grep ID | awk '{print $2}') )
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> scc-report-${now}.txt
echo "Organization level SCC Configuration: $org_id"  >> scc-report-${now}.txt
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> scc-report-${now}.txt
if [[ $(gcloud organizations get-iam-policy $org_id --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:service-org-$org_id@security-center-api.iam.gserviceaccount.com" | awk '{print $2}' | grep securitycenter.controlServiceAgent ) ]]; then
        echo "SCC service account is ENABLED at org level and has securitycenter.controlServiceAgent role" >> scc-report-${now}.txt
        compliance_state="Compliant"
else
        echo "SCC service account does not have organization-level permissions or does not have the securitycenter.controlServiceAgent" >> scc-report-${now}.txt
        compliance_state="Non-Compliant"
fi

if [[ $(gcloud essential-contacts compute --notification-categories=security --organization=$org_id ) ]]; then
        echo "ESSENTIAL-CONTACTS for security is ENABLED for the organization" >> scc-report-${now}.txt
        if [[($compliance_state == "Compliant" )]]; then
                compliance_state="Compliant"
        else
                compliance_state="Non-Compliant"
        fi
else
        echo "ESSENTIAL-CONTACTS for security is DISABLED for the organization" >> scc-report-${now}.txt
        compliance_state="Non-Compliant"
fi

service=(
#    "container-threat-detection"
    "event-threat-detection"
    "virtual-machine-threat-detection"
)


for services in "${service[@]}"
do
    if [[ $(gcloud alpha scc settings services describe-explicit --service=$services  --organization=$org_id --quiet | grep 'ENABLED' ) ]]; then
        echo "${services^^} is ENABLED" >> scc-report-${now}.txt
        if [[($compliance_state == "Compliant" )]]; then
                compliance_state="Compliant"
        else
                compliance_state="Non-Compliant"
        fi
    else
        echo "${services^^} is DISABLED or Your access is denied" >> scc-report-${now}.txt
        compliance_state="Non-Compliant"
    fi
    #sleep 60
done
$(gcloud config unset project)

gcloud asset search-all-resources --asset-types=cloudresourcemanager.googleapis.com/Project --scope=organizations/$org_id --format="value(name)" | awk -F"/" '{print (NF>1)? $NF : ""}' | sort -u > proj-lst-cai.txt
gcloud projects list | grep PROJECT_ID | awk {'print $2'} |  sort -u > proj-lst.txt
projects=( $(comm -12 proj-lst-cai.txt proj-lst.txt) )


echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> scc-report-${now}.txt
if [[($compliance_state == "Compliant" )]]; then
        echo -e "Project level SCC Configuration"  >> scc-report-${now}.txt
#        projects=( $(gcloud projects list | grep PROJECT_ID | awk {'print $2'}) )
        for i in "${projects[@]}"
            do
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> scc-report-${now}.txt
                $(gcloud config set project $i)
                sleep 2
                echo "SCC Configuration for the project: $i" >> scc-report-${now}.txt
        ## Disabling Container Threat Detection check
                ## if [[ $(gcloud alpha scc settings services describe --service=container-threat-detection --project=$i --quiet | grep 'ENABLED' ) ]]; then
                ##     echo "CONTAINER-THREAT-DETECTION is ENABLED " >> scc-report-${now}.txt
                ##     if [[($compliance_state == "Compliant" )]]; then
                ##         compliance_state="Compliant"
                ##     else
                ##         compliance_state="Compliant contingent on the above projects"
                ##     fi                    
                ## else
                ##     echo "CONTAINER-THREAT-DETECTION is DISABLED or Your access is denied " >> scc-report-${now}.txt
                ##     compliance_state="Compliant contingent on the above projects"
                ## fi
        # # Project Level Event Threat Detection
                if [[ $(gcloud alpha scc settings services describe --service=event-threat-detection --project=$i --quiet | grep 'ENABLED' ) ]]; then
                    echo "EVENT-THREAT-DETECTION is ENABLED " >> scc-report-${now}.txt
                    if [[($compliance_state == "Compliant" )]]; then
                        compliance_state="Compliant"
                    else
                        compliance_state="Compliant contingent on the above projects"
                    fi
                else
                    echo "EVENT-THREAT-DETECTION is DISABLED or Your access is denied " >> scc-report-${now}.txt
                    compliance_state="Compliant contingent on the above projects"
                fi
        # # Project Level Virtual Machine Threat Detection
                if [[ $(gcloud alpha scc settings services describe --service=virtual-machine-threat-detection --project=$i --quiet | grep 'ENABLED' ) ]]; then
                    echo "VIRTUAL-MACHINE-THREAT-DETECTION is ENABLED " >> scc-report-${now}.txt
                    if [[($compliance_state == "Compliant" )]]; then
                        compliance_state="Compliant"
                    else
                        compliance_state="Compliant contingent on the above projects"
                    fi                    
                else
                    echo "VIRTUAL-MACHINE-THREAT-DETECTION is DISABLED or Your access is denied " >> scc-report-${now}.txt
                    compliance_state="Compliant contingent on the above projects"
                fi
                if [[ $(gcloud services list --enabled --filter="NAME:dns.googleapis.com" | grep dns) ]]; then
                    echo "DNS API is ENABLED "  >> scc-report-${now}.txt
                    if [[ $(gcloud dns policies list | grep LOGGING) ]]; then
                        echo "DNS logging is ENABLED "  >> scc-report-${now}.txt
                        if [[($compliance_state == "Compliant" )]]; then
                            compliance_state="Compliant"
                        else
                            compliance_state="Compliant contingent on the above projects"
                        fi
                    else
                        echo "DNS logging is DISABLED "  >> scc-report-${now}.txt
                        compliance_state="Compliant contingent on the above projects"
                    fi         
                else
                    echo "DNS API is DISABLED "  >> scc-report-${now}.txt
                    echo "DNS logging is DISABLED "  >> scc-report-${now}.txt
                    compliance_state="Compliant contingent on the above projects"
                fi 
            done
        $(gcloud config unset project)
fi
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> scc-report-${now}.txt
echo "Your organization id ($org_id) is $compliance_state" >> scc-report-${now}.txt
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> scc-report-${now}.txt
echo -e "Integrate SCC with your existing security operations tools (e.g., SIEM, SOAR) to respond to \nand triage security findings that indicate the potential or presence of cryptomining attacks. \nFor more information, please visit \nhttps://cloud.google.com/security-command-center/docs/cryptomining-detection-best-practices#integrate-seim-soar-with-scc" >> scc-report-${now}.txt
echo -e "Consider enabling SCC premium at the organization level as it's generally more cost effective \nthan enabling SCC premium on all projects individually." >> scc-report-${now}.txt
