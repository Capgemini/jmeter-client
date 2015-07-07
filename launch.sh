#!/bin/bash

set -e

CONSUL_TEMPLATE="/usr/local/bin/consul-template"
JMETER="/opt/jmeter/apache-jmeter-$JMETER_VERSION/bin/jmeter"

# Usage example.
function usage() {
  echo "Usage: $0 [-t jmx-script] [-l log-dir]" 1>&2; exit 1;
}

# Validate enviroment
function validate_env() {
    if [[ ! -f ${CONSUL_TEMPLATE} ]] ; then
      echo "- Consul template must be installed"
      exit 1
    fi
    if [[ ! -f ${JMETER} ]] ; then
      echo "- JMeter must be installed"
      exit 1
    fi
}

# Check correct arguemnts passed to script.
function check_args() {
  if [ -z "${SCRIPT_PATH}" ] || [ -z "${LOG_DIR}" ]; then
    usage
  fi
}

# Update JMeter config using consul template.
function jmeter_update_config() {
  echo "Attempting to update JMeter config file..."

  ${CONSUL_TEMPLATE}  -config /consul-template/config.d \
                      -log-level info \
                      -consul consul.service.consul:8500 \
                      -once
  err=$?

  if [[ ${err} -ne 0 ]] ; then
    echo "Error '${err}' while trying to update JMeter config using Consul template"
    exit ${err}
  fi
  
  echo "JMeter config updated!"
}

# Start JMeter tests
function jmeter_start_tests() {
  echo "Starting JMeter tests..."
  ${JMETER} -n -t ${SCRIPT_PATH} -r -l ${LOG_DIR}/test.jtl -j ${LOG_DIR}/jmeter.log
}

function run() {
  validate_env
  check_args
  jmeter_update_config
  jmeter_start_tests
}

while getopts :t:l: opt
do
  case ${opt} in
    t) SCRIPT_PATH=${OPTARG} ;;
    l) LOG_DIR=${OPTARG} ;;
    :) echo "The -${OPTARG} option requires a parameter"
       exit 1 ;;
    ?) echo "Invalid option: -${OPTARG}"
       exit 1 ;;
  esac
done
shift $((OPTIND -1))

run
