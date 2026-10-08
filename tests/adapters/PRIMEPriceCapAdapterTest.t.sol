// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeEthereum, AaveV3EthereumAssets} from '../../scripts/DeployEthereum.s.sol';

contract PRIMEEthereumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeEthereum.PRIMEAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 26147000}),
      'PRIME_Ethereum'
    )
  {}

  function setUp() public override {
    super.setUp();
    // the fixed 1 USD base feed reverts on description(), which the report reads
    vm.mockCall(
      AaveV3EthereumAssets.GHO_ORACLE,
      abi.encodeWithSignature('description()'),
      abi.encode('ONE USD')
    );
  }
}
