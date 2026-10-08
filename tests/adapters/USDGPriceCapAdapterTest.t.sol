// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';

contract USDGEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.USDGAdapterCode(),
      14,
      ForkParams({network: 'mainnet', blockNumber: 24319000})
    )
  {}
}

contract USDGArbitrumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeArbitrum.USDGAdapterCode(),
      14,
      ForkParams({network: 'arbitrum', blockNumber: 512800000})
    )
  {}
}
