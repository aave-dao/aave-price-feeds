// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';

import {OneUSDFixedAdapter} from '../../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';
import {CapAdaptersCodeAvalanche} from '../../scripts/DeployAvalanche.s.sol';

contract OneUSDFixedAdapterAvalancheTest is Test {
  // OneUSDFixedAdapter deployed on Ethereum through the same deterministic factory and salt
  address constant ETHEREUM_ONE_USD_FIXED_ADAPTER = 0xCcE4d712CA51098e89F26f79F114132942DE9134;

  OneUSDFixedAdapter adapter;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 98721530);
    assertEq(ETHEREUM_ONE_USD_FIXED_ADAPTER.code.length, 0);
    adapter = OneUSDFixedAdapter(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeAvalanche.oneUSDFixedAdapterCode())
    );
  }

  function test_sameAddressAsEthereum() external view {
    assertEq(address(adapter), ETHEREUM_ONE_USD_FIXED_ADAPTER);
  }

  function test_latestAnswer() external view {
    assertEq(adapter.latestAnswer(), 1e8);
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.description(), 'ONE USD');
  }
}
