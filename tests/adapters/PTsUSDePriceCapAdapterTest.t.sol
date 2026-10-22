// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {IPendlePriceCapAdapter, ICLSynchronicityPriceAdapter, IChainlinkAggregator} from '../../src/interfaces/IPendlePriceCapAdapter.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';

/// @dev The discount rates asserted below are the PT-sUSDe-22OCT2026 values, used as placeholders
/// until LlamaRisk publishes the final rates for the 28JAN2027 maturity.
contract PTsUSDe28JAN2027PlasmaTest is Test {
  uint256 internal constant FORK_BLOCK = 35734145;
  uint256 internal constant MATURITY_28JAN2027 = 1801094400;
  uint64 internal constant PLACEHOLDER_DISCOUNT_RATE = 0.0437e18;
  uint64 internal constant PLACEHOLDER_MAX_DISCOUNT_RATE = 0.1227e18;

  IPendlePriceCapAdapter internal adapter;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), FORK_BLOCK);
    adapter = IPendlePriceCapAdapter(
      GovV3Helpers.deployDeterministic(CapAdaptersCodePlasma.ptSUSDeJanuary2027AdapterCode())
    );
  }

  function test_configuration() public view {
    assertEq(
      ICLSynchronicityPriceAdapter(address(adapter)).description(),
      'PT Capped sUSDe USDT/USD linear discount 28JAN2027'
    );
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.MATURITY(), MATURITY_28JAN2027);
    assertEq(
      address(adapter.PENDLE_PRINCIPAL_TOKEN()),
      0x257561233419039BeC3a28be717d14B4f490883D,
      'oracle should price PT-sUSDe-28JAN2027'
    );
    assertEq(address(adapter.ASSET_TO_USD_AGGREGATOR()), AaveV3PlasmaAssets.USDT0_ORACLE);
    assertEq(address(adapter.ACL_MANAGER()), address(AaveV3Plasma.ACL_MANAGER));
    assertEq(adapter.discountRatePerYear(), PLACEHOLDER_DISCOUNT_RATE);
    assertEq(adapter.MAX_DISCOUNT_RATE_PER_YEAR(), PLACEHOLDER_MAX_DISCOUNT_RATE);
  }

  function test_latestAnswer() public view {
    int256 referencePrice = IChainlinkAggregator(AaveV3PlasmaAssets.USDT0_ORACLE).latestAnswer();
    uint256 timeToMaturity = MATURITY_28JAN2027 - block.timestamp;
    uint256 expectedDiscount = (timeToMaturity * uint256(PLACEHOLDER_DISCOUNT_RATE)) / 365 days;
    uint256 expectedPrice = (uint256(referencePrice) * (1e18 - expectedDiscount)) / 1e18;

    int256 price = adapter.latestAnswer();

    assertEq(uint256(price), expectedPrice);
    assertGt(price, 0.985e8);
    assertLt(price, 0.99e8);
  }
}
