// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {BNBScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3BNB, AaveV3BNBAssets} from 'aave-address-book/AaveV3BNB.sol';
import {ChainlinkBNB} from 'aave-address-book/ChainlinkBNB.sol';

import {PriceCapAdapterStable, IPriceCapAdapterStable, IChainlinkAggregator} from '../src/contracts/PriceCapAdapterStable.sol';
import {ScaledPriceAdapter} from '../src/contracts/misc-adapters/ScaledPriceAdapter.sol';
import {CLRatePriceCapAdapter, IPriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {BNBxPriceCapAdapter} from '../src/contracts/lst-adapters/BNBxPriceCapAdapter.sol';

library CapAdaptersCodeBNB {
  address public constant wstETH_stETH_AGGREGATOR = 0x4c75d01cfa4D998770b399246400a6dc40FB9645;
  address public constant BNBx_STAKE_MANAGER_V2 = 0x3b961e83400D51e6E1AF5c450d3C7d7b80588d28;

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

  /// @dev Wraps an 18-dec SVR feed so it reports the standard 8-dec USD price.
  function scaledAdapterCode(address svrFeed) internal pure returns (bytes memory) {
    return abi.encodePacked(type(ScaledPriceAdapter).creationCode, abi.encode(svrFeed));
  }

  function wstETHSvrAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3BNB.ACL_MANAGER,
            baseAggregatorAddress: GovV3Helpers.predictDeterministicAddress(
              scaledAdapterCode(ChainlinkBNB.SVR_ETH__USD)
            ),
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
            assetToUsdAggregator: IChainlinkAggregator(
              GovV3Helpers.predictDeterministicAddress(
                scaledAdapterCode(ChainlinkBNB.SVR_USDT__USD)
              )
            ),
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
            assetToUsdAggregator: IChainlinkAggregator(
              GovV3Helpers.predictDeterministicAddress(
                scaledAdapterCode(ChainlinkBNB.SVR_USDC__USD)
              )
            ),
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
            assetToUsdAggregator: IChainlinkAggregator(
              GovV3Helpers.predictDeterministicAddress(
                scaledAdapterCode(ChainlinkBNB.SVR_FDUSD__USD)
              )
            ),
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

contract DeployScaledBNBSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_BNB__USD)
    );
  }
}

contract DeployScaledBTCBSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_BTC__USD)
    );
  }
}

contract DeployScaledETHSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_ETH__USD)
    );
  }
}

contract DeployScaledCAKESvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_CAKE__USD)
    );
  }
}

contract DeployScaledUSDTSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_USDT__USD)
    );
  }
}

contract DeployScaledUSDCSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_USDC__USD)
    );
  }
}

contract DeployScaledFDUSDSvrBnb is BNBScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeBNB.scaledAdapterCode(ChainlinkBNB.SVR_FDUSD__USD)
    );
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
