// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice A simple version of the X Layer Staked Token allowing to get the exchange ratio
interface IXStakedToken {
  /**
   * @dev Returns the current exchange rate scaled by by 10**18
   * @return _exchangeRate The exchange rate
   * @notice Returns 0 before the oracle's first update
   */
  function exchangeRate() external view returns (uint256 _exchangeRate);
}
