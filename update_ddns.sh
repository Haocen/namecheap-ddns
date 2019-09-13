#!/bin/bash

# Go to NameCheap dashboard and enable DYNAMIC DNS
#
# https://ap.www.namecheap.com/Domains/DomainControlPanel/example.com/advancedns
# Be aware that Dynamic DNS Password is NOT account password
# Only DNS records created as A + Dynamic DNS Record can be updated
# 
 
domain="$DOMAIN"		# your domain
host="$HOST"   # your host, use '@' to represent root host
password="$PASSWORD"		# can be found as Dynamic DNS Password after enabling DYNAMIC DNS in dashboard
ip_detector_endpoint="$IP_DETECTOR_ENDPOINT"		# any public ip echo service endpoint that returns JSON or IP in a string, leave empty to rely on namecheap automatically detecting request orign IP
debug="true"

if [[ "${DEBUG,,}" == "false" || "${DEBUG,,}" == "no" ]]; then
	debug=""
fi

if [[ -z "$ip_detector_endpoint" || "${ip_detector_endpoint,,}" == "false" || "${ip_detector_endpoint,,}" == "no" ]]; then
	echo "Updating DNS record for hostname: $host.$domain with remote detected origin IP"
else
  ip_detector_endpoint_response=$(curl -s GET "$ip_detector_endpoint")
	detected_ip=$(echo $ip_detector_endpoint_response | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

	if [ -z "$detected_ip" ]; then
		echo "Cannot parse detected IP"
		exit 1
	fi

	optional_ip_parameter="&ip=${detected_ip}"
	echo "Updating DNS record for hostname: $host.$domain with IP: $detected_ip"
	
fi

update_dns_record_result=$(curl -s -X GET \
	"https://dynamicdns.park-your-domain.com/update?domain=${domain}&password=${password}&host=${host}${optional_ip_parameter}")

if [ $? -eq 0 ]; then
	updated_ip=$(echo $update_dns_record_result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
	if [[ -z "$ip_detector_endpoint" || "${ip_detector_endpoint,,}" == "false" || "${ip_detector_endpoint,,}" == "no" ]]; then
	  echo "Successfully updated DNS record to ${updated_ip}"
	else
		if [ "$detected_ip" != "$updated_ip" ]; then
			echo "Failed to update DNS record, remote replied with IP: ${updated_ip} but expected to be updated with IP: ${detected_ip}"
		else
			echo "Successfully updated DNS record to ${updated_ip}"
		fi
	fi
else
	echo "Failed to update DNS record"
	echo "You may set DEBUG to true for debugging"
	echo "Update response:"
	echo $update_dns_record_result
fi

if [ ! -z "$debug" ]; then
	echo "Update response:"
	echo $update_dns_record_result
fi
