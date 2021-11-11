/*
* Use this file for functional testing of your smart contract.
* Fill out the arguments and return values for a function and
* use the CodeLens links above the transaction blocks to
* invoke/submit transactions.
* All transactions defined in your smart contract are used here
* to generate tests, including those functions that would
* normally only be used on instantiate and upgrade operations.
* This basic test file can also be used as the basis for building
* further functional tests to run as part of a continuous
* integration pipeline, or for debugging locally deployed smart
* contracts by invoking/submitting individual transactions.
*/
/*
* Generating this test file will also trigger an npm install
* in the smart contract project directory. This installs any
* package dependencies, including fabric-network, which are
* required for this test file to be run locally.
*/

'use strict';

const assert = require('assert');
const fabricNetwork = require('fabric-network');
const SmartContractUtil = require('./js-smart-contract-util');
const os = require('os');
const path = require('path');

describe('UserContract-Property@0.0.4' , () => {

    const homedir = os.homedir();
    const walletPath = path.join(homedir, '.fabric-vscode', 'environments', 'PropertyNetwork', 'wallets', 'User');
    const gateway = new fabricNetwork.Gateway();
    let wallet;
    const identityName = 'User Admin';
    let connectionProfile;

    before(async () => {
        connectionProfile = await SmartContractUtil.getConnectionProfile();
        wallet = await fabricNetwork.Wallets.newFileSystemWallet(walletPath);
    });

    beforeEach(async () => {

        const discoveryAsLocalhost = SmartContractUtil.hasLocalhostURLs(connectionProfile);
        const discoveryEnabled = true;

        const options = {
            wallet: wallet,
            identity: identityName,
            discovery: {
                asLocalhost: discoveryAsLocalhost,
                enabled: discoveryEnabled
            }
        };

        await gateway.connect(connectionProfile, options);
    });

    afterEach(async () => {
        gateway.disconnect();
    });

    describe('userExists', () =>{
        it('should submit userExists transaction', async () => {
            // TODO: populate transaction parameters
            const arg0 = 'usr-001';
            const args = [ arg0];
            const response = await SmartContractUtil.submitTransaction('UserContract', 'userExists', args, gateway); // Returns buffer of transaction return value
            
            // TODO: Update with return value of transaction
            assert.strictEqual(JSON.parse(response.toString()), true);
        }).timeout(10000);
    });

    describe('userRegistrationRequest', () =>{
        it('should submit userRegistrationRequest transaction', async () => {
            // TODO: populate transaction parameters
            const arg0 = 'usr-100';
            const arg1 = 'AP';
            const arg2 = '7876123456';
            const arg3 = 'usr-100@email.com';
            const args = [ arg0, arg1, arg2, arg3];
            const response = await SmartContractUtil.submitTransaction('UserContract', 'userRegistrationRequest', args, gateway); // Returns buffer of transaction return value
            
            // TODO: Update with return value of transaction
            let returnVal = `Successfully able to register {"userId": ${arg0},"userName":${arg1},"phoneNumber":${arg2},"emailId":${arg3}}`;
            assert.strictEqual(JSON.parse(response.toString()), returnVal);
        }).timeout(10000);
    });

    describe('viewUser', () =>{
        it('should submit viewUser transaction', async () => {
            // TODO: populate transaction parameters
            const arg0 = 'usr-001';
            const args = [ arg0];
            const response = await SmartContractUtil.submitTransaction('UserContract', 'viewUser', args, gateway); // Returns buffer of transaction return value
            const expectedResponse = `{"emailId":"usr-001@email.com","phoneNumber":"123456789","userId":"usr-001","userName":"Adam"}`
            // TODO: Update with return value of transaction
            assert.strictEqual(JSON.parse(response.toString()), expectedResponse);
        }).timeout(10000);
    });

    describe('deleteUser', () =>{
        it('should submit deleteUser transaction', async () => {
            // TODO: populate transaction parameters
            const arg0 = 'EXAMPLE';
            const args = [ arg0];
            const response = await SmartContractUtil.submitTransaction('UserContract', 'deleteUser', args, gateway); // Returns buffer of transaction return value
            
            // TODO: Update with return value of transaction
            assert.strictEqual(JSON.parse(response.toString()), undefined);
        }).timeout(10000);
    });

});
