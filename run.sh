#!/bin/bash

CONFIGURATION=$1
shift

INVENTORY=$1
shift

ansible-playbook main.yml --extra-vars "varsDirectory=${CONFIGURATION}/vars" -i ${CONFIGURATION}/hosts/${INVENTORY} "$@"