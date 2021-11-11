/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { ChaincodeStub, ClientIdentity } = require('fabric-shim');
const { TxnContract } = require('../lib');
const winston = require('winston');

const crypto = require('crypto');
const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const sinon = require('sinon');
const sinonChai = require('sinon-chai');

chai.should();
chai.use(chaiAsPromised);
chai.use(sinonChai);

class TestContext {

    constructor() {
        this.stub = sinon.createStubInstance(ChaincodeStub);
        this.clientIdentity = sinon.createStubInstance(ClientIdentity);
        this.logging = {
            getLogger: sinon.stub().returns(sinon.createStubInstance(winston.createLogger().constructor)),
            setLevel: sinon.stub(),
        };
    }

}

describe('TxnContract', () => {

    let contract;
    let ctx;
    const mspid = 'one';
    const collectionName = `_implicit_org_${mspid}`;

    beforeEach(() => {
        contract = new TxnContract();
        ctx = new TestContext();
        ctx.clientIdentity.getMSPID.returns(mspid);
        ctx.stub.getPrivateData.withArgs(collectionName, '001').resolves(Buffer.from('{"privateValue":"150"}'));
        const hashToVerify = crypto.createHash('sha256').update('{"privateValue":"150"}').digest('hex');
        ctx.stub.getPrivateDataHash.withArgs(collectionName, '001').resolves(Buffer.from(hashToVerify, 'hex'));
    });

    describe('#txnExists', () => {

        it('should return true for a private asset that exists', async () => {
            await contract.txnExists(ctx, '001').should.eventually.be.true;
        });

        it('should return false for a private asset that does not exist', async () => {
            await contract.txnExists(ctx, '002').should.eventually.be.false;
        });

    });

    describe('#createTxn', () => {

        it('should throw an error for a private asset that already exists', async () => {
            await contract.createTxn(ctx, '001').should.be.rejectedWith('The asset txn 001 already exists');
        });

        it('should throw an error if transient data is not provided when creating private asset', async () => {
            let transientMap = new Map();
            ctx.stub.getTransient.returns(transientMap);
            await contract.createTxn(ctx, '002').should.be.rejectedWith('The privateValue key was not specified in transient data. Please try again.');
        });

        it('should throw an error if transient data key is not privateValue', async () => {
            let transientMap = new Map();
            transientMap.set('prVal', Buffer.from('125'));
            ctx.stub.getTransient.returns(transientMap);
            await contract.createTxn(ctx, '002').should.be.rejectedWith('The privateValue key was not specified in transient data. Please try again.');
        });

        it('should create a private asset if transient data key is privateValue', async () => {
            let transientMap = new Map();
            transientMap.set('privateValue', Buffer.from('1500'));
            ctx.stub.getTransient.returns(transientMap);
            await contract.createTxn(ctx, '002');
            ctx.stub.putPrivateData.should.have.been.calledOnceWithExactly(collectionName, '002', Buffer.from('{"privateValue":"1500"}'));
        });

    });

    describe('#readTxn', () => {

        it('should throw an error for my private asset that does not exist', async () => {
            await contract.readTxn(ctx, '003').should.be.rejectedWith('The asset txn 003 does not exist');
        });

        it('should return my private asset', async () => {
            await contract.readTxn(ctx, '001').should.eventually.deep.equal({ privateValue: '150' });
            ctx.stub.getPrivateData.should.have.been.calledWithExactly(collectionName, '001');
        });

    });

    describe('#updateTxn', () => {

        it('should throw an error for my private asset that does not exist', async () => {
            await contract.updateTxn(ctx, '003').should.be.rejectedWith('The asset txn 003 does not exist');
        });

        it('should throw an error if transient data is not provided when updating private asset', async () => {
            let transientMap = new Map();
            ctx.stub.getTransient.returns(transientMap);
            await contract.updateTxn(ctx, '001').should.be.rejectedWith('The privateValue key was not specified in transient data. Please try again.');
        });

        it('should update my private asset if transient data key is privateValue', async () => {
            let transientMap = new Map();
            transientMap.set('privateValue', Buffer.from('99'));
            ctx.stub.getTransient.returns(transientMap);
            await contract.updateTxn(ctx, '001');
            ctx.stub.putPrivateData.should.have.been.calledOnceWithExactly(collectionName, '001', Buffer.from('{"privateValue":"99"}'));
        });

        it('should throw an error if transient data key is not privateValue', async () => {
            let transientMap = new Map();
            transientMap.set('prVal', Buffer.from('125'));
            ctx.stub.getTransient.returns(transientMap);
            await contract.updateTxn(ctx, '001').should.be.rejectedWith('The privateValue key was not specified in transient data. Please try again.');
        });

    });

    describe('#deleteTxn', () => {

        it('should throw an error for my private asset that does not exist', async () => {
            await contract.deleteTxn(ctx, '003').should.be.rejectedWith('The asset txn 003 does not exist');
        });

        it('should delete my private asset', async () => {
            await contract.deleteTxn(ctx, '001');
            ctx.stub.deletePrivateData.should.have.been.calledOnceWithExactly(collectionName, '001');
        });

    });

    describe('#verifyTxn', () => {

        it('should return success message if hash provided matches the hash of the private data', async () => {
            const objectToVerify = '{"privateValue":"125"}';
            const hashToVerify = crypto.createHash('sha256').update(objectToVerify).digest('hex');
            ctx.stub.getPrivateDataHash.withArgs(collectionName, '001').resolves(Buffer.from(hashToVerify, 'hex'));
            const result = await contract.verifyTxn(ctx, mspid, '001', '{"privateValue":"125"}');
            result.should.equal(true);
        });

        it('should throw an error if hash provided does not match the hash of the private data', async () => {
            ctx.stub.getPrivateDataHash.withArgs(collectionName, '001').resolves(Buffer.from('someHash'));
            const result = await contract.verifyTxn(ctx, mspid, '001', 'someObject');
            result.should.equal(false);
        });

        it('should throw an error when user tries to verify an asset that doesnt exist', async () => {
            ctx.stub.getPrivateDataHash.withArgs(collectionName, '001').resolves(Buffer.from(''));
            await contract.verifyTxn(ctx, mspid, '001', 'someObject').should.be.rejectedWith('No private data hash with the key: 001');
        });
    });
});
