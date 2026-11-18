// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {console2} from 'forge-std/console2.sol';
import {
  AaveV3EthereumHorizon,
  AaveV3EthereumHorizonAssets
} from 'aave-address-book/AaveV3EthereumHorizon.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';

import {PriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from '../src/interfaces/IPriceCapAdapterStable.sol';

library CapAdaptersCodeEthereumHorizon {
  address public constant RLUSD_PRICE_FEED = AaveV3EthereumHorizonAssets.RLUSD_ORACLE;
  address public constant USDC_PRICE_FEED = AaveV3EthereumHorizonAssets.USDC_ORACLE;

  function RLUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3EthereumHorizon.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(RLUSD_PRICE_FEED),
            adapterDescription: 'Capped RLUSD / USD',
            priceCap: int256(1.02 * 1e8)
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
            aclManager: AaveV3EthereumHorizon.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDC_PRICE_FEED),
            adapterDescription: 'Capped USDC / USD',
            priceCap: int256(1.02 * 1e8)
          })
        )
      );
  }
}

contract DeployRLUSDEthereumHorizon is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumHorizon.RLUSDAdapterCode());
  }
}

contract DeployUSDCEthereumHorizon is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereumHorizon.USDCAdapterCode());
  }
}
