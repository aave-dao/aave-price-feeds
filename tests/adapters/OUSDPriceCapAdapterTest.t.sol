// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract OUSDEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.OUSDAdapterCode(),
      7, // the OUSD / USD feed went live on 2026-09-30
      ForkParams({network: 'mainnet', blockNumber: 26147000})
    )
  {}
}
