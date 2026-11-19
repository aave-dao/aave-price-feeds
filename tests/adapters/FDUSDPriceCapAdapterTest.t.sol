// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {CapAdaptersCodeBNB} from '../../scripts/DeployBnb.s.sol';

contract FDUSDBnbTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeBNB.FDUSDSvrAdapterCode(),
      0,
      ForkParams({network: 'bnb', blockNumber: 126090000})
    )
  {}
}
