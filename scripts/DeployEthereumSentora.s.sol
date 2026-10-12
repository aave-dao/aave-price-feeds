// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';

import {PriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {OneUSDFixedAdapter} from '../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';
import {ScaledPriceAdapter} from '../src/contracts/misc-adapters/ScaledPriceAdapter.sol';
import {IPriceCapAdapter, IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from '../src/interfaces/IPriceCapAdapterStable.sol';

library CapAdaptersCodeEthereumSentora {
  // TODO: placeholder, replace with the Sentora ACLManager once deployed
  IACLManager public constant SENTORA_ACL_MANAGER =
    IACLManager(0x000000000000000000000000000000000000dEaD);

  address public constant PRIME_WYLDS_RATIO_FEED = 0xf17C0EdcAA28371e9c8012D7699bF40ECF0F58d1;
  address public constant PST_USDC_RATIO_FEED = 0x4BE50bE32dB1510240d542f77c5B36Ca0D0965E6;
  // Open USD 0x9f6F3991D525015a6F8CaF062C83b62fD3AC4436, not Origin Dollar
  address public constant OUSD_PRICE_FEED = 0xaf0311CCc42d22D2624fEC8024119cb71bBc7418;

  function RLUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: SENTORA_ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkEthereum.RLUSD__USD),
            adapterDescription: 'Capped RLUSD / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function PYUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: SENTORA_ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkEthereum.PYUSD__USD),
            adapterDescription: 'Capped PYUSD / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function USDTAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: SENTORA_ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkEthereum.USDT__USD),
            adapterDescription: 'Capped USDT / USD',
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
            aclManager: SENTORA_ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkEthereum.USDC__USD),
            adapterDescription: 'Capped USDC / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function OUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: SENTORA_ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(OUSD_PRICE_FEED),
            adapterDescription: 'Capped OUSD / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function oneUSDFixedAdapterCode() internal pure returns (bytes memory) {
    return abi.encodePacked(type(OneUSDFixedAdapter).creationCode);
  }

  function PRIMEAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: SENTORA_ACL_MANAGER,
            // no wYLDS / USD feed exists, wYLDS is priced at a fixed 1 USD
            baseAggregatorAddress: GovV3Helpers.predictDeterministicAddress(
              oneUSDFixedAdapterCode()
            ),
            ratioProviderAddress: PRIME_WYLDS_RATIO_FEED,
            pairDescription: 'Capped PRIME / wYLDS / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_060963216752411499,
              snapshotTimestamp: 1790224667, // Sep-24-2026
              maxYearlyRatioGrowthPercent: 10_50
            })
          })
        )
      );
  }

  /// @dev the PST / USDC feed has 6 decimals, below the 8 required by the cap adapter
  function PSTRatioScaledAdapterCode() internal pure returns (bytes memory) {
    return abi.encodePacked(type(ScaledPriceAdapter).creationCode, abi.encode(PST_USDC_RATIO_FEED));
  }

  function PSTAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: SENTORA_ACL_MANAGER,
            baseAggregatorAddress: GovV3Helpers.predictDeterministicAddress(USDCAdapterCode()),
            ratioProviderAddress: GovV3Helpers.predictDeterministicAddress(
              PSTRatioScaledAdapterCode()
            ),
            pairDescription: 'Capped PST / USDC / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_13598500,
              snapshotTimestamp: 1790847311, // Oct-01-2026
              maxYearlyRatioGrowthPercent: 12_83
            })
          })
        )
      );
  }
}

contract DeployRLUSDEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.RLUSDAdapterCode());
  }
}

contract DeployPYUSDEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.PYUSDAdapterCode());
  }
}

contract DeployUSDTEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.USDTAdapterCode());
  }
}

contract DeployUSDCEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.USDCAdapterCode());
  }
}

contract DeployOUSDEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.OUSDAdapterCode());
  }
}

contract DeployOneUSDFixedEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.oneUSDFixedAdapterCode());
  }
}

contract DeployPRIMEEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.oneUSDFixedAdapterCode());
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.PRIMEAdapterCode());
  }
}

contract DeployPSTEthereumSentora is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.USDCAdapterCode());
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.PSTRatioScaledAdapterCode());
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumSentora.PSTAdapterCode());
  }
}
