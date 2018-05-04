pragma solidity ^0.4.20;

import "./WarToken.sol";
import "./AccessService.sol";

contract ActionPresell is AccessService {
    WarToken tokenContract;
    mapping (uint16 => uint16) petPresellCounter;
    mapping (address => uint16[]) presellLimit;

    event PetPreSelled(address indexed buyer, uint16 protoId);

    function ActionPresell(address _nftAddr) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = WarToken(_nftAddr);

        petPresellCounter[10001] = 50;
        petPresellCounter[10002] = 30;
        petPresellCounter[10003] = 50;
        petPresellCounter[10004] = 30;
        petPresellCounter[10005] = 30;
    }

    function() external payable {

    }

    function setWarTokenAddr(address _nftAddr) external onlyAdmin {
        tokenContract = WarToken(_nftAddr);
    }

    function petPresell(uint16 _protoId) 
        external
        payable
        whenNotPaused 
    {
        uint16 curSupply = petPresellCounter[_protoId];
        require(curSupply > 0);
        uint16[] storage buyArray = presellLimit[msg.sender];
        uint256 curBuyCnt = buyArray.length;
        require(curBuyCnt < 10);

        uint256 payBack = 0;
        if (_protoId == 10001) {
            require(msg.value >= 0.66 ether);
            payBack = (msg.value - 0.66 ether);
            uint16[9] memory param1 = [10001, 5, 9, 40, 0, 0, 0, 0, 1];       // hp +40%
            tokenContract.createFashion(msg.sender, param1, 1);
            buyArray.push(10001);
        } else if(_protoId == 10002) {
            require(msg.value >= 0.99 ether);
            payBack = (msg.value - 0.99 ether);
            uint16[9] memory param2 = [10002, 5, 9, 0, 30, 30, 0, 0, 1];       // atk +30%
            tokenContract.createFashion(msg.sender, param2, 1);
            buyArray.push(10002);
        } else if(_protoId == 10003) {
            require(msg.value >= 0.66 ether);
            payBack = (msg.value - 0.66 ether);
            uint16[9] memory param3 = [10003, 5, 9, 0, 0, 0, 40, 0, 1];        // def +40%
            tokenContract.createFashion(msg.sender, param3, 1);
            buyArray.push(10003);
        } else if(_protoId == 10004) {
            require(msg.value >= 0.99 ether);
            payBack = (msg.value - 0.99 ether);
            uint16[9] memory param4 = [10004, 5, 9, 0, 0, 0, 0, 50, 1];        // crit +50%
            tokenContract.createFashion(msg.sender, param4, 1);
            buyArray.push(10004);
        } else {
            require(msg.value >= 0.99 ether);
            payBack = (msg.value - 0.99 ether);
            uint16[9] memory param5 = [10005, 5, 9, 20, 10, 10, 20, 0, 1];      // hp +20%, atk +10%, def +20%
            tokenContract.createFashion(msg.sender, param5, 1);
            buyArray.push(10005);
        }

        petPresellCounter[_protoId] = (curSupply - 1);

        PetPreSelled(msg.sender, _protoId);

        addrFinance.transfer(msg.value - payBack);        // need 2300 gas -_-!
        if (payBack > 0) {
            msg.sender.transfer(payBack);
        }
    }

    function getPetCanPresellCount() external view returns (uint16[5] cntArray) {
        cntArray[0] = petPresellCounter[10001];
        cntArray[1] = petPresellCounter[10002];
        cntArray[2] = petPresellCounter[10003];
        cntArray[3] = petPresellCounter[10004];
        cntArray[4] = petPresellCounter[10005];   
    }

    function getBuyCount(address _owner) external view returns (uint32) {
        return uint32(presellLimit[_owner].length);
    }

    function getBuyArray(address _owner) external view returns (uint16[]) {
        uint16[] storage buyArray = presellLimit[_owner];
        return buyArray;
    }
}
