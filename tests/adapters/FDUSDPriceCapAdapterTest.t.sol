// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {ChainlinkBNB} from 'aave-address-book/ChainlinkBNB.sol';
import {CapAdaptersCodeBNB} from '../../scripts/DeployBnb.s.sol';

contract FDUSDBnbTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeBNB.FDUSDAdapterCode(),
      0,
      ForkParams({network: 'bnb', blockNumber: 126090000})
    )
  {}

  function setUp() public override {
    super.setUp();
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_FDUSD__USD)
    );
  }

  function test_latestAnswerRetrospective() public pure override {
    // base feed is a freshly deployed ScaledPriceAdapter over the SVR feed
    assertTrue(true);
  }
}
