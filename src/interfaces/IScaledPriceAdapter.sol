// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

interface IScaledPriceAdapter {
  /**
   * @dev Returns the feed decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the description of the feed.
   */
  function description() external view returns (string memory);

  /**
   * @dev Scaled `latestAnswer` from chainlink price feed.
   * @dev Loses price precision by log10(scaleFactor) when scaling down.
   */
  function latestAnswer() external view returns (int256);

  /**
   * @dev Direction and units used to scale latestAnswer to base decimals of 8.
   * @dev Loses price precision by log10(scaleFactor) when scaling down.
   * @return scaleUp Whether to scale up or down.
   * @return scaleFactor The units to scale by.
   */
  function scale() external view returns (bool scaleUp, uint256 scaleFactor);

  /**
   * @dev Underlying chainlink price feed.
   */
  function source() external view returns (address);
}
