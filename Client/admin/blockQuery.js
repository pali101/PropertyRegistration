'use strict';

const { Gateway, Wallets } = require('fabric-network');
const { BlockDecoder } = require('fabric-common');
const fs = require('fs');
const path = require('path');

async function main() {
    try {
        const ccpPath = path.resolve(__dirname, '../../Network/organizations/gateways/connection-admin.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('appUser');
        if (!identity) {
            console.log('An identity for the user "appUser" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp,
            {
                wallet, identity: 'appUser',
                discovery: { enabled: true, asLocalhost: true }
            });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('autochannel');

        // Get the contract from the network.
        const contract = network.getContract('qscc');

        //Block query
        const resultByte = await contract.evaluateTransaction(
            'GetBlockByNumber',
            'autochannel',
            String(6)
        );
        const resultJson = BlockDecoder.decode(resultByte);
        console.log("queryBlock: ", resultJson);

        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

main();