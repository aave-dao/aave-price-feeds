// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {Test} from 'forge-std/Test.sol';
import {LongTailOracleAdapters, FixedPriceAdapter, CLSynchronicityPriceAdapterBaseToPeg} from '../scripts/LongTailOracleAdapters.sol';
import {IFixedPriceAdapter} from '../src/interfaces/IFixedPriceAdapter.sol';
import {IChainlinkAggregator} from '../src/interfaces/IChainlinkAggregator.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3Celo} from 'aave-address-book/GovernanceV3Celo.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';

contract LongTailOracleAdaptersTest is Test {
  function check(string memory alias_, uint256 chain, address executor) internal {
    vm.createSelectFork(vm.rpcUrl(alias_));
    LongTailOracleAdapters.Spec[] memory rows = LongTailOracleAdapters.specs(chain);
    for (uint256 i; i < rows.length; i++) {
      LongTailOracleAdapters.Spec memory s = rows[i];
      (address expectedFixed, address expectedOracle) = LongTailOracleAdapters.addresses(s);
      if (vm.envOr('CHECK_DEPLOYED', false)) {
        assertGt(expectedFixed.code.length, 0, 'FIXED_FEED_NOT_DEPLOYED');
        assertGt(expectedOracle.code.length, 0, 'ORACLE_NOT_DEPLOYED');
      }
      (address fixedFeed, address oracle) = LongTailOracleAdapters.deploy(s);
      assertEq(fixedFeed, expectedFixed);
      assertEq(oracle, expectedOracle);
      FixedPriceAdapter f = FixedPriceAdapter(fixedFeed);
      assertEq(f.latestAnswer(), int256(s.price));
      assertEq(f.decimals(), 8);
      assertEq(address(f.ACL_MANAGER()), s.acl);
      assertTrue(f.ACL_MANAGER().isPoolAdmin(executor));
      if (s.ethUsd == address(0)) {
        assertEq(oracle, fixedFeed);
      } else {
        CLSynchronicityPriceAdapterBaseToPeg o = CLSynchronicityPriceAdapterBaseToPeg(oracle);
        assertEq(address(o.BASE_TO_PEG()), s.ethUsd);
        assertEq(address(o.ASSET_TO_PEG()), fixedFeed);
        assertEq(o.decimals(), 18);
        int256 ethPrice = IChainlinkAggregator(s.ethUsd).latestAnswer();
        assertEq(o.latestAnswer(), (int256(s.price) * 1e18) / ethPrice);
        vm.mockCall(
          s.ethUsd,
          abi.encodeWithSelector(IChainlinkAggregator.latestAnswer.selector),
          abi.encode(ethPrice * 2)
        );
        assertEq(o.latestAnswer(), (int256(s.price) * 1e18) / (ethPrice * 2));
        vm.clearMockedCalls();
      }
      (address againFixed, address againOracle) = LongTailOracleAdapters.deploy(s);
      assertEq(againFixed, fixedFeed);
      assertEq(againOracle, oracle);
      vm.expectRevert(IFixedPriceAdapter.CallerIsNotPoolAdmin.selector);
      f.setPrice(int256(s.price + 1));
      vm.prank(executor);
      f.setPrice(int256(s.price + 1));
      assertEq(f.price(), int256(s.price + 1));
      vm.prank(executor);
      f.setPrice(int256(s.price));
    }
  }

  function test_Ethereum() public {
    check('mainnet', 1, GovernanceV3Ethereum.EXECUTOR_LVL_1);
  }

  function test_Polygon() public {
    check('polygon', 137, GovernanceV3Polygon.EXECUTOR_LVL_1);
  }

  function test_Arbitrum() public {
    check('arbitrum', 42161, GovernanceV3Arbitrum.EXECUTOR_LVL_1);
  }

  function test_Avalanche() public {
    check('avalanche', 43114, GovernanceV3Avalanche.EXECUTOR_LVL_1);
  }

  function test_Celo() public {
    check('celo', 42220, GovernanceV3Celo.EXECUTOR_LVL_1);
  }

  function test_Optimism() public {
    check('optimism', 10, GovernanceV3Optimism.EXECUTOR_LVL_1);
  }

  function test_Scroll() public {
    check('scroll', 534352, GovernanceV3Scroll.EXECUTOR_LVL_1);
  }
}
