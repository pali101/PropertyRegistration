/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');
const crypto = require('crypto');

async function getCollectionName(ctx) {
    return 'CollectionOrder';
}

class TxnContract extends Contract {

    constructor() {
        // Unique name when multiple contracts per chaincode file
        super('org.property.txnContract');
    }
    async txnExists(ctx, txnId) {
        const collectionName = await getCollectionName(ctx);
        const data = await ctx.stub.getPrivateDataHash(collectionName, txnId);
        return (!!data && data.length > 0);
    }

    async createTxn(ctx, txnId) {
        const exists = await this.txnExists(ctx, txnId);
        if (exists) {
            throw new Error(`The asset txn ${txnId} already exists`);
        }

        const transactionAsset = {};

        const transientData = ctx.stub.getTransient();
        if (transientData.size === 0 ||  
            !transientData.has('propertyId') ||
            !transientData.has('owner') ||
            !transientData.has('price') ) {
            throw new Error('The privateValue key was not specified in transient data. Please try again.');
        }

        transactionAsset.propertyId = transientData.get('propertyId').toString();
        transactionAsset.owner = transientData.get('owner').toString();
        transactionAsset.price = transientData.get('price').toString();
        transactionAsset.assetType = 'order';

        const collectionName = await getCollectionName(ctx);
        await ctx.stub.putPrivateData(collectionName, txnId, Buffer.from(JSON.stringify(transactionAsset)));
    }

    async readTxn(ctx, txnId) {
        const exists = await this.txnExists(ctx, txnId);
        if (!exists) {
            throw new Error(`The asset txn ${txnId} does not exist`);
        }
        // let privateDataString;
        const collectionName = await getCollectionName(ctx);
        const transactionData = await ctx.stub.getPrivateData(collectionName, txnId);
        privateDataString = JSON.parse(privateData.toString());
        return privateDataString;
    }

    // async updateTxn(ctx, txnId) {
    //     const exists = await this.txnExists(ctx, txnId);
    //     if (!exists) {
    //         throw new Error(`The asset txn ${txnId} does not exist`);
    //     }
    //     const privateAsset = {};

    //     const transientData = ctx.stub.getTransient();
    //     if (transientData.size === 0 || !transientData.has('privateValue')) {
    //         throw new Error('The privateValue key was not specified in transient data. Please try again.');
    //     }
    //     privateAsset.privateValue = transientData.get('privateValue').toString();

    //     const collectionName = await getCollectionName(ctx);
    //     await ctx.stub.putPrivateData(collectionName, txnId, Buffer.from(JSON.stringify(privateAsset)));
    // }

    async deleteTxn(ctx, txnId) {
        const exists = await this.txnExists(ctx, txnId);
        if (!exists) {
            throw new Error(`The asset txn ${txnId} does not exist`);
        }
        const collectionName = await getCollectionName(ctx);
        await ctx.stub.deletePrivateData(collectionName, txnId);
    }

    // async verifyTxn(ctx, mspid, txnId, objectToVerify) {

    //     // Convert provided object into a hash
    //     const hashToVerify = crypto.createHash('sha256').update(objectToVerify).digest('hex');
    //     const pdHashBytes = await ctx.stub.getPrivateDataHash(`_implicit_org_${mspid}`, txnId);
    //     if (pdHashBytes.length === 0) {
    //         throw new Error('No private data hash with the key: ' + txnId);
    //     }

    //     const actualHash = Buffer.from(pdHashBytes).toString('hex');

    //     // Compare the hash calculated (from object provided) and the hash stored on public ledger
    //     if (hashToVerify === actualHash) {
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }


}

module.exports = TxnContract;
