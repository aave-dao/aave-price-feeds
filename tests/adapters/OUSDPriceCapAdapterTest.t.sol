// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {CapAdaptersCodeEthereumSentora} from '../../scripts/DeployEthereumSentora.s.sol';

contract OUSDEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereumSentora.OUSDAdapterCode(),
      7, // the OUSD / USD feed went live on 2026-09-30
      ForkParams({network: 'mainnet', blockNumber: 26147000})
    )
  {}

  function test_sources() external {
    IPriceCapAdapterStable adapter = _createAdapter();
    assertEq(
      address(adapter.ACL_MANAGER()),
      address(CapAdaptersCodeEthereumSentora.SENTORA_ACL_MANAGER)
    );
    assertEq(
      address(adapter.ASSET_TO_USD_AGGREGATOR()),
      CapAdaptersCodeEthereumSentora.OUSD_PRICE_FEED
    );
  }
}
