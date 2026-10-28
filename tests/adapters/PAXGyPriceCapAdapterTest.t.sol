// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {PAXGyPriceCapAdapter} from '../../src/contracts/lst-adapters/PAXGyPriceCapAdapter.sol';
import {IPAXGyAccountant} from '../../src/interfaces/IPAXGyAccountant.sol';
import {CapAdaptersCodeEthereum, AaveV3Ethereum} from '../../scripts/DeployEthereum.s.sol';

contract PAXGyEthereumTest is BaseTest {
  IPAXGyAccountant internal constant ACCOUNTANT =
    IPAXGyAccountant(CapAdaptersCodeEthereum.PAXGy_ACCOUNTANT);

  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.PAXGyAdapterCode(),
      // Limited to available rate history, including the 7-day window before the first sample.
      23,
      ForkParams({network: 'mainnet', blockNumber: 26247073}),
      'PAXGy_Ethereum'
    )
  {}

  function test_nativeRateAndConfiguration() public {
    IPriceCapAdapter adapter = _createAdapter();

    assertEq(ACCOUNTANT.vault(), 0x6c6494Fd9962eB98B94ffA48F6679058F820700e);
    // The accountant denominates the rate in its XAU stand-in, rather than the PAXG token.
    assertEq(ACCOUNTANT.base(), 0x130493BCD68Ca6aE7b15566A757Bd6699D73467D);
    assertEq(ACCOUNTANT.decimals(), 18);
    assertEq(adapter.RATIO_DECIMALS(), ACCOUNTANT.decimals());
    assertEq(adapter.getRatio(), int256(ACCOUNTANT.getRate()));
    assertEq(address(adapter.ACL_MANAGER()), address(AaveV3Ethereum.ACL_MANAGER));
    assertEq(adapter.RATIO_PROVIDER(), address(ACCOUNTANT));
    assertEq(address(adapter.BASE_TO_USD_AGGREGATOR()), 0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6);
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.getSnapshotRatio(), 1_001317899581791979);
    assertEq(adapter.getSnapshotTimestamp(), 1791136619);
    assertEq(adapter.MINIMUM_SNAPSHOT_DELAY(), 7 days);
    assertEq(adapter.getMaxYearlyGrowthRatePercent(), 6_00);
    assertEq(adapter.description(), 'Capped PAXGy / XAU / USD');
    assertEq(
      adapter.latestAnswer(),
      (int256(ACCOUNTANT.getRate()) * adapter.BASE_TO_USD_AGGREGATOR().latestAnswer()) / 1e18
    );
  }

  function test_accountantPauseKeepsLastRate() public {
    IPriceCapAdapter adapter = _createAdapter();
    uint256 rateBefore = ACCOUNTANT.getRate();
    int256 priceBefore = adapter.latestAnswer();

    vm.prank(ACCOUNTANT.owner());
    ACCOUNTANT.pause();
    assertEq(ACCOUNTANT.getRate(), rateBefore);

    vm.expectRevert(bytes4(keccak256('AccountantWithRateProviders__Paused()')));
    ACCOUNTANT.getRateSafe();
    assertEq(adapter.getRatio(), int256(rateBefore));
    assertEq(adapter.latestAnswer(), priceBefore);
    assertFalse(adapter.isCapped());
  }

  function test_outOfBoundsUpdateKeepsLastRate() public {
    skip(1 days);
    IPriceCapAdapter adapter = _createAdapter();
    uint256 rateBefore = ACCOUNTANT.getRate();
    int256 priceBefore = adapter.latestAnswer();

    vm.prank(ACCOUNTANT.owner());
    ACCOUNTANT.updateExchangeRate(type(uint96).max);

    vm.expectRevert(bytes4(keccak256('AccountantWithRateProviders__Paused()')));
    ACCOUNTANT.getRateSafe();
    assertEq(ACCOUNTANT.getRate(), rateBefore);
    assertEq(adapter.getRatio(), int256(rateBefore));
    assertEq(adapter.latestAnswer(), priceBefore);
    assertFalse(adapter.isCapped());
  }

  function test_downwardUpdateKeepsLastRate() public {
    skip(1 days);
    IPriceCapAdapter adapter = _createAdapter();
    uint256 rateBefore = ACCOUNTANT.getRate();
    int256 priceBefore = adapter.latestAnswer();

    vm.prank(ACCOUNTANT.owner());
    ACCOUNTANT.updateExchangeRate(uint96(rateBefore - 1));

    vm.expectRevert(bytes4(keccak256('AccountantWithRateProviders__Paused()')));
    ACCOUNTANT.getRateSafe();
    assertEq(ACCOUNTANT.getRate(), rateBefore);
    assertEq(adapter.getRatio(), int256(rateBefore));
    assertEq(adapter.latestAnswer(), priceBefore);
    assertFalse(adapter.isCapped());
  }

  function test_publishedSnapshotMatchesAccountant() public {
    vm.createSelectFork(vm.rpcUrl(forkParams.network), 26120629);
    assertEq(block.timestamp, 1791136619);
    assertEq(ACCOUNTANT.getRate(), 1_001317899581791979);
  }

  function test_capBoundary() public {
    IPriceCapAdapter adapter = _createAdapter();
    uint256 maxRatio = adapter.getSnapshotRatio() +
      (adapter.getMaxRatioGrowthPerSecondScaled() *
        (block.timestamp - adapter.getSnapshotTimestamp())) /
      adapter.SCALING_FACTOR();
    int256 goldPrice = adapter.BASE_TO_USD_AGGREGATOR().latestAnswer();

    _mockRatioProviderRate(maxRatio);
    assertFalse(adapter.isCapped());
    assertEq(adapter.latestAnswer(), (goldPrice * int256(maxRatio)) / 1e18);

    _mockRatioProviderRate(maxRatio + 1);
    assertTrue(adapter.isCapped());
    assertEq(adapter.latestAnswer(), (goldPrice * int256(maxRatio)) / 1e18);
  }

  function test_rateDecreaseIsNotFloored() public {
    IPriceCapAdapter adapter = _createAdapter();
    uint256 reducedRate = 0.99e18;
    _mockRatioProviderRate(reducedRate);

    assertFalse(adapter.isCapped());
    assertEq(adapter.getRatio(), int256(reducedRate));
    assertEq(
      adapter.latestAnswer(),
      (adapter.BASE_TO_USD_AGGREGATOR().latestAnswer() * int256(reducedRate)) / 1e18
    );
  }

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new PAXGyPriceCapAdapter(capAdapterParams);
  }

  function _mockRatioProviderRate(uint256 amount) internal override {
    vm.mockCall(
      address(ACCOUNTANT),
      abi.encodeWithSelector(IPAXGyAccountant.getRate.selector),
      abi.encode(amount)
    );
  }
}
