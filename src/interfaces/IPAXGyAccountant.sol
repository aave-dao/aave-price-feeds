// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice PAXGy accountant interface.
interface IPAXGyAccountant {
  function decimals() external view returns (uint8);

  function vault() external view returns (address);

  function base() external view returns (address);

  function owner() external view returns (address);

  function pause() external;

  function getRate() external view returns (uint256);

  /// @notice Returns the gold-denominated rate per share at 18 decimals. Reverts when paused.
  function getRateSafe() external view returns (uint256);
}
