sh createCa.sh

sleep 5

echo "########## Setting required env ############"
export CHANNEL_NAME=autochannel
export IMAGE_TAG=latest
export COMPOSE_PROJECT_NAME=fabricscratch-ca

echo "########## Generate the genesis block ############"
configtxgen -profile OrdererGenesis \
-channelID system-channel -outputBlock \
./channel-artifacts/genesis.block

sleep 2

echo "########## Generate the Channel Transaction ############"
configtxgen -profile AutoChannel \
-outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME.tx \
-channelID $CHANNEL_NAME

sleep 2

echo "########## Starting the components ############"
docker-compose -f docker/docker-compose-singlepeer.yml up -d

export ORDERER_TLS_CA=`docker exec cli  env | grep ORDERER_TLS_CA | cut -d'=' -f2`

sleep 2

echo "########## Creating the Channel ############"
docker exec cli peer channel create -o orderer.property.com:7050 \
-c $CHANNEL_NAME -f /opt/gopath/src/github.com/hyperledger/fabric/peer/config/$CHANNEL_NAME.tx \
--tls --cafile $ORDERER_TLS_CA


sleep 2

echo "########## Joining Admin Peer to Channel ############"
docker exec \
     -e CORE_PEER_LOCALMSPID=AdminMSP \
     -e CHANNEL_NAME=autochannel \
     -e CORE_PEER_ADDRESS=peer0.admin.property.com:7051 \
     -e ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem \
     -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.crt \
     -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.key \
     -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/ca.crt \
     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/users/Admin@admin.property.com/msp \
     -e CORE_PEER_TLS_ENABLED=true \
     -e FABRIC_LOGGING_SPEC=INFO \
     -i \
     cli peer channel join -b $CHANNEL_NAME.block

sleep 2

echo "########## Joining User Peer to Channel ############"
docker exec \
     -e CORE_PEER_LOCALMSPID=UserMSP \
     -e CHANNEL_NAME=autochannel \
     -e CORE_PEER_ADDRESS=peer0.user.property.com:9051 \
     -e ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem \
     -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.crt \
     -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.key \
     -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/ca.crt \
     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/users/Admin@user.property.com/msp \
     -e CORE_PEER_TLS_ENABLED=true \
     -e FABRIC_LOGGING_SPEC=INFO \
     -i \
     cli peer channel join -b $CHANNEL_NAME.block

sleep 2


echo "########## Generating anchor peer tx for admin ############"
configtxgen -profile AutoChannel -outputAnchorPeersUpdate ./channel-artifacts/AdminMSPanchors.tx -channelID autochannel -asOrg AdminMSP

sleep 2

echo "########## Generating anchor peer tx for user ############"
configtxgen -profile AutoChannel -outputAnchorPeersUpdate ./channel-artifacts/UserMSPanchors.tx -channelID autochannel -asOrg UserMSP

sleep 2


echo "########## Anchor Peer Update for Admin ############"
docker exec \
     -e CORE_PEER_LOCALMSPID=AdminMSP \
     -e CHANNEL_NAME=autochannel \
     -e CORE_PEER_ADDRESS=peer0.admin.property.com:7051 \
     -e ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem \
     -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.crt \
     -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.key \
     -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/ca.crt \
     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/users/Admin@admin.property.com/msp \
     -e CORE_PEER_TLS_ENABLED=true \
     -e FABRIC_LOGGING_SPEC=INFO \
     -i \
     cli peer channel update -o orderer.property.com:7050 -c autochannel -f ./config/AdminMSPanchors.tx --tls --cafile $ORDERER_TLS_CA

sleep 2

echo "##########  Anchor Peer Update for User ############"
docker exec \
     -e CORE_PEER_LOCALMSPID=UserMSP \
     -e CHANNEL_NAME=autochannel \
     -e CORE_PEER_ADDRESS=peer0.user.property.com:9051 \
     -e ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem \
     -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.crt \
     -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.key \
     -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/ca.crt \
     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/users/Admin@user.property.com/msp \
     -e CORE_PEER_TLS_ENABLED=true \
     -e FABRIC_LOGGING_SPEC=INFO \
     -i \
     cli peer channel update -o orderer.property.com:7050 -c autochannel -f ./config/UserMSPanchors.tx --tls --cafile $ORDERER_TLS_CA

sleep 2


echo "##########  Package Chaincode ############"
docker exec \
     -e CORE_PEER_LOCALMSPID=AdminMSP \
     -e CHANNEL_NAME=autochannel \
     -e CORE_PEER_ADDRESS=peer0.admin.property.com:7051 \
     -e ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem \
     -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.crt \
     -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.key \
     -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/ca.crt \
     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/users/Admin@admin.property.com/msp \
     -e CORE_PEER_TLS_ENABLED=true \
     -e FABRIC_LOGGING_SPEC=INFO \
     -i \
     cli peer lifecycle chaincode package kbaproperty.tar.gz --path /opt/gopath/src/github.com/chaincode/Property/ --lang node --label kbaproperty_1

sleep 2

echo "##########  Install Chaincode on Admin peer ############"
docker exec \
     -e CORE_PEER_LOCALMSPID=AdminMSP \
     -e CHANNEL_NAME=autochannel \
     -e CORE_PEER_ADDRESS=peer0.admin.property.com:7051 \
     -e ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem \
     -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.crt \
     -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/server.key \
     -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/peers/peer0.admin.property.com/tls/ca.crt \
     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/admin.property.com/users/Admin@admin.property.com/msp \
     -e CORE_PEER_TLS_ENABLED=true \
     -e FABRIC_LOGGING_SPEC=INFO \
     -i \
     cli peer lifecycle chaincode install kbaproperty.tar.gz


sleep 2

echo "##########  Install Chaincode on User peer ############"
docker exec \
     -e CORE_PEER_LOCALMSPID=UserMSP \
     -e CHANNEL_NAME=autochannel \
     -e CORE_PEER_ADDRESS=peer0.user.property.com:9051 \
     -e ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property.com/orderer.property.com/msp/tlscacerts/tlsca.property.com-cert.pem \
     -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.crt \
     -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/server.key \
     -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/peers/peer0.user.property.com/tls/ca.crt \
     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/property.com/user.property.com/users/Admin@user.property.com/msp \
     -e CORE_PEER_TLS_ENABLED=true \
     -e FABRIC_LOGGING_SPEC=INFO \
     -i \
     cli peer lifecycle chaincode install kbaproperty.tar.gz

sleep 2


echo "##########  Copy the above package ID for next steps, follow the approveCommit.txt ############"
