pragma solidity ^0.4.20;

import "./AccessService.sol";
import "./SafeMath.sol";

contract PrizePool is AccessService {
    using SafeMath for uint256;

    event SendPrizeSuccesss(uint64 flag, uint256 oldBalance, uint256 sendVal);
    event PrizeTimeClear(uint256 newVal);
    uint64 public nextPrizeTime;
    uint256 maxPrizeOneDay = 30;

    
    function PrizePool() public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;
    }

    function() external payable {

    }

    function getBalance() external view returns(uint256) {
        return this.balance;
    }

    function clearNextPrizeTime() external onlyService {
        nextPrizeTime = 0;
        PrizeTimeClear(0);
    }

    function setMaxPrizeOneDay(uint256 val) external onlyAdmin {
        require(val > 0 && val < 100);
        require(val != maxPrizeOneDay);
        maxPrizeOneDay = val;
    }

    // gas 130000 per 10 address
    function sendPrize(address[] winners, uint256[] amounts, uint64 _flag) 
        external 
        onlyService 
        whenNotPaused
    {
        uint64 tmNow = uint64(block.timestamp);
        uint256 length = winners.length;
        require(length == amounts.length);
        require(length <= 64);

        uint256 sum = 0;
        for (uint32 i = 0; i < length; ++i) {
            sum = sum.add(amounts[i]);
        }
        uint256 balance = this.balance;
        require((sum.mul(100).div(balance)) <= maxPrizeOneDay);

        address addrZero = address(0);
        for (uint32 j = 0; j < length; ++j) {
            if (winners[j] != addrZero) {
                winners[j].transfer(amounts[j]);
            }
        }
        nextPrizeTime = tmNow + 21600;
        SendPrizeSuccesss(_flag, balance, sum);
    }
}


