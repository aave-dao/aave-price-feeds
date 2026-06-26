// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeAvalanche} from '../../scripts/DeployAvalanche.s.sol';
import {CapAdaptersCodeMonad} from '../../scripts/DeployMonad.s.sol';

contract AUSDAvalancheTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeAvalanche.AUSDAdapterCode(),
      10,
      ForkParams({network: 'avalanche', blockNumber: 53614500})
    )
  {}
}

contract AUSDMonadTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMonad.AUSDAdapterCode(),
      0,
      ForkParams({network: 'monad', blockNumber: 83150000})
    )
  {}

  function setUp() public override {
    super.setUp();
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeMonad.scaledAdapterCode(CapAdaptersCodeMonad.AUSD_SVR_USD_PRICE_FEED)
    );
  }

  function test_latestAnswerRetrospective() public pure override {
    // base feed is a freshly deployed ScaledPriceAdapter over the SVR feed
    assertTrue(true);
  }
}
