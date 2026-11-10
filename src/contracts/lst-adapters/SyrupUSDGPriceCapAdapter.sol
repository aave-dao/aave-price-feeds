// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';
import {IMaplePool} from '../../interfaces/IMaplePool.sol';

/**
 * @title SyrupUSDGPriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (SyrupUSDG / USD) pair by using
 * @notice Capped adapter for (USDG / USD) and (SyrupUSDG / USDG) ratio.
 */
contract SyrupUSDGPriceCapAdapter is PriceCapAdapterBase {
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
    return int256(IMaplePool(RATIO_PROVIDER).convertToExitAssets(10 ** RATIO_DECIMALS));
  }
}
