pragma solidity ^0.4.20;

import "./AccessService.sol";
import "./IDataInterface.sol";

contract DataMining is AccessService, IDataMining {
    event RecommenderChange(address indexed _target, address _recommender);
    event FreeMineralChange(address indexed _target, uint32 _accCnt);

    /// @dev Recommend relationship map
    mapping (address => address) recommendRelation;
    /// @dev Free mining count map
    mapping (address => uint32) freeMineral;
    /// @dev Trust contract
    mapping (address => bool) actionContracts;

    function DataMining() public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;
    }

    function setRecommender(address _target, address _recommender) 
        external
        onlyService
    {
        require(_target != address(0));
        recommendRelation[_target] = _recommender;
        RecommenderChange(_target, _recommender);
    }

    function setRecommenderMulti(address[] _targets, address[] _recommenders) 
        external
        onlyService
    {
        uint256 targetLength = _targets.length;
        require(targetLength <= 64);
        require(targetLength == _recommenders.length);
        address addrZero = address(0);
        for (uint256 i = 0; i < targetLength; ++i) {
            if (_targets[i] != addrZero) {
                recommendRelation[_targets[i]] = _recommenders[i];
                RecommenderChange(_targets[i], _recommenders[i]);
            }
        }
    }

    function getRecommender(address _target) external view returns(address) {
        return recommendRelation[_target];
    }

    function addFreeMineral(address _target, uint32 _cnt)  
        external
        onlyService
    {
        require(_target != address(0));
        require(_cnt <= 32);
        uint32 oldCnt = freeMineral[_target];
        freeMineral[_target] = oldCnt + _cnt;
        FreeMineralChange(_target, freeMineral[_target]);
    }

    function addFreeMineralMulti(address[] _targets, uint32[] _cnts)
        external
        onlyService
    {
        uint256 targetLength = _targets.length;
        require(targetLength <= 64);
        require(targetLength == _cnts.length);
        address addrZero = address(0);
        uint32 oldCnt;
        uint32 newCnt;
        address addr;
        for (uint256 i = 0; i < targetLength; ++i) {
            addr = _targets[i];
            if (addr != addrZero && _cnts[i] <= 32) {
                oldCnt = freeMineral[addr];
                newCnt = oldCnt + _cnts[i];
                assert(oldCnt < newCnt);
                freeMineral[addr] = newCnt;
                FreeMineralChange(addr, freeMineral[addr]);
            }
        }
    }

    function setActionContract(address _actionAddr, bool _useful) external onlyAdmin {
        actionContracts[_actionAddr] = _useful;
    }

    function getActionContract(address _actionAddr) external view onlyAdmin returns(bool) {
        return actionContracts[_actionAddr];
    }

    function subFreeMineral(address _target) external returns(bool) {
        require(actionContracts[msg.sender]);
        require(_target != address(0));
        uint32 cnts = freeMineral[_target];
        assert(cnts > 0);
        freeMineral[_target] = cnts - 1;
        FreeMineralChange(_target, cnts - 1);
        return true;
    }

    function getFreeMineral(address _target) external view returns(uint32) {
        return freeMineral[_target];
    }
}
