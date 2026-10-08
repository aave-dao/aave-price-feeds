// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract PSTEthereumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeEthereum.PSTAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 26147000}),
      'PST_Ethereum'
    )
  {}

  function setUp() public override {
    super.setUp();
    // the scaled ratio feed is not deployed yet, keep it across the retrospective forks
    vm.makePersistent(
      GovV3Helpers.deployDeterministic(CapAdaptersCodeEthereum.PSTRatioScaledAdapterCode())
    );
  }
}
