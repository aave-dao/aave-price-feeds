// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {MonadScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Monad} from 'aave-address-book/AaveV3Monad.sol';

import {OneUSDFixedAdapter} from '../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';
import {FixedPriceAdapter} from '../src/contracts/misc-adapters/FixedPriceAdapter.sol';
import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {IPriceCapAdapter, IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';

library CapAdaptersCodeMonad {
  address public constant ETH_USD_PRICE_FEED = 0x1B1414782B859871781bA3E4B0979b9ca57A0A04;
  address public constant cbBTC_USD_PRICE_FEED = 0x3dDc1bAE752aaEe31b577bF844c799C349A1d6BD;
  address public constant MON_USD_PRICE_FEED = 0xBcD78f76005B7515837af6b50c7C52BCf73822fb;
  address public constant USDT_USD_PRICE_FEED = 0x1a1Be4c184923a6BFF8c27cfDf6ac8bDE4DE00FC;
  address public constant USDC_USD_PRICE_FEED = 0xf5F15f188AbCB0d165D1Edb7f37F7d6fA2fCebec;
  address public constant AUSD_USD_PRICE_FEED = 0xE20751C7B5867bCBef815ffc1b284c3f412a9e13;
  address public constant USDe_USD_PRICE_FEED = 0x6b5902EABcE27C23FC97ea136504395b4d22C1FD;
  address public constant sUSDe_USD_MARKET_FEED = 0xB7E7A36A0Fc6543C10f4F9B60E942F1b628f2a13;

  address public constant wstETH_stETH_Exchange_Rate = 0xDBFFF41Aca92EE1d8Cb9Fff6432f345ae64bEF09;
  address public constant weETH_eETH_Exchange_Rate = 0x87DC38591B6e151A7aEc05D8efcCc8f321906C32;

  function USDT0AdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDT_USD_PRICE_FEED),
            adapterDescription: 'Capped USDT0 / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function USDCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDC_USD_PRICE_FEED),
            adapterDescription: 'Capped USDC / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function AUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(AUSD_USD_PRICE_FEED),
            adapterDescription: 'Capped AUSD / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function USDeAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDT_USD_PRICE_FEED),
            adapterDescription: 'Capped USDe / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function ghoFixedAdapterCode() internal pure returns (bytes memory) {
    return abi.encodePacked(type(OneUSDFixedAdapter).creationCode);
  }

  function wstETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            baseAggregatorAddress: ETH_USD_PRICE_FEED,
            ratioProviderAddress: wstETH_stETH_Exchange_Rate,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_237177964998796368,
              snapshotTimestamp: 1781683096, // block 81835000, ~2026-06-17
              maxYearlyRatioGrowthPercent: 9_68
            })
          })
        )
      );
  }

  function weETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            baseAggregatorAddress: ETH_USD_PRICE_FEED,
            ratioProviderAddress: weETH_eETH_Exchange_Rate,
            pairDescription: 'Capped weETH / eETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_097197043704895136,
              snapshotTimestamp: 1781683096, // block 81835000, ~2026-06-17
              maxYearlyRatioGrowthPercent: 8_75
            })
          })
        )
      );
  }

  function sUSDeAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            baseAggregatorAddress: USDe_USD_PRICE_FEED,
            ratioProviderAddress: address(0), // TODO: no sUSDe/USDe exchange-rate feed on Monad
            pairDescription: 'Capped sUSDe / USDe / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 0, // TODO
              snapshotTimestamp: 0, // TODO
              maxYearlyRatioGrowthPercent: 0 // TODO: risk growth cap (L2s use 15_19)
            })
          })
        )
      );
  }

  function syrupUSDCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Monad.ACL_MANAGER,
            baseAggregatorAddress: USDC_USD_PRICE_FEED,
            ratioProviderAddress: address(0), // TODO: syrupUSDC vault rate not exposed on Monad
            pairDescription: 'Capped SyrupUSDC / USDC / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 0, // TODO
              snapshotTimestamp: 0, // TODO
              maxYearlyRatioGrowthPercent: 0 // TODO: risk growth cap (Base uses 8_04)
            })
          })
        )
      );
  }

  function fixedMUsdAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(FixedPriceAdapter).creationCode,
        abi.encode(address(AaveV3Monad.ACL_MANAGER), 8, int256(1 * 1e8), 'Fixed mUSD/USD')
      );
  }
}

contract DeployUSDT0Monad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.USDT0AdapterCode());
  }
}

contract DeployUSDCMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.USDCAdapterCode());
  }
}

contract DeployAUSDMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.AUSDAdapterCode());
  }
}

contract DeployUSDeMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.USDeAdapterCode());
  }
}

contract DeployGhoMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.ghoFixedAdapterCode());
  }
}

contract DeployWstETHMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.wstETHAdapterCode());
  }
}

contract DeployWeETHMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.weETHAdapterCode());
  }
}

contract DeploySUSDeMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.sUSDeAdapterCode());
  }
}

contract DeploySyrupUSDCMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.syrupUSDCAdapterCode());
  }
}

contract DeployFixedMUSDMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.fixedMUsdAdapterCode());
  }
}
