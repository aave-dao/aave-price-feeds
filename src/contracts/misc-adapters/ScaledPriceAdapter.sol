// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

import {AggregatorInterface} from '../../interfaces/AggregatorInterface.sol';
import {IScaledPriceAdapter} from '../../interfaces/IScaledPriceAdapter.sol';

/**
 * @title ScaledPriceAdapter
 * @author Aave Labs
 * @dev Price Adapter for Chainlink price feeds to scale price to standard USD unit of 8 decimals.
 */
contract ScaledPriceAdapter is IScaledPriceAdapter {
  AggregatorInterface internal immutable _SOURCE;

  uint8 internal constant _BASE_DECIMALS = 8;
  bool internal immutable _SCALE_UP;
  uint256 internal immutable _SCALE_FACTOR;

  constructor(address source_) {
    _SOURCE = AggregatorInterface(source_);
    uint8 sourceDecimals = _SOURCE.decimals();
    _SCALE_UP = sourceDecimals < _BASE_DECIMALS;
    _SCALE_FACTOR =
      10 ** (_SCALE_UP ? _BASE_DECIMALS - sourceDecimals : sourceDecimals - _BASE_DECIMALS);
  }

  /// @inheritdoc IScaledPriceAdapter
  function latestAnswer() external view returns (int256) {
    return
      _SCALE_UP
        ? _SOURCE.latestAnswer() * int256(_SCALE_FACTOR)
        : _SOURCE.latestAnswer() / int256(_SCALE_FACTOR);
  }

  /// @inheritdoc IScaledPriceAdapter
  function description() external view returns (string memory) {
    return string.concat(_SOURCE.description(), ' (USD Scaled)');
  }

  /// @inheritdoc IScaledPriceAdapter
  function decimals() external pure returns (uint8) {
    return _BASE_DECIMALS;
  }

  /// @inheritdoc IScaledPriceAdapter
  function scale() external view returns (bool, uint256) {
    return (_SCALE_UP, _SCALE_FACTOR);
  }

  /// @inheritdoc IScaledPriceAdapter
  function source() external view returns (address) {
    return address(_SOURCE);
  }
}
