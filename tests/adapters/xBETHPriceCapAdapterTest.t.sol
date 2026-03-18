// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {XStakedPriceCapAdapter} from '../../src/contracts/lst-adapters/XStakedPriceCapAdapter.sol';
import {CapAdaptersCodeXLayer} from '../../scripts/DeployXLayer.s.sol';

contract xBETH_XLayerTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeXLayer.xBETHAdapterCode(),
      30,
      ForkParams({network: 'xlayer', blockNumber: 55067099}),
      'xBETH_XLayer'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new XStakedPriceCapAdapter(capAdapterParams);
  }
}
