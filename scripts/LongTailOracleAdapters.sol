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
      result[0] = _aaveV2Ethereum('AMPL', 123960000);
      result[1] = _aaveV2Ethereum('BAL', 13170000);
      result[2] = _aaveV2Ethereum('ENJ', 4610000);
      result[3] = _aaveV2Ethereum('FRAX', 100000000);
      result[4] = _aaveV2Ethereum('KNC', 14010000);
      result[5] = _aaveV2Ethereum('LUSD', 100000000);
      result[6] = _aaveV2Ethereum('RAI', 265870000);
      result[7] = _aaveV2Ethereum('REN', 330000);
      result[8] = _aaveV2Ethereum('TUSD', 100000000);
      result[9] = _aaveV2Ethereum('USDP', 100000000);
      result[10] = _aaveV2Ethereum('YFI', 228663680000);
      result[11] = _aaveV2Ethereum('ZRX', 9810000);
      result[12] = _aaveV2Ethereum('sUSD', 37800000);
      result[13] = _aaveV3EthereumEtherFi('FRAX', 100000000);
      result[14] = _aaveV3Ethereum('BAL', 13370000);
      result[15] = _aaveV3Ethereum('FRAX', 100000000);
      result[16] = _aaveV3Ethereum('FXS', 35620000);
      result[17] = _aaveV3Ethereum('KNC', 14000000);
      result[18] = _aaveV3Ethereum('LUSD', 100000000);
      result[19] = _aaveV3Ethereum('RPL', 173380000);
      result[20] = _aaveV3Ethereum('STG', 27340000);
      return result;
    }
    if (chain == 137) {
      result = new Spec[](5);
      result[0] = _aaveV2Polygon('BAL', 12840000);
      result[1] = _aaveV2Polygon('GHST', 7930000);
      result[2] = _aaveV3Polygon('BAL', 13160000);
      result[3] = _aaveV3Polygon('GHST', 8280000);
      result[4] = _aaveV3Polygon('miMATIC', 95300000);
      return result;
    }
    if (chain == 42161) {
      result = new Spec[](3);
      result[0] = _aaveV3Arbitrum('FRAX', 100000000);
      result[1] = _aaveV3Arbitrum('LUSD', 100000000);
      result[2] = _aaveV3Arbitrum('MAI', 95300000);
      return result;
    }
    if (chain == 43114) {
      result = new Spec[](2);
      result[0] = _aaveV3Avalanche('FRAX', 100000000);
      result[1] = _aaveV3Avalanche('MAI', 95300000);
      return result;
    }
    if (chain == 42220) {
      result = new Spec[](1);
      result[0] = _aaveV3Celo('USDm', 100000000);
      return result;
    }
    if (chain == 10) {
      result = new Spec[](3);
      result[0] = _aaveV3Optimism('LUSD', 100000000);
      result[1] = _aaveV3Optimism('MAI', 95300000);
      result[2] = _aaveV3Optimism('sUSD', 30290000);
      return result;
    }
    if (chain == 534352) {
      result = new Spec[](1);
      result[0] = _aaveV3Scroll('SCR', 3350000);
      return result;
    }
    revert('UNSUPPORTED_CHAIN');
  }

  function _aaveV2Ethereum(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return
      Spec(
        'AaveV2Ethereum',
        symbol,
        price,
        address(AaveV3Ethereum.ACL_MANAGER),
        ChainlinkEthereum.ETH__USD
      );
  }

  function _aaveV3EthereumEtherFi(
    string memory symbol,
    uint256 price
  ) private pure returns (Spec memory) {
    return
      Spec(
        'AaveV3EthereumEtherFi',
        symbol,
        price,
        address(AaveV3EthereumEtherFi.ACL_MANAGER),
        address(0)
      );
  }

  function _aaveV3Ethereum(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return Spec('AaveV3Ethereum', symbol, price, address(AaveV3Ethereum.ACL_MANAGER), address(0));
  }

  function _aaveV2Polygon(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return
      Spec(
        'AaveV2Polygon',
        symbol,
        price,
        address(AaveV3Polygon.ACL_MANAGER),
        ChainlinkPolygon.ETH__USD
      );
  }

  function _aaveV3Polygon(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return Spec('AaveV3Polygon', symbol, price, address(AaveV3Polygon.ACL_MANAGER), address(0));
  }

  function _aaveV3Arbitrum(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return Spec('AaveV3Arbitrum', symbol, price, address(AaveV3Arbitrum.ACL_MANAGER), address(0));
  }

  function _aaveV3Avalanche(
    string memory symbol,
    uint256 price
  ) private pure returns (Spec memory) {
    return Spec('AaveV3Avalanche', symbol, price, address(AaveV3Avalanche.ACL_MANAGER), address(0));
  }

  function _aaveV3Celo(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return Spec('AaveV3Celo', symbol, price, address(AaveV3Celo.ACL_MANAGER), address(0));
  }

  function _aaveV3Optimism(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return Spec('AaveV3Optimism', symbol, price, address(AaveV3Optimism.ACL_MANAGER), address(0));
  }

  function _aaveV3Scroll(string memory symbol, uint256 price) private pure returns (Spec memory) {
    return Spec('AaveV3Scroll', symbol, price, address(AaveV3Scroll.ACL_MANAGER), address(0));
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
