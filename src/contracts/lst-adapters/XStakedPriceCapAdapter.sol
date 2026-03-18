// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';
import {IXStakedToken} from '../../interfaces/IXStakedToken.sol';

/**
 * @title XStakedPriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (XStaked / USD) pair specific to X-Layer by using
 * @notice Capped adapter for chainlink (Base / USD) and the exchange rate ratio from the XStakedToken.
 */
contract XStakedPriceCapAdapter is PriceCapAdapterBase {
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
    return int256(IXStakedToken(RATIO_PROVIDER).exchangeRate());
  }
}
