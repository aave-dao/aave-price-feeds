// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {BNBScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3BNB, AaveV3BNBAssets} from 'aave-address-book/AaveV3BNB.sol';
import {ChainlinkBNB} from 'aave-address-book/ChainlinkBNB.sol';

import {PriceCapAdapterStable, IPriceCapAdapterStable, IChainlinkAggregator} from '../src/contracts/PriceCapAdapterStable.sol';
import {CLRatePriceCapAdapter, IPriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {BNBxPriceCapAdapter} from '../src/contracts/lst-adapters/BNBxPriceCapAdapter.sol';

library CapAdaptersCodeBNB {
  address public constant wstETH_stETH_AGGREGATOR = 0x4c75d01cfa4D998770b399246400a6dc40FB9645;
  address public constant BNBx_STAKE_MANAGER_V2 = 0x3b961e83400D51e6E1AF5c450d3C7d7b80588d28;

  // AAVE-specific SVR feeds (8 decimals), not yet in the address book
  address public constant SVR_BTC_USD = 0xb2Fc37a370F002A3e5F5953D7bF805D674855852;
  address public constant SVR_BNB_USD = 0xD4C04c875E599eA7aFbc4C4431a9c5CFB117879d;
  address public constant SVR_USDT_USD = 0x1185A7A74D41F4b3220Cff4b8f4F8F5479bAf1f6;
  address public constant SVR_USDC_USD = 0xC34525FC7c09DC88de9bB789e03467C16Fa66d0D;
  address public constant SVR_ETH_USD = 0x20583d40675F169FAD64c7fF9f3d754607e13ba0;
  address public constant SVR_CAKE_USD = 0xB224ba48D9a9d3A64569C4A77C2c3E05DB1c5407;
  address public constant SVR_FDUSD_USD = 0x1bBaCa01782FC1FC25364c677B7a2a4437DB4f9F;

  function wstETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3BNB.ACL_MANAGER,
            baseAggregatorAddress: AaveV3BNBAssets.ETH_ORACLE,
            ratioProviderAddress: wstETH_stETH_AGGREGATOR,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1179619475032439052,
              snapshotTimestamp: 1727049059, // Sep-22-2024
              maxYearlyRatioGrowthPercent: 9_68
            })
          })
        )
      );
  }

  function BNBxAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(BNBxPriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3BNB.ACL_MANAGER,
            baseAggregatorAddress: AaveV3BNBAssets.WBNB_ORACLE,
            ratioProviderAddress: BNBx_STAKE_MANAGER_V2,
            pairDescription: 'Capped BNBx / BNB / USD',
            minimumSnapshotDelay: 21 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1093544888172635115,
              snapshotTimestamp: 1728396262, // Oct-08-2024
              maxYearlyRatioGrowthPercent: 12_00
            })
          })
        )
      );
  }

  function wstETHSvrAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3BNB.ACL_MANAGER,
            baseAggregatorAddress: SVR_ETH_USD,
            ratioProviderAddress: ChainlinkBNB.wstETH__stETH_Exchange_Rate,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_245173991915781615,
              snapshotTimestamp: 1790696529, // Sep-29-2026 (block: 124742475)
              maxYearlyRatioGrowthPercent: 9_68
            })
          })
        )
      );
  }

  function USDTSvrAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3BNB.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(SVR_USDT_USD),
            adapterDescription: 'Capped USDT/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function USDCSvrAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3BNB.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(SVR_USDC_USD),
            adapterDescription: 'Capped USDC/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function FDUSDSvrAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3BNB.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(SVR_FDUSD_USD),
            adapterDescription: 'Capped FDUSD/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }
}

contract DeployWstEthBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.wstETHAdapterCode());
  }
}

contract DeployBNBxBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.BNBxAdapterCode());
  }
}

contract DeployWstEthSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.wstETHSvrAdapterCode());
  }
}

contract DeployUSDTSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.USDTSvrAdapterCode());
  }
}

contract DeployUSDCSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.USDCSvrAdapterCode());
  }
}

contract DeployFDUSDSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBNB.FDUSDSvrAdapterCode());
  }
}
