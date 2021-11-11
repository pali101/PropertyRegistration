/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const UserContract = require('./lib/userContract.js');
const TxnContract = require('./lib/txn-contract');


module.exports.UserContract = UserContract;
module.exports.TxnContract = TxnContract;
module.exports.contracts = [ UserContract, TxnContract ];
