// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';

import {OneUSDFixedAdapter} from '../../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';
import {FixedPriceAdapter} from '../../src/contracts/misc-adapters/FixedPriceAdapter.sol';
import {CapAdaptersCodeMonad} from '../../scripts/DeployMonad.s.sol';

contract GhoMonadTest is Test {
  OneUSDFixedAdapter adapter;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('monad'), 83550000);
    adapter = OneUSDFixedAdapter(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.ghoFixedAdapterCode())
    );
  }

  function test_latestAnswer() external view {
    assertEq(adapter.latestAnswer(), 1e8);
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.description(), 'ONE USD');
  }
}

contract mUSDMonadTest is Test {
  FixedPriceAdapter adapter;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('monad'), 83550000);
    adapter = FixedPriceAdapter(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.fixedMUsdAdapterCode())
    );
  }

  function test_latestAnswer() external view {
    assertEq(adapter.latestAnswer(), 1e8);
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.description(), 'Fixed mUSD/USD');
  }
}
