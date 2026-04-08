// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;
import "./TestLib.sol";
contract fraxPerLPTokenFacet is FraxUnifiedFarm_ERC20 {
    function fraxPerLPToken()
        public
        view
        override
        returns (uint256 frax_per_lp_token)
    {
        // COMMENTED OUT SO COMPILER DOESNT COMPLAIN. UNCOMMENT WHEN DEPLOYING

        // Convex Volatile/FRAXBP
        // ============================================
        {
            // Half of the LP is FRAXBP. Half of that should be FRAX.
            // Using 0.25 * lp price for gas savings
            frax_per_lp_token =
                (curvePool.lp_price() * (1e18)) /
                (4 * curvePool.price_oracle());
        }
    }
}
