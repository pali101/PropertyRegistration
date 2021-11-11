#!/bin/bash


sudo rm -rf \
    ./organizations/fabric-ca/user/msp \
    ./organizations/fabric-ca/user/ca-cert.pem \
    ./organizations/fabric-ca/user/fabric-ca-server.db \
    ./organizations/fabric-ca/user/IssuerPublicKey \
    ./organizations/fabric-ca/user/IssuerRevocationPublicKey \
    ./organizations/fabric-ca/user/tls-cert.pem

sudo rm -rf \
    ./organizations/fabric-ca/admin/msp \
    ./organizations/fabric-ca/admin/ca-cert.pem \
    ./organizations/fabric-ca/admin/fabric-ca-server.db \
    ./organizations/fabric-ca/admin/IssuerPublicKey \
    ./organizations/fabric-ca/admin/IssuerRevocationPublicKey \
    ./organizations/fabric-ca/admin/tls-cert.pem


sudo rm -rf \
    ./organizations/fabric-ca/orderer/msp \
    ./organizations/fabric-ca/orderer/ca-cert.pem \
    ./organizations/fabric-ca/orderer/fabric-ca-server.db \
    ./organizations/fabric-ca/orderer/IssuerPublicKey \
    ./organizations/fabric-ca/orderer/IssuerRevocationPublicKey \
    ./organizations/fabric-ca/orderer/tls-cert.pem

sudo rm -rf \
    ./organizations/ordererOrganizations/property.com/orderer.property.com/msp \
    ./organizations/ordererOrganizations/property.com/orderer.property.com/fabric-ca-client-config.yaml \
    ./organizations/ordererOrganizations/property.com/orderer.property.com/orderers \
    ./organizations/ordererOrganizations/property.com/orderer.property.com/users
    
sudo rm -rf \
    ./organizations/peerOrganizations/property.com/admin.property.com/ca \
    ./organizations/peerOrganizations/property.com/admin.property.com/msp \
    ./organizations/peerOrganizations/property.com/admin.property.com/peers \
    ./organizations/peerOrganizations/property.com/admin.property.com/tlsca \
    ./organizations/peerOrganizations/property.com/admin.property.com/users \
    ./organizations/peerOrganizations/property.com/admin.property.com/fabric-ca-client-config.yaml

sudo rm -rf \
    ./organizations/peerOrganizations/property.com/user.property.com/ca \
    ./organizations/peerOrganizations/property.com/user.property.com/msp \
    ./organizations/peerOrganizations/property.com/user.property.com/peers \
    ./organizations/peerOrganizations/property.com/user.property.com/tlsca \
    ./organizations/peerOrganizations/property.com/user.property.com/users \
    ./organizations/peerOrganizations/property.com/user.property.com/fabric-ca-client-config.yaml
