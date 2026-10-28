// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {OneUSDFixedAdapter} from '../../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';

contract OneUSDFixedAdapterAvalancheTest is Test {
  OneUSDFixedAdapter constant adapter =
    OneUSDFixedAdapter(0xCcE4d712CA51098e89F26f79F114132942DE9134);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 98723074);
  }

  function test_deployedBytecode() external view {
    assertEq(address(adapter).code, type(OneUSDFixedAdapter).runtimeCode);
  }

  function test_latestAnswer() external view {
    assertEq(adapter.latestAnswer(), 1e8);
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.description(), 'ONE USD');
  }
}
