// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {AaveV3BNB, AaveV3BNBAssets} from 'aave-address-book/AaveV3BNB.sol';
import {ChainlinkBNB} from 'aave-address-book/ChainlinkBNB.sol';
import {AggregatorInterface} from '../../src/interfaces/AggregatorInterface.sol';
import {IScaledPriceAdapter} from '../../src/interfaces/IScaledPriceAdapter.sol';
import {CapAdaptersCodeBNB} from '../../scripts/DeployBnb.s.sol';

contract ScaledSvrBnbTest is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('bnb'), 126090000);
  }

  function test_scaledAdapters() public {
    address[7] memory feeds = [
      ChainlinkBNB.SVR_BNB__USD,
      ChainlinkBNB.SVR_BTC__USD,
      ChainlinkBNB.SVR_ETH__USD,
      ChainlinkBNB.SVR_CAKE__USD,
      ChainlinkBNB.SVR_USDT__USD,
      ChainlinkBNB.SVR_USDC__USD,
      ChainlinkBNB.SVR_FDUSD__USD
    ];

    for (uint256 i; i < feeds.length; i++) {
      IScaledPriceAdapter adapter = IScaledPriceAdapter(
        GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.scaledAdapterCode(feeds[i]))
      );
      AggregatorInterface feed = AggregatorInterface(feeds[i]);

      assertEq(feed.decimals(), 18);
      assertEq(adapter.decimals(), 8);
      assertGt(adapter.latestAnswer(), 0);
      assertEq(adapter.latestAnswer(), feed.latestAnswer() / 1e10);
    }
  }

  /// @dev AaveOracle does not normalize decimals (BASE_CURRENCY_UNIT = 1e8): a raw 18-dec SVR feed
  /// misprices the asset by 1e10, the scaled adapter reports the same price as the current source.
  function test_oracleRequiresScaledFeeds() public {
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
      ChainlinkBNB.SVR_BNB__USD,
      ChainlinkBNB.SVR_BTC__USD,
      ChainlinkBNB.SVR_ETH__USD,
      ChainlinkBNB.SVR_CAKE__USD,
      ChainlinkBNB.SVR_USDT__USD,
      ChainlinkBNB.SVR_USDC__USD,
      ChainlinkBNB.SVR_FDUSD__USD
    ];

    assertEq(AaveV3BNB.ORACLE.BASE_CURRENCY_UNIT(), 1e8);

    for (uint256 i; i < assets.length; i++) {
      uint256 current = AaveV3BNB.ORACLE.getAssetPrice(assets[i]);

      _setSource(assets[i], feeds[i]);
      assertApproxEqRel(AaveV3BNB.ORACLE.getAssetPrice(assets[i]), current * 1e10, 0.01e18);

      _setSource(
        assets[i],
        GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.scaledAdapterCode(feeds[i]))
      );
      assertApproxEqRel(AaveV3BNB.ORACLE.getAssetPrice(assets[i]), current, 0.01e18);
    }
  }

  /// @dev the capped wrappers, with their scaled base feeds deployed, price like the current sources
  function test_oracleWithCappedAdapters() public {
    address[4] memory assets = [
      AaveV3BNBAssets.USDT_UNDERLYING,
      AaveV3BNBAssets.USDC_UNDERLYING,
      AaveV3BNBAssets.FDUSD_UNDERLYING,
      AaveV3BNBAssets.wstETH_UNDERLYING
    ];
    address[4] memory feeds = [
      ChainlinkBNB.SVR_USDT__USD,
      ChainlinkBNB.SVR_USDC__USD,
      ChainlinkBNB.SVR_FDUSD__USD,
      ChainlinkBNB.SVR_ETH__USD
    ];
    bytes[4] memory wrappers = [
      CapAdaptersCodeBNB.USDTAdapterCode(),
      CapAdaptersCodeBNB.USDCAdapterCode(),
      CapAdaptersCodeBNB.FDUSDAdapterCode(),
      CapAdaptersCodeBNB.wstETHSvrAdapterCode()
    ];

    for (uint256 i; i < assets.length; i++) {
      uint256 current = AaveV3BNB.ORACLE.getAssetPrice(assets[i]);

      GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.scaledAdapterCode(feeds[i]));
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
