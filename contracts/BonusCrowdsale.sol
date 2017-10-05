pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


// Crowdsale which can give time and amount bonuses
contract BonusCrowdsale is Crowdsale, Ownable {

    uint[] public BONUS_TIMES;
    uint[] public BONUS_TIMES_VALUES;
    uint[] public BONUS_AMOUNTS;
    uint[] public BONUS_AMOUNTS_VALUES;
    uint public constant BONUS_COEFF = 1000; // Values should be 10x percents, values from 0 to 1000
    
    function BonusCrowdsale() {
    }

    function buyTokens(address beneficiary) public payable {
        require(BONUS_TIMES.length > 0 || BONUS_AMOUNTS.length > 0);
        require(BONUS_TIMES.length == BONUS_TIMES_VALUES.length);
        require(BONUS_AMOUNTS.length == BONUS_AMOUNTS_VALUES.length);

        uint256 bonus = computeBonus(msg.value.mul(rate));

        uint256 oldRate = rate;
        rate = rate * BONUS_COEFF / (BONUS_COEFF + bonus);
        super.buyTokens(beneficiary);
        rate = oldRate;
    }

    function computeBonus(uint256 usdValue) public returns(uint256) {
        return computeAmountBonus(usdValue) + computeTimeBonus();
    }

    function computeTimeBonus() public returns(uint256) {
        require(now >= startTime);

        for (uint i = 0; i < BONUS_TIMES.length; i++) {
            if (startTime <= BONUS_TIMES[i]) {
                return BONUS_TIMES_VALUES[i];
            }
        }

        return 0;
    }

    function computeAmountBonus(uint256 usdValue) public returns(uint256) {
        for (uint i = 0; i < BONUS_AMOUNTS.length; i++) {
            if (usdValue >= BONUS_AMOUNTS[i]) {
                return BONUS_AMOUNTS_VALUES[i];
            }
        }

        return 0;
    }

}
