#!/usr/bin/env bash
#########################################################
## Azure Connect
#########################################################

CACHE_DIR="${CACHE_DIR:-${HOME}/run}"
mkdir -p "${CACHE_DIR}"

########################################################################
## _connect $ip
##
## Attempt to get the user connected to the ip passed in as an arg
########################################################################
function _connect() {
  local ip="$1"
  echo "Connecting to ${1}"
  for user in admiral ubuntu captain; do
    if ssh "${user}@${ip}" echo 2> /dev/null; then
      ssh "${user}@${ip}"
      break
    fi
  done
}

########################################################################
## _azLoginCheck
##
## Verify the user is logged in and punt if not
########################################################################
function _azLoginCheck() {
  echo -n "Confirming you are logged into az cli..."
  az group list \
    1> /dev/null \
    2> /dev/null

  if [ $? -ne 0 ]; then
    echo "
    You probably need to refresh your login with the az cli

    Try running:

    az login
    "
    exit 1
  fi
  echo "Done"
}


########################################################################
## (a)zure (c)onnect (r)eset (c)ache
##
## Usage:
##   acrc
##
## Runs through all of your subscriptions using the az cli
## and caches ip addresses and subscription ids
########################################################################
CACHE_FILE_SUBSCRIPTIONS="${CACHE_DIR}/az-cache-subscriptions"
function acrc() {

  _azLoginCheck

  az account list \
    1> "${CACHE_FILE_SUBSCRIPTIONS}" \
    2> /dev/null

  echo -n "Caching all the vm data..."
  for subscription_id in $(jq -r '.[].id' "${CACHE_FILE_SUBSCRIPTIONS}")
  do
    CACHE_FILE_IPS="${CACHE_DIR}/az-cache-vms-${subscription_id}"
    az vm list-ip-addresses --subscription "${subscription_id}" > "${CACHE_FILE_IPS}"
  done
  echo "Done"

}

########################################################################
## (a)zure (c)onnect
##
## Usage:
##   ac [$search]
##
## Searches the cache for machine/resource group names and
## then connects to the selected one.  The search is optional.
## If the search results in more than one machine, you can select
## from a list of the remaining results.  The search is a fuzzy
## match
########################################################################
function ac() {
  local search="$1"
  local machines=""

  # In case we haven't run the cache before
  [ ! -f "${CACHE_FILE_SUBSCRIPTIONS}" ] && acrc
  for ip_file in $(find "${HOME}/run" -type f -name "az-cache-vms*")
  do
    rg_name_ip=$(jq -r '.[].virtualMachine | (.resourceGroup+"|"+.name+"|"+.network.privateIpAddresses[0])' "${ip_file}")
    machines="${machines}${rg_name_ip}\n"
  done
  machine=$(echo "${machines}" | tr '[:upper:]' '[:lower:]' | grep -i "${search}")
  count=$(echo "${machine}" | wc -l)
  if [ "${count}" -gt 1 ]; then
    select machine in $(echo "${machine}"); do
      [ -n "${machine}" ] && break
    done
  fi
  echo "Selected: ${machine}"
  _connect $(echo "${machine}" | cut -f3 -d'|' )
}
