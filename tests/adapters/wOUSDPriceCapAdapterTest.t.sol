// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {WOUSDPriceCapAdapter} from '../../src/contracts/lst-adapters/WOUSDPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract wOUSDEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.wOUSDAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 26147000}),
      'wOUSD_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new WOUSDPriceCapAdapter(capAdapterParams);
  }
}
