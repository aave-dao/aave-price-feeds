// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {IPriceCapAdapter} from '../../src/interfaces/IPriceCapAdapter.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {CapAdaptersCodeEthereumSentora} from '../../scripts/DeployEthereumSentora.s.sol';

contract PSTEthereumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeEthereumSentora.PSTAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 26147000}),
      'PST_Ethereum'
    )
  {}

  function setUp() public override {
    super.setUp();
    // the USDC base and the scaled ratio feed are not deployed yet, keep them across the retrospective forks
    vm.makePersistent(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.USDCAdapterCode())
    );
    vm.makePersistent(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.PSTRatioScaledAdapterCode())
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
      GovV3Helpers.predictDeterministicAddress(CapAdaptersCodeEthereumSentora.USDCAdapterCode())
    );
    assertEq(
      adapter.RATIO_PROVIDER(),
      GovV3Helpers.predictDeterministicAddress(
        CapAdaptersCodeEthereumSentora.PSTRatioScaledAdapterCode()
      )
    );
  }
}
