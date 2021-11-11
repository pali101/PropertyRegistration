#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${ORGMSP}/$6/" \
        ccp-template.json
}

ORG=admin
P0PORT=7051
CAPORT=7054
PEERPEM=../organizations/peerOrganizations/property.com/admin.property.com/tlsca/tls-localhost-7054-ca-admin.pem
CAPEM=../organizations/peerOrganizations/property.com/admin.property.com/ca/localhost-7054-ca-admin.pem
ORGMSP=admin

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGMSP)" > gateways/connection-admin.json

ORG=user
P0PORT=9051
CAPORT=8054
PEERPEM=../organizations/peerOrganizations/property.com/user.property.com/tlsca/tls-localhost-8054-ca-user.pem
CAPEM=../organizations/peerOrganizations/property.com/user.property.com/ca/localhost-8054-ca-user.pem
ORGMSP=user

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGMSP)" > gateways/connection-user.json

