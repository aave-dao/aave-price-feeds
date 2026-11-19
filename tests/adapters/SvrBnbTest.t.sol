// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {AaveV3BNB, AaveV3BNBAssets} from 'aave-address-book/AaveV3BNB.sol';
import {AggregatorInterface} from '../../src/interfaces/AggregatorInterface.sol';
import {CapAdaptersCodeBNB} from '../../scripts/DeployBnb.s.sol';

contract SvrBnbTest is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('bnb'), 126090000);
  }

  /// @dev the SVR feeds can be used directly as sources: same decimals and price as the current ones
  function test_oracleWithSvrFeeds() public {
    address[7] memory assets = [
      AaveV3BNBAssets.WBNB_UNDERLYING,
      AaveV3BNBAssets.BTCB_UNDERLYING,
      AaveV3BNBAssets.ETH_UNDERLYING,
      AaveV3BNBAssets.Cake_UNDERLYING,
      AaveV3BNBAssets.USDT_UNDERLYING,
      AaveV3BNBAssets.USDC_UNDERLYING,
      AaveV3BNBAssets.FDUSD_UNDERLYING
    ];
    address[7] memory feeds = [
      CapAdaptersCodeBNB.SVR_BNB_USD,
      CapAdaptersCodeBNB.SVR_BTC_USD,
      CapAdaptersCodeBNB.SVR_ETH_USD,
      CapAdaptersCodeBNB.SVR_CAKE_USD,
      CapAdaptersCodeBNB.SVR_USDT_USD,
      CapAdaptersCodeBNB.SVR_USDC_USD,
      CapAdaptersCodeBNB.SVR_FDUSD_USD
    ];

    assertEq(AaveV3BNB.ORACLE.BASE_CURRENCY_UNIT(), 1e8);

    for (uint256 i; i < assets.length; i++) {
      assertEq(AggregatorInterface(feeds[i]).decimals(), 8);

      uint256 current = AaveV3BNB.ORACLE.getAssetPrice(assets[i]);
      _setSource(assets[i], feeds[i]);
      assertApproxEqRel(AaveV3BNB.ORACLE.getAssetPrice(assets[i]), current, 0.01e18);
    }
  }

  /// @dev the capped wrappers over the SVR feeds price like the current sources
  function test_oracleWithCappedAdapters() public {
    address[4] memory assets = [
      AaveV3BNBAssets.USDT_UNDERLYING,
      AaveV3BNBAssets.USDC_UNDERLYING,
      AaveV3BNBAssets.FDUSD_UNDERLYING,
      AaveV3BNBAssets.wstETH_UNDERLYING
    ];
    bytes[4] memory wrappers = [
      CapAdaptersCodeBNB.USDTSvrAdapterCode(),
      CapAdaptersCodeBNB.USDCSvrAdapterCode(),
      CapAdaptersCodeBNB.FDUSDSvrAdapterCode(),
      CapAdaptersCodeBNB.wstETHSvrAdapterCode()
    ];

    for (uint256 i; i < assets.length; i++) {
      uint256 current = AaveV3BNB.ORACLE.getAssetPrice(assets[i]);
      _setSource(assets[i], GovV3Helpers.deployDeterministic(wrappers[i]));
      assertApproxEqRel(AaveV3BNB.ORACLE.getAssetPrice(assets[i]), current, 0.01e18);
    }
  }

  function _setSource(address asset, address source) internal {
    address[] memory assets = new address[](1);
    address[] memory sources = new address[](1);
    assets[0] = asset;
    sources[0] = source;

    vm.prank(AaveV3BNB.ACL_ADMIN);
    AaveV3BNB.ORACLE.setAssetSources(assets, sources);
  }
}
