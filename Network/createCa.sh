echo "##########Strating the docker-compose-ca############"
export COMPOSE_PROJECT_NAME=fabricscratch-ca
docker-compose -f ./docker/docker-compose-ca.yml up -d 

echo "##########Creating the folder structure for CA############"

mkdir -p organizations/peerOrganizations/property.com/admin.property.com/
mkdir -p organizations/peerOrganizations/property.com/user.property.com/

echo "##########Setting PATH for Fabric CA client############"

export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/property.com/admin.property.com/
sleep 2

echo "########## Enroll Admin ca admin############"

fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-admin --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem

sleep 5

echo "########## Create config.yaml for Admin ############"

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-admin.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-admin.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-admin.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-admin.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/msp/config.yaml

echo "########## Register admin peer ############"
fabric-ca-client register --caname ca-admin --id.name peer0admin --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem
sleep 5

echo "########## Register admin user ############"

fabric-ca-client register --caname ca-admin --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem
sleep 5

echo "########## Register admin Org admin ############"

fabric-ca-client register --caname ca-admin --id.name adminadmin --id.secret adminadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem
sleep 5

echo "########## Generate Admin peer MSP ############"

fabric-ca-client enroll -u https://peer0admin:peer0pw@localhost:7054 --caname ca-admin -M ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/msp --csr.hosts peer0.admin.property.com --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem
sleep 5

echo "########## Generate Admin Peer tls cert ############"

fabric-ca-client enroll -u https://peer0admin:peer0pw@localhost:7054 --caname ca-admin -M ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls --enrollment.profile tls --csr.hosts peer0.admin.property.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem
sleep 5

echo "########## Organizing the folders ############"
echo "########## Copy the certificate files ############"

