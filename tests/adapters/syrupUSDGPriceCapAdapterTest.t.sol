// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {SyrupUSDGPriceCapAdapter} from '../../src/contracts/lst-adapters/SyrupUSDGPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum, AaveV3EthereumAssets} from '../../scripts/DeployEthereum.s.sol';

contract syrupUSDGEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.syrupUSDGAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 25594919}),
      'SyrupUSDG_Ethereum'
    )
  {}

  function setUp() public override {
    super.setUp();
    // the base feed is the USDG cap adapter, deployed more recently than the retrospective range
    vm.makePersistent(AaveV3EthereumAssets.USDG_ORACLE);
  }

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new SyrupUSDGPriceCapAdapter(capAdapterParams);
  }
}
