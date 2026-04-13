// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';

contract USDeEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.USDeAdapterCode(),
      10,
      ForkParams({network: 'mainnet', blockNumber: 19940721})
    )
  {}
}

contract USDeMegaEthTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMegaEth.USDeAdapterCode(),
      10,
      ForkParams({network: 'megaeth', blockNumber: 12922700})
    )
  {}
}
