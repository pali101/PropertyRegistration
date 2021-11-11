/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { ChaincodeStub, ClientIdentity } = require('fabric-shim');
const { UserContract } = require('..');
const winston = require('winston');

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
        this.logger = {
            getLogger: sinon
                .stub()
                .returns(sinon.createStubInstance(winston.createLogger().constructor)),
            setLevel: sinon.stub(),
        };
    }
}

describe('UserContract', () => {
    let contract;
    let ctx;

    beforeEach(() => {
        contract = new UserContract();
        ctx = new TestContext();
        ctx.stub.getState
            .withArgs('usr-001')
            .resolves(
                Buffer.from(
                    '{"userId":"usr-001","userName":"Adam","phoneNumber":"1234567890","emailId":"usr001@email.com"}'
                )
            );
        ctx.stub.getState
            .withArgs('usr-002')
            .resolves(
                Buffer.from(
                    '{"userId":"usr-002","userName":"Eve","phoneNumber":"1234567891","emailId":"usr002@email.com"}'
                )
            );

        ctx.clientIdentity = {
            getMSPID: function () {
                return 'UserMSP';
            },
        };
    });

    describe('#userExists', () => {
        it('should return true for a user', async () => {
            await contract.userExists(ctx, 'usr-001').should.eventually.be.true;
        });

        it('should return false for a user that does not exist', async () => {
            await contract.userExists(ctx, 'usr-003').should.eventually.be.false;
        });
    });

    describe('#userRegistrationRequest', () => {
        it('should create a user', async () => {
            await contract.userRegistrationRequest(
                ctx,
                'usr-003',
                'Lucifer',
                '0987654321',
                'usr003@email.com'
            );
            ctx.stub.putState.should.have.been.calledOnceWithExactly(
                'usr-003',
                Buffer.from(
                    '{"userId":"usr-003","userName":"Lucifer","phoneNumber":"0987654321","emailId":"usr003@email.com"}'
                )
            );
        });

        it('should throw an error for a user that already exists', async () => {
            await contract
                .userRegistrationRequest(
                    ctx,
                    'usr-001',
                    'Adam',
                    '1234567890',
                    'usr001@email.com'
                )
                .should.be.rejectedWith(/The user usr-001 already exists/);
        });
    });

    describe('#viewUser', () => {
        it('should return a user', async () => {
            await contract.viewUser(ctx, 'usr-002').should.eventually.deep.equal({
                userId:"usr-002",
                userName:"Eve",
                phoneNumber:"1234567891",
                emailId:"usr002@email.com",
            });
        });

        it('should throw an error for a user that does not exist', async () => {
            await contract
                .viewUser(ctx, 'usr-003')
                .should.be.rejectedWith(/The user usr-003 does not exist/);
        });
    });

});
