// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {IPriceCapAdapter} from '../../src/interfaces/IPriceCapAdapter.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {CapAdaptersCodeEthereumSentora} from '../../scripts/DeployEthereumSentora.s.sol';

contract PRIMEEthereumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeEthereumSentora.PRIMEAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 26147000}),
      'PRIME_Ethereum'
    )
  {}

  function setUp() public override {
    super.setUp();
    // the fixed 1 USD base feed is not deployed yet, keep it across the retrospective forks
    vm.makePersistent(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.oneUSDFixedAdapterCode())
    );
  }

  function test_sources() external {
    IPriceCapAdapter adapter = _createAdapter();
    assertEq(
      address(adapter.ACL_MANAGER()),
      address(CapAdaptersCodeEthereumSentora.SENTORA_ACL_MANAGER)
    );
    assertEq(
      address(adapter.BASE_TO_USD_AGGREGATOR()),
      GovV3Helpers.predictDeterministicAddress(
        CapAdaptersCodeEthereumSentora.oneUSDFixedAdapterCode()
      )
    );
    assertEq(adapter.RATIO_PROVIDER(), CapAdaptersCodeEthereumSentora.PRIME_WYLDS_RATIO_FEED);
  }
}
