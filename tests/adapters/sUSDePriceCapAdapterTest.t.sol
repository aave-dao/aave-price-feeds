// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {SUSDePriceCapAdapter} from '../../src/contracts/lst-adapters/SUSDePriceCapAdapter.sol';
import {CapAdaptersCodeAvalanche} from '../../scripts/DeployAvalanche.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';
import {CapAdaptersCodeMonad} from '../../scripts/DeployMonad.s.sol';

// was tested with USDe / USD feed for a longer period
contract sUSDeEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.sUSDeAdapterCode(),
      8,
      ForkParams({network: 'mainnet', blockNumber: 20131922}),
      'sUSDe_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new SUSDePriceCapAdapter(capAdapterParams);
  }
}

contract sUSDeMantleTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMantle.sUSDeAdapterCode(),
      3,
      ForkParams({network: 'mantle', blockNumber: 90952191}),
      'sUSDe_Mantle'
    )
  {}
}

contract sUSDeAvalancheTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeAvalanche.sUSDeAdapterCode(),
      30,
      ForkParams({network: 'avalanche', blockNumber: 77096662}),
      'sUSDe_Avalanche'
    )
  {}
}

contract sUSDePlasmaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodePlasma.sUSDeAdapterParams(),
      14,
      ForkParams({network: 'plasma', blockNumber: 3764593}),
      'sUSDe_Plasma'
    )
  {}
}

contract sUSDeInkTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeInk.sUSDeAdapterCode(),
      1,
      ForkParams({network: 'ink', blockNumber: 36873000}), // Feb 06 2026
      'sUSDe_Ink'
    )
  {}

  function test_latestAnswerRetrospective() public pure override {
    // cannot test due to newly base feed deployed
    assertTrue(true);
  }
}

contract sUSDeMonadTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMonad.sUSDeAdapterCode(),
      0,
      ForkParams({network: 'monad', blockNumber: 83587465}),
      'sUSDe_monad'
    )
  {}

  function setUp() public override {
    super.setUp();
    // sUSDe base is the USDe cap adapter, which itself reads the USDT0 SVR feed: deploy both, in order
    GovV3Helpers.deployDeterministic(
      CapAdaptersCodeMonad.scaledAdapterCode(CapAdaptersCodeMonad.USDT0_SVR_USD_PRICE_FEED)
    );
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMonad.USDeAdapterCode());
  }

  function test_latestAnswerRetrospective() public pure override {
    // cannot test due to newly deployed base/ratio feeds
    assertTrue(true);
  }
}
