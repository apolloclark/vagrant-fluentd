#!/bin/bash -ex

# get the REDHAT variables
REDHAT_USER=${1:-}
if [[ -z "$REDHAT_USER" ]]; then
    echo "ERROR: Missing <REDHAT_USER>"
    echo "usage: $0 <REDHAT_USER> <REDHAT_PASS>"
    exit 1
fi

REDHAT_PASS=${2:-}
if [[ -z "$REDHAT_PASS" ]]; then
    echo "ERROR: Missing <REDHAT_PASS>"
    echo "usage: $0 <REDHAT_USER>  <REDHAT_PASS>"
    exit 1
fi

echo "REDHAT_USER = $REDHAT_USER";
echo "REDHAT_PASS = $REDHAT_PASS";

# register with Redhat
subscription-manager register --username "$REDHAT_USER" --password "$REDHAT_PASS"

# register with self-serve virtual subscription
subscription-manager subscribe --pool=8a85f98c615810120161582177020497

# apply security updates
yum update-minimal --security -y -e 0

# install basic tools
yum install -y -q -e 0 nano git net-tools policycoreutils-python
