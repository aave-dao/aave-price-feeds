// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {WOUSDPriceCapAdapter} from '../../src/contracts/lst-adapters/WOUSDPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

/// @dev the base is the Chainlink OUSD / USD feed, which prices Open USD and not Origin Dollar (the wOUSD underlying)
contract wOUSDEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.wOUSDAdapterCode(),
      7, // the OUSD / USD feed went live on 2026-09-30
      ForkParams({network: 'mainnet', blockNumber: 26147000}),
      'wOUSD_Ethereum'
    )
  {}

  function setUp() public override {
    super.setUp();
    // the capped OUSD base is not deployed yet, keep it across the retrospective forks
    vm.makePersistent(GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereum.OUSDAdapterCode()));
  }

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new WOUSDPriceCapAdapter(capAdapterParams);
  }
}
