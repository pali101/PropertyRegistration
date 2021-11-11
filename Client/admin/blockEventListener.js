'use strict';

const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function main() {
    const gateway = new Gateway();
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

        await gateway.connect(ccp,
            {
                wallet, identity: 'appUser',
                discovery: { enabled: true, asLocalhost: true }
            });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('autochannel');

        //Listener to block events
        await network.addBlockListener(async (event) => {
            console.log('Block details: ', event);
            console.log('Block number :', event.blockNumber.toString());
        })

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

main();