// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice PAXGy accountant's native exchange rate interface.
interface IPAXGyAccountant {
  /// @notice Returns the gold-denominated rate per share at 18 decimals. Reverts when paused.
  function getRateSafe() external view returns (uint256);
}
