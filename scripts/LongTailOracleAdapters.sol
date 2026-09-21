// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {FixedPriceAdapter} from '../src/contracts/misc-adapters/FixedPriceAdapter.sol';
import {CLSynchronicityPriceAdapterBaseToPeg} from '../src/contracts/CLSynchronicityPriceAdapterBaseToPeg.sol';
import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';
import {AaveV3Celo} from 'aave-address-book/AaveV3Celo.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumEtherFi} from 'aave-address-book/AaveV3EthereumEtherFi.sol';
import {AaveV3Optimism} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveV3Scroll} from 'aave-address-book/AaveV3Scroll.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {ChainlinkPolygon} from 'aave-address-book/ChainlinkPolygon.sol';

/// @dev Prices from the September 16, 2026 specification:
/// https://governance.aave.com/t/25400
/// V2 uses the chain's V3 Core ACL and divides the fixed USD target by live ETH/USD.
library LongTailOracleAdapters {
  struct Spec {
    string market;
    string symbol;
    uint256 price;
    address acl;
    address ethUsd;
  }

  function specs(uint256 chain) internal pure returns (Spec[] memory result) {
    if (chain == 1) {
      result = new Spec[](21);
      result[0] = Spec(
        'AaveV2Ethereum',
        'AMPL',
        123960000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[1] = Spec(
        'AaveV2Ethereum',
        'BAL',
        13170000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[2] = Spec(
        'AaveV2Ethereum',
        'ENJ',
        4610000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[3] = Spec(
        'AaveV2Ethereum',
        'FRAX',
        100000000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[4] = Spec(
        'AaveV2Ethereum',
        'KNC',
        14010000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[5] = Spec(
        'AaveV2Ethereum',
        'LUSD',
        100000000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[6] = Spec(
        'AaveV2Ethereum',
        'RAI',
        265870000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[7] = Spec(
        'AaveV2Ethereum',
        'REN',
        330000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[8] = Spec(
        'AaveV2Ethereum',
        'TUSD',
        100000000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[9] = Spec(
        'AaveV2Ethereum',
        'USDP',
        100000000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[10] = Spec(
        'AaveV2Ethereum',
        'YFI',
        228663680000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[11] = Spec(
        'AaveV2Ethereum',
        'ZRX',
        9810000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[12] = Spec(
        'AaveV2Ethereum',
        'sUSD',
        37800000,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
      result[13] = Spec(
        'AaveV3EthereumEtherFi',
        'FRAX',
        100000000,
        address(AaveV3EthereumEtherFi.ACL_MANAGER),
        address(0)
      );
      result[14] = Spec(
        'AaveV3Ethereum',
        'BAL',
        13370000,
        address(AaveV3Ethereum.ACL_MANAGER),
        address(0)
      );
      result[15] = Spec(
        'AaveV3Ethereum',
        'FRAX',
        100000000,
        address(AaveV3Ethereum.ACL_MANAGER),
        address(0)
      );
      result[16] = Spec(
        'AaveV3Ethereum',
        'FXS',
        35620000,
        address(AaveV3Ethereum.ACL_MANAGER),
        address(0)
      );
      result[17] = Spec(
        'AaveV3Ethereum',
        'KNC',
        14000000,
        address(AaveV3Ethereum.ACL_MANAGER),
        address(0)
      );
      result[18] = Spec(
        'AaveV3Ethereum',
        'LUSD',
        100000000,
        address(AaveV3Ethereum.ACL_MANAGER),
        address(0)
      );
      result[19] = Spec(
        'AaveV3Ethereum',
        'RPL',
        173380000,
        address(AaveV3Ethereum.ACL_MANAGER),
        address(0)
      );
      result[20] = Spec(
        'AaveV3Ethereum',
        'STG',
        27340000,
        address(AaveV3Ethereum.ACL_MANAGER),
        address(0)
      );
      return result;
    }
    if (chain == 137) {
      result = new Spec[](5);
      result[0] = Spec(
        'AaveV2Polygon',
        'BAL',
        12840000,
        address(AaveV3Polygon.ACL_MANAGER),
        ChainlinkPolygon.ETH__USD
      );
      result[1] = Spec(
        'AaveV2Polygon',
        'GHST',
        7930000,
        address(AaveV3Polygon.ACL_MANAGER),
        ChainlinkPolygon.ETH__USD
      );
      result[2] = Spec(
        'AaveV3Polygon',
        'BAL',
        13160000,
        address(AaveV3Polygon.ACL_MANAGER),
        address(0)
      );
      result[3] = Spec(
        'AaveV3Polygon',
        'GHST',
        8280000,
        address(AaveV3Polygon.ACL_MANAGER),
        address(0)
      );
      result[4] = Spec(
        'AaveV3Polygon',
        'miMATIC',
        95300000,
        address(AaveV3Polygon.ACL_MANAGER),
        address(0)
      );
      return result;
    }
    if (chain == 42161) {
      result = new Spec[](3);
      result[0] = Spec(
        'AaveV3Arbitrum',
        'FRAX',
        100000000,
        address(AaveV3Arbitrum.ACL_MANAGER),
        address(0)
      );
      result[1] = Spec(
        'AaveV3Arbitrum',
        'LUSD',
        100000000,
        address(AaveV3Arbitrum.ACL_MANAGER),
        address(0)
      );
      result[2] = Spec(
        'AaveV3Arbitrum',
        'MAI',
        95300000,
        address(AaveV3Arbitrum.ACL_MANAGER),
        address(0)
      );
      return result;
    }
    if (chain == 43114) {
      result = new Spec[](2);
      result[0] = Spec(
        'AaveV3Avalanche',
        'FRAX',
        100000000,
        address(AaveV3Avalanche.ACL_MANAGER),
        address(0)
      );
      result[1] = Spec(
        'AaveV3Avalanche',
        'MAI',
        95300000,
        address(AaveV3Avalanche.ACL_MANAGER),
        address(0)
      );
      return result;
    }
    if (chain == 42220) {
      result = new Spec[](1);
      result[0] = Spec(
        'AaveV3Celo',
        'USDm',
        100000000,
        address(AaveV3Celo.ACL_MANAGER),
        address(0)
      );
      return result;
    }
    if (chain == 10) {
      result = new Spec[](3);
      result[0] = Spec(
        'AaveV3Optimism',
        'LUSD',
        100000000,
        address(AaveV3Optimism.ACL_MANAGER),
        address(0)
      );
      result[1] = Spec(
        'AaveV3Optimism',
        'MAI',
        95300000,
        address(AaveV3Optimism.ACL_MANAGER),
        address(0)
      );
      result[2] = Spec(
        'AaveV3Optimism',
        'sUSD',
        30290000,
        address(AaveV3Optimism.ACL_MANAGER),
        address(0)
      );
      return result;
    }
    if (chain == 534352) {
      result = new Spec[](1);
      result[0] = Spec(
        'AaveV3Scroll',
        'SCR',
        3350000,
        address(AaveV3Scroll.ACL_MANAGER),
        address(0)
      );
      return result;
    }
    revert('UNSUPPORTED_CHAIN');
  }

  function fixedCode(Spec memory s) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(FixedPriceAdapter).creationCode,
        abi.encode(s.acl, uint8(8), int256(s.price), string.concat('Fixed ', s.symbol, '/USD'))
      );
  }

  function conversionCode(Spec memory s, address fixedFeed) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLSynchronicityPriceAdapterBaseToPeg).creationCode,
        abi.encode(s.ethUsd, fixedFeed, uint8(18), string.concat(s.symbol, '/ETH fixed USD target'))
      );
  }

  function addresses(Spec memory s) internal pure returns (address fixedFeed, address oracle) {
    fixedFeed = GovV3Helpers.predictDeterministicAddress(fixedCode(s));
    oracle = s.ethUsd == address(0)
      ? fixedFeed
      : GovV3Helpers.predictDeterministicAddress(conversionCode(s, fixedFeed));
  }

  function deploy(Spec memory s) internal returns (address fixedFeed, address oracle) {
    fixedFeed = GovV3Helpers.deployDeterministic(fixedCode(s));
    oracle = s.ethUsd == address(0)
      ? fixedFeed
      : GovV3Helpers.deployDeterministic(conversionCode(s, fixedFeed));
  }

  function deployAll(uint256 chain) internal {
    Spec[] memory rows = specs(chain);
    for (uint256 i; i < rows.length; i++) {
      deploy(rows[i]);
    }
  }
}