cp organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/tlscacerts/* organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/ca.crt
cp organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/signcerts/* organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.crt
cp organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/keystore/* organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.key

mkdir -p ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/msp/tlscacerts
cp ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/msp/tlscacerts/ca.crt

mkdir -p ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/tlsca
cp ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/tlsca/tls-localhost-7054-ca-admin.pem

mkdir -p ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/ca
cp ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/ca/localhost-7054-ca-admin.pem

cp organizations/peerOrganizations/property.com/admin.property.com/msp/config.yaml organizations/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/msp/config.yaml

echo "Generate User MSP"
echo "================="

fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-admin -M ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/users/User1@admin.property.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem

sleep 5

cp organizations/peerOrganizations/property.com/admin.property.com/msp/config.yaml organizations/peerOrganizations/property.com/admin.property.com/users/User1@admin.property.com/msp/config.yaml

echo "Generate org Admin MSP"
echo "======================"
dealer
fabric-ca-client enroll -u https://adminadmin:adminadminpw@localhost:7054 --caname ca-admin -M ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/users/Admin@admin.property.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/admin/tls-cert.pem
sleep 5

cp ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/property.com/admin.property.com/users/Admin@admin.property.com/msp/config.yaml

echo "============================================================End of Admin =================================================================================================="

echo "================================================================== User =================================================================================================="


export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/property.com/user.property.com/

echo "enroll User ca"
echo "======================"

fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-user --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem

sleep 5




echo "Create config.yaml for User" 
echo "==================================="

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-user.pem 
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-user.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-user.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-user.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/property.com/user.property.com/msp/config.yaml

echo "Register user peer"
echo "=========================="
fabric-ca-client register --caname ca-user --id.name peer0user --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem
sleep 5

echo "Register user user"
echo "=========================="
fabric-ca-client register --caname ca-user --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem
sleep 5

echo "Register user Org admin"
echo "=========================="
fabric-ca-client register --caname ca-user --id.name useradmin --id.secret useradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem
sleep 5

echo "Generate User peer MSP"
echo "=============================="
fabric-ca-client enroll -u https://peer0user:peer0pw@localhost:8054 --caname ca-user -M ${PWD}/organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/msp --csr.hosts peer0.user.property.com --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem
sleep 5

echo "Generate User Peer tls cert"
echo "==================================="
fabric-ca-client enroll -u https://peer0user:peer0pw@localhost:8054 --caname ca-user -M ${PWD}/organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls --enrollment.profile tls --csr.hosts peer0.user.property.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem
sleep 5

echo "Organizing the folders"
echo "======================"

echo "Copy the certificate files"
echo "=========================="

cp organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/tlscacerts/* organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/ca.crt
cp organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/signcerts/* organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.crt
cp organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/keystore/* organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.key

mkdir -p ${PWD}/organizations/peerOrganizations/property.com/user.property.com/msp/tlscacerts
cp ${PWD}/organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/property.com/user.property.com/msp/tlscacerts/ca.crt

mkdir -p ${PWD}/organizations/peerOrganizations/property.com/user.property.com/tlsca
cp ${PWD}/organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/property.com/user.property.com/tlsca/tls-localhost-8054-ca-user.pem

mkdir -p ${PWD}/organizations/peerOrganizations/property.com/user.property.com/ca
cp ${PWD}/organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/property.com/user.property.com/ca/localhost-8054-ca-user.pem

cp organizations/peerOrganizations/property.com/user.property.com/msp/config.yaml organizations/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/msp/config.yaml

echo "Generate User MSP"
echo "================="

fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-user -M ${PWD}/organizations/peerOrganizations/property.com/user.property.com/users/User1@user.property.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem
sleep 5

cp organizations/peerOrganizations/property.com/user.property.com/msp/config.yaml organizations/peerOrganizations/property.com/user.property.com/users/User1@user.property.com/msp/config.yaml

echo "Generate org Admin MSP"
echo "======================"

fabric-ca-client enroll -u https://useradmin:useradminpw@localhost:8054 --caname ca-user -M ${PWD}/organizations/peerOrganizations/property.com/user.property.com/users/Admin@user.property.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/user/tls-cert.pem
sleep 5

cp ${PWD}/organizations/peerOrganizations/property.com/user.property.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/property.com/user.property.com/users/Admin@user.property.com/msp/config.yaml


echo "==========================================================End of User ========================================================================================================"


echo "==========================================================Orderer Config ========================================================================================================================"


echo "enroll Orderer ca"
echo "================="

mkdir -p organizations/ordererOrganizations/property.com/orderer.property.com/


export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/

fabric-ca-client enroll -u https://admin:adminpw@localhost:9052 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
sleep 5
echo "Create config.yaml for Mvd "
echo "==================================="

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9052-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9052-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9052-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9052-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/msp/config.yaml

echo "Register orderer"
echo "=========================="
fabric-ca-client register --caname ca-orderer --id.name orderer0 --id.secret orderer0pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem

echo "Register orderer Org admin"
echo "=========================="
fabric-ca-client register --caname ca-orderer --id.name ordereradmin --id.secret ordereradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem

echo "Generate Orderer MSP"
echo "=============================="
fabric-ca-client enroll -u https://orderer0:orderer0pw@localhost:9052 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/msp --csr.hosts orderer.property.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem

cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/msp/config.yaml

echo "Generate Orderer TLS certificates"
echo "==================================="
fabric-ca-client enroll -u https://orderer0:orderer0pw@localhost:9052 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls --enrollment.profile tls --csr.hosts orderer.property.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
sleep 5

echo "Organizing the folders"
echo "======================"
echo "Copy the certificate files"
echo "=========================="

  cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/orderers/orderer.property.com/msp/config.yaml

echo "Generate Orderer admin MSP"
echo "=========================="
  fabric-ca-client enroll -u https://ordereradmin:ordereradminpw@localhost:9052 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/users/Admin@property.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
sleep 5

  cp ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/property.com/orderer.property.com/users/Admin@property.com/msp/config.yaml

echo "=========================================================End of orderer ========================================================================================================================"







