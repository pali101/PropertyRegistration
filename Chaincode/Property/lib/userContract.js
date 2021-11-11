/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class UserContract extends Contract { 
    
    constructor() {
        // Unique name when multiple contracts per chaincode file
        super('org.property.userContract');
    }

    async userExists(ctx, userId) {
        const buffer = await ctx.stub.getState(userId);
        return (!!buffer && buffer.length > 0);
    }

    async userRegistrationRequest(ctx, userId, userName, phoneNumber, emailId) {
        const mspID = ctx.clientIdentity.getMSPID();
        if (mspID === 'UserMSP') {
            const exists = await this.userExists(ctx, userId);
            if (exists) {
                throw new Error(`The user ${userId} already exists`);
            }
            const userAsset = {
                userId: userId,
                userName: userName,
                phoneNumber: phoneNumber,
                emailId: emailId
            }
            const buffer = Buffer.from(JSON.stringify(userAsset));
            await ctx.stub.putState(userId, buffer);
        } else {
            return `User under following MSP:- ${mspID} cannot register user`;
        }
    }

    async viewUser(ctx, userId) {
        const exists = await this.userExists(ctx, userId);
        if (!exists) {
            throw new Error(`The user ${userId} does not exist`);
        }
        const buffer = await ctx.stub.getState(userId);
        const asset = JSON.parse(buffer.toString());
        return asset;
    }

    async deleteUser(ctx, userId) {
        const mspID = ctx.clientIdentity.getMSPID();
        if (mspID === 'AdminMSP') {
            const exists = await this.userExists(ctx, userId);
            if (!exists) {
                throw new Error(`The user ${userId} does not exist`);
            }
            await ctx.stub.deleteState(userId);
        } else {
            return `User under following MSP:${mspID} cannot able to perform this action`;
        }
    }

    // Check if property already exists in ledger
    async propertyExists(ctx, propertyId) {
        const buffer = await ctx.stub.getState(propertyId);
        return (!!buffer && buffer.length > 0);
    }

    // Create request for new Property
    async propertyRegistrationRequest(ctx, propertyId, propertyName, owner, price, status) {
        const mspID = ctx.clientIdentity.getMSPID();
        if (mspID === 'UserMSP') {
            const exists = await this.propertyExists(ctx, propertyId);
            if (exists) {
                throw new Error(`The property ${propertyId} already exists`);
            }
            const propertyAsset = {
                propertyId: propertyId,
                propertyName: propertyName,
                owner: owner,
                price: price,
                status: status
            }
            const buffer = Buffer.from(JSON.stringify(propertyAsset));
            await ctx.stub.putState(propertyId, buffer);
        } else {
            return `User under following MSP:- ${mspID} cannot able to perform this action`;
        }
    }

    // Read property details
    async readProperty(ctx, propertyId) {
        const exists = await this.propertyExists(ctx, propertyId);
        if (!exists) {
            throw new Error(`The property ${propertyId} does not exist`);
        }
        const buffer = await ctx.stub.getState(propertyId);
        const asset = JSON.parse(buffer.toString());
        return asset;
    }

    async updateProperty(ctx, propertyId, newValue) {
        const exists = await this.propertyExists(ctx, propertyId);
        if (!exists) {
            throw new Error(`The property ${propertyId} does not exist`);
        }
        const asset = { value: newValue };
        const buffer = Buffer.from(JSON.stringify(asset));
        await ctx.stub.putState(propertyId, buffer);
    }

    // Delete property details
    async deleteProperty(ctx, propertyId) {
        const mspID = ctx.clientIdentity.getMSPID();
        if (mspID === 'UserMSP' || mspID === 'AdminMSP') {
            const exists = await this.propertyExists(ctx, propertyId);
            if (!exists) {
                throw new Error(`The property ${propertyId} does not exist`);
            }
            await ctx.stub.deleteState(propertyId);
        } else {
            return `User under following MSP:${mspID} cannot able to perform this action`;
        }
    }

    // Query all registered properties  
    async queryAllProperties(ctx) {
        const queryString = {
            selector: {
                assetType: 'property',
            },
            sort: [{ propertyId: 'asc' }],
        };
        let resultIterator = await ctx.stub.getQueryResult(
            JSON.stringify(queryString)
        );
        let result = await this.getAllResults(resultIterator, false);
        return JSON.stringify(result);
    }

    // Get property according to property ID range
    async getPropertyByRange(ctx, startKey, endKey) {
        let resultIterator = await ctx.stub.getStateByRange(startKey, endKey);
        let result = await this.getAllResults(resultIterator, false);
        return JSON.stringify(result);
    }

    // Fetch property history
    async getPropertyHistory(ctx, propertyID) {
        let resultsIterator = await ctx.stub.getHistoryForKey(propertyID);
        let results = await this.getAllResults(resultsIterator, true);
        return JSON.stringify(results);
    }

    async approvedUserExists(ctx, userId) {
        const approvedUserId = SHA256(userId).toString()
        const buffer = await ctx.stub.getState(approvedUserId);
        return (!!buffer && buffer.length > 0);
    }

    async approveNewUser(ctx, userId) {
        const mspID = ctx.clientIdentity.getMSPID();
        const user = await this.userExists(ctx, userId);
            if(!user) {
                throw new Error(`The user ${userId} does not exist`);
            }
        // Use nounce for approvedUserId and approvedPropertyId if need to use this in production
        const approvedUserId = SHA256(userId).toString()
        if (mspID === 'AdminMSP') {
            const exists = await this.approvedUserExists(ctx, userId);
            if (exists) {
                throw new Error(`The user ${userId} is already approved`);
            }
            const userAsset = await ctx.stub.getState(userId)
            // const buffer = Buffer.from(JSON.stringify(userAsset));
            await ctx.stub.putState(approvedUserId, userAsset);
        } else {
            return `User under following MSP:- ${mspID} is not authorised to approve new user`;
        }
    }

    async deleteApprovedUser(ctx, userId) {
        const mspID = ctx.clientIdentity.getMSPID();
        const approvedUserId = SHA256(userId).toString()
        if (mspID === 'AdminMSP') {
            const exists = await this.approvedUserExists(ctx, userId);
            if (!exists) {
                throw new Error(`The user ${userId} does not exist`);
            }
            await ctx.stub.deleteState(approvedUserId);
        } else {
            return `User under following MSP:${mspID} cannot able to perform this action`;
        }
    }

    async approvedPropertyExists(ctx, propertyId) {
        const approvedPropertyId = SHA256(propertyId).toString();
        const buffer = await ctx.stub.getState(approvedPropertyId);
        return (!!buffer && buffer.length > 0);
    }

    async approveNewProperty(ctx, propertyId) {
        const mspID = ctx.clientIdentity.getMSPID();
        const approvedPropertyId = SHA256(propertyId).toString();
        if (mspID === 'AdminMSP') {
            const property = await this.propertyExists(ctx, propertyId);
            if(!property) {
                throw new Error(`The property ${propertyId} does not exist`);
            }
            const exists = await this.approvedPropertyExists(ctx, propertyId);
            if (exists) {
                throw new Error(`The property ${propertyId} transaction is already approved`);
            }
            const propertyAsset = await ctx.stub.getState(propertyId)
            // const buffer = Buffer.from(JSON.stringify(userAsset));
            await ctx.stub.putState(approvedPropertyId, propertyAsset);
        } else {
            return `User under following MSP:- ${mspID} is not authorised to approve new property transaction`;
        }
    }
}
module.exports = UserContract;