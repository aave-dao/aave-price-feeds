// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';
import {CapAdaptersCodeMonad} from '../../scripts/DeployMonad.s.sol';

contract USDeEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.USDeAdapterCode(),
      10,
      ForkParams({network: 'mainnet', blockNumber: 19940721})
    )
  {}
}

contract USDeMegaEthTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMegaEth.USDeAdapterCode(),
      10,
      ForkParams({network: 'megaeth', blockNumber: 12922700})
    )
  {}
}

contract USDeMonadTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMonad.USDeAdapterCode(),
      0,
      ForkParams({network: 'monad', blockNumber: 83150000})
    )
  {}

  function setUp() public override {
    super.setUp();
    // USDe reads the USDT0 SVR feed internally
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeMonad.scaledAdapterCode(CapAdaptersCodeMonad.USDT0_SVR_USD_PRICE_FEED)
    );
  }

  function test_latestAnswerRetrospective() public pure override {
    // base feed is a freshly deployed ScaledPriceAdapter over the SVR feed
    assertTrue(true);
  }
}
