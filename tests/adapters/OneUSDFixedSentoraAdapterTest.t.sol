// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';

import {OneUSDFixedAdapter} from '../../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';
import {CapAdaptersCodeEthereumSentora} from '../../scripts/DeployEthereumSentora.s.sol';

contract OneUSDFixedEthereumSentoraTest is Test {
  OneUSDFixedAdapter adapter;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26147000);
    adapter = OneUSDFixedAdapter(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.oneUSDFixedAdapterCode())
    );
  }

  function test_latestAnswer() external view {
    assertEq(adapter.latestAnswer(), 1e8);
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.description(), 'ONE USD');
  }
}
