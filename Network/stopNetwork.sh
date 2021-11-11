export CHANNEL_NAME=autochannel
export IMAGE_TAG=latest
export COMPOSE_PROJECT_NAME=fabricscratch-ca

docker-compose -f docker/docker-compose-singlepeer.yml down

rm channel-artifacts/*.*


sleep 5
echo "******* Deleting CA *********"
export COMPOSE_PROJECT_NAME=fabricscratch-ca

docker-compose -f docker/docker-compose-ca.yml down


docker system prune && docker volume prune

docker rmi $(docker images dev-* -aq)

echo "Removing Certificates"

sh removecacerts.sh

echo "Removed Property Network"

