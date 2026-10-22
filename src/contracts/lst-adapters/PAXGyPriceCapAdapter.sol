// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';
import {IPAXGyAccountant} from '../../interfaces/IPAXGyAccountant.sol';

/**
 * @title PAXGyPriceCapAdapter
 * @author Aave Labs
 * @notice Prices PAXGy in USD using the capped native accountant rate and the XAU/USD feed.
 */
contract PAXGyPriceCapAdapter is PriceCapAdapterBase {
  /**
   * @param capAdapterParams parameters to create cap adapter
   */
  constructor(
    CapAdapterParams memory capAdapterParams
  )
    PriceCapAdapterBase(
      CapAdapterBaseParams({
        aclManager: capAdapterParams.aclManager,
        baseAggregatorAddress: capAdapterParams.baseAggregatorAddress,
        ratioProviderAddress: capAdapterParams.ratioProviderAddress,
        pairDescription: capAdapterParams.pairDescription,
        ratioDecimals: 18,
        minimumSnapshotDelay: capAdapterParams.minimumSnapshotDelay,
        priceCapParams: capAdapterParams.priceCapParams
      })
    )
  {}

  /// @inheritdoc IPriceCapAdapter
  function getRatio() public view override returns (int256) {
    // The accountant stores its rate as uint96; getRateSafe propagates its paused-state revert.
    return int256(IPAXGyAccountant(RATIO_PROVIDER).getRateSafe());
  }
}
