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
  struct SpecV2 {
    string symbol;
    uint256 price;
    address acl;
    address ethUsd;
  }

  struct SpecV3 {
    string symbol;
    uint256 price;
    address acl;
  }

  function specsV2(uint256 chain) internal pure returns (SpecV2[] memory result) {
    if (chain == 1) {
      result = new SpecV2[](13);
      result[0] = _aaveV2Ethereum('AMPL', 123_960_000); // $1.2396
      result[1] = _aaveV2Ethereum('BAL', 13_170_000); // $0.1317
      result[2] = _aaveV2Ethereum('ENJ', 4_610_000); // $0.0461
      result[3] = _aaveV2Ethereum('FRAX', 100_000_000); // $1.00
      result[4] = _aaveV2Ethereum('KNC', 14_010_000); // $0.1401
      result[5] = _aaveV2Ethereum('LUSD', 100_000_000); // $1.00
      result[6] = _aaveV2Ethereum('RAI', 265_870_000); // $2.6587
      result[7] = _aaveV2Ethereum('REN', 330_000); // $0.0033
      result[8] = _aaveV2Ethereum('TUSD', 100_000_000); // $1.00
      result[9] = _aaveV2Ethereum('USDP', 100_000_000); // $1.00
      result[10] = _aaveV2Ethereum('YFI', 228_663_680_000); // $2286.6368
      result[11] = _aaveV2Ethereum('ZRX', 9_810_000); // $0.0981
      result[12] = _aaveV2Ethereum('sUSD', 37_800_000); // $0.378
      return result;
    }
    if (chain == 137) {
      result = new SpecV2[](2);
      result[0] = _aaveV2Polygon('BAL', 12_840_000); // $0.1284
      result[1] = _aaveV2Polygon('GHST', 7_930_000); // $0.0793
      return result;
    }
    return new SpecV2[](0);
  }

  function specsV3(uint256 chain) internal pure returns (SpecV3[] memory result) {
    if (chain == 1) {
      result = new SpecV3[](8);
      result[0] = _aaveV3EthereumEtherFi('FRAX', 100_000_000); // $1.00
      result[1] = _aaveV3Ethereum('BAL', 13_370_000); // $0.1337
      result[2] = _aaveV3Ethereum('FRAX', 100_000_000); // $1.00
      result[3] = _aaveV3Ethereum('FXS', 35_620_000); // $0.3562
      result[4] = _aaveV3Ethereum('KNC', 14_000_000); // $0.14
      result[5] = _aaveV3Ethereum('LUSD', 100_000_000); // $1.00
      result[6] = _aaveV3Ethereum('RPL', 173_380_000); // $1.7338
      result[7] = _aaveV3Ethereum('STG', 27_340_000); // $0.2734
      return result;
    }
    if (chain == 137) {
      result = new SpecV3[](3);
      result[0] = _aaveV3Polygon('BAL', 13_160_000); // $0.1316
      result[1] = _aaveV3Polygon('GHST', 8_280_000); // $0.0828
      result[2] = _aaveV3Polygon('miMATIC', 95_300_000); // $0.953
      return result;
    }
    if (chain == 42161) {
      result = new SpecV3[](3);
      result[0] = _aaveV3Arbitrum('FRAX', 100_000_000); // $1.00
      result[1] = _aaveV3Arbitrum('LUSD', 100_000_000); // $1.00
      result[2] = _aaveV3Arbitrum('MAI', 95_300_000); // $0.953
      return result;
    }
    if (chain == 43114) {
      result = new SpecV3[](2);
      result[0] = _aaveV3Avalanche('FRAX', 100_000_000); // $1.00
      result[1] = _aaveV3Avalanche('MAI', 95_300_000); // $0.953
      return result;
    }
    if (chain == 42220) {
      result = new SpecV3[](1);
      result[0] = _aaveV3Celo('USDm', 100_000_000); // $1.00
      return result;
    }
    if (chain == 10) {
      result = new SpecV3[](3);
      result[0] = _aaveV3Optimism('LUSD', 100_000_000); // $1.00
      result[1] = _aaveV3Optimism('MAI', 95_300_000); // $0.953
      result[2] = _aaveV3Optimism('sUSD', 30_290_000); // $0.3029
      return result;
    }
    if (chain == 534352) {
      result = new SpecV3[](1);
      result[0] = _aaveV3Scroll('SCR', 3_350_000); // $0.0335
      return result;
    }
    revert('UNSUPPORTED_CHAIN');
  }

  function _aaveV2Ethereum(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV2 memory) {
    return SpecV2(symbol, price, address(AaveV3Ethereum.ACL_MANAGER), ChainlinkEthereum.ETH__USD);
  }

  function _aaveV3EthereumEtherFi(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3EthereumEtherFi.ACL_MANAGER));
  }

  function _aaveV3Ethereum(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3Ethereum.ACL_MANAGER));
  }

  function _aaveV2Polygon(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV2 memory) {
    return SpecV2(symbol, price, address(AaveV3Polygon.ACL_MANAGER), ChainlinkPolygon.ETH__USD);
  }

  function _aaveV3Polygon(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3Polygon.ACL_MANAGER));
  }

  function _aaveV3Arbitrum(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3Arbitrum.ACL_MANAGER));
  }

  function _aaveV3Avalanche(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3Avalanche.ACL_MANAGER));
  }

  function _aaveV3Celo(string memory symbol, uint256 price) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3Celo.ACL_MANAGER));
  }

  function _aaveV3Optimism(
    string memory symbol,
    uint256 price
  ) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3Optimism.ACL_MANAGER));
  }

  function _aaveV3Scroll(string memory symbol, uint256 price) private pure returns (SpecV3 memory) {
    return SpecV3(symbol, price, address(AaveV3Scroll.ACL_MANAGER));
  }

  function fixedCode(
    string memory symbol,
    uint256 price,
    address acl
  ) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(FixedPriceAdapter).creationCode,
        abi.encode(acl, uint8(8), int256(price), string.concat('Fixed ', symbol, '/USD'))
      );
  }

  function conversionCode(SpecV2 memory s, address fixedFeed) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLSynchronicityPriceAdapterBaseToPeg).creationCode,
        abi.encode(s.ethUsd, fixedFeed, uint8(18), string.concat(s.symbol, '/ETH fixed USD target'))
      );
  }

  function addresses(SpecV2 memory s) internal pure returns (address fixedFeed, address oracle) {
    fixedFeed = GovV3Helpers.predictDeterministicAddress(fixedCode(s.symbol, s.price, s.acl));
    oracle = GovV3Helpers.predictDeterministicAddress(conversionCode(s, fixedFeed));
  }

  function addresses(SpecV3 memory s) internal pure returns (address) {
    return GovV3Helpers.predictDeterministicAddress(fixedCode(s.symbol, s.price, s.acl));
  }

  function deploy(SpecV2 memory s) internal returns (address fixedFeed, address oracle) {
    fixedFeed = GovV3Helpers.deployDeterministic(fixedCode(s.symbol, s.price, s.acl));
    oracle = GovV3Helpers.deployDeterministic(conversionCode(s, fixedFeed));
  }

  function deploy(SpecV3 memory s) internal returns (address) {
    return GovV3Helpers.deployDeterministic(fixedCode(s.symbol, s.price, s.acl));
  }

  function deployAll(uint256 chain) internal {
    SpecV2[] memory v2 = specsV2(chain);
    for (uint256 i; i < v2.length; i++) deploy(v2[i]);
    SpecV3[] memory v3 = specsV3(chain);
    for (uint256 i; i < v3.length; i++) deploy(v3[i]);
  }
}
