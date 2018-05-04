pragma solidity ^0.4.20;

import "./WarToken.sol";
import "./AccessService.sol";
import "./Random.sol";
import "./IDataInterface.sol";
import "./SafeMath.sol";
import "./IBitGuildToken.sol";

contract ActionMiningPlat is Random, AccessService {
    using SafeMath for uint256;

    event MiningOrderPlatCreated(uint256 indexed index, address indexed miner, uint64 chestCnt);
    event MiningPlatResolved(uint256 indexed index, address indexed miner, uint64 chestCnt);

    struct MiningOrder {
        address miner; 
        uint64 chestCnt;
        uint64 tmCreate;
        uint64 tmResolve;
    }

    /// @dev Max fashion suit id
    uint16 maxProtoId;
    /// @dev If the recommender can get reward 
    bool isRecommendOpen;
    /// @dev WarToken(NFT) contract address
    WarToken public tokenContract;
    /// @dev DataMining contract address
    IDataMining public dataContract;
    /// @dev mining order array
    MiningOrder[] public ordersArray;
    /// @dev suit count
    mapping (uint16 => uint256) public protoIdToCount;
    /// @dev BitGuildToken address
    IBitGuildToken public bitGuildContract;
    /// @dev mining Price of PLAT
    uint256 public miningOnePlat = 650000000000000000000;
    uint256 public miningThreePlat = 1950000000000000000000;
    uint256 public miningFivePlat = 3088000000000000000000;
    uint256 public miningTenPlat = 5850000000000000000000;

    function ActionMiningPlat(address _nftAddr, uint16 _maxProtoId, address _platAddr) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = WarToken(_nftAddr);
        maxProtoId = _maxProtoId;
        
        MiningOrder memory order = MiningOrder(0, 0, 1, 1);
        ordersArray.push(order);

        bitGuildContract = IBitGuildToken(_platAddr);
    }

    function() external payable {

    }

    function getPlatBalance() external view returns(uint256) {
        return bitGuildContract.balanceOf(this);
    }

    function withdrawPlat() external {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        uint256 balance = bitGuildContract.balanceOf(this);
        require(balance > 0);
        bitGuildContract.transfer(addrFinance, balance);
    }

    function getOrderCount() external view returns(uint256) {
        return ordersArray.length - 1;
    }

    function setDataMining(address _addr) external onlyAdmin {
        require(_addr != address(0));
        dataContract = IDataMining(_addr);
    }

    function setMaxProtoId(uint16 _maxProtoId) external onlyAdmin {
        require(_maxProtoId > 0 && _maxProtoId < 10000);
        require(_maxProtoId != maxProtoId);
        maxProtoId = _maxProtoId;
    }

    function setRecommendStatus(bool _isOpen) external onlyAdmin {
        require(_isOpen != isRecommendOpen);
        isRecommendOpen = _isOpen;
    }

    function setFashionSuitCount(uint16 _protoId, uint256 _cnt) external onlyAdmin {
        require(_protoId > 0 && _protoId <= maxProtoId);
        require(_cnt > 0 && _cnt <= 5);
        require(protoIdToCount[_protoId] != _cnt);
        protoIdToCount[_protoId] = _cnt;
    }

    function changePlatPrice(uint32 miningType, uint256 price) external onlyAdmin {
        require(price > 0 && price < 100000);
        uint256 newPrice = price * 1000000000000000000;
        if (miningType == 1) {
            miningOnePlat = newPrice;
        } else if (miningType == 3) {
            miningThreePlat = newPrice;
        } else if (miningType == 5) {
            miningFivePlat = newPrice;
        } else if (miningType == 10) {
            miningTenPlat = newPrice;
        } else {
            require(false);
        }
    }

    function _getFashionParam(uint256 _seed) internal view returns(uint16[9] attrs) {
        uint256 curSeed = _seed;
        // quality
        uint256 rdm = curSeed % 10000;
        uint16 qtyParam;
        if (rdm < 6900) {
            attrs[1] = 1;
            qtyParam = 0;
        } else if (rdm < 8700) {
            attrs[1] = 2;
            qtyParam = 1;
        } else if (rdm < 9600) {
            attrs[1] = 3;
            qtyParam = 2;
        } else if (rdm < 9900) {
            attrs[1] = 4;
            qtyParam = 4;
        } else {
            attrs[1] = 5;
            qtyParam = 6;
        }

        // protoId
        curSeed /= 10000;
        rdm = ((curSeed % 10000) / (9999 / maxProtoId)) + 1;
        attrs[0] = uint16(rdm <= maxProtoId ? rdm : maxProtoId);

        // pos
        curSeed /= 10000;
        uint256 tmpVal = protoIdToCount[attrs[0]];
        if (tmpVal == 0) {
            tmpVal = 5;
        }
        rdm = ((curSeed % 10000) / (9999 / tmpVal)) + 1;
        uint16 pos = uint16(rdm <= tmpVal ? rdm : tmpVal);
        attrs[2] = pos;

        rdm = attrs[0] % 3;

        curSeed /= 10000;
        tmpVal = (curSeed % 10000) % 21 + 90;

        if (rdm == 0) {
            if (pos == 1) {
                uint256 attr = (200 + qtyParam * 200) * tmpVal / 100;              // +atk
                attrs[4] = uint16(attr * 40 / 100);
                attrs[5] = uint16(attr * 160 / 100);
            } else if (pos == 2) {
                attrs[6] = uint16((40 + qtyParam * 40) * tmpVal / 100);            // +def
            } else if (pos == 3) {
                attrs[3] = uint16((600 + qtyParam * 600) * tmpVal / 100);          // +hp
            } else if (pos == 4) {
                attrs[6] = uint16((60 + qtyParam * 60) * tmpVal / 100);            // +def
            } else {
                attrs[3] = uint16((400 + qtyParam * 400) * tmpVal / 100);          // +hp
            }
        } else if (rdm == 1) {
            if (pos == 1) {
                uint256 attr2 = (190 + qtyParam * 190) * tmpVal / 100;              // +atk
                attrs[4] = uint16(attr2 * 50 / 100);
                attrs[5] = uint16(attr2 * 150 / 100);
            } else if (pos == 2) {
                attrs[6] = uint16((42 + qtyParam * 42) * tmpVal / 100);            // +def
            } else if (pos == 3) {
                attrs[3] = uint16((630 + qtyParam * 630) * tmpVal / 100);          // +hp
            } else if (pos == 4) {
                attrs[6] = uint16((63 + qtyParam * 63) * tmpVal / 100);            // +def
            } else {
                attrs[3] = uint16((420 + qtyParam * 420) * tmpVal / 100);          // +hp
            }
        } else {
            if (pos == 1) {
                uint256 attr3 = (210 + qtyParam * 210) * tmpVal / 100;             // +atk
                attrs[4] = uint16(attr3 * 30 / 100);
                attrs[5] = uint16(attr3 * 170 / 100);
            } else if (pos == 2) {
                attrs[6] = uint16((38 + qtyParam * 38) * tmpVal / 100);            // +def
            } else if (pos == 3) {
                attrs[3] = uint16((570 + qtyParam * 570) * tmpVal / 100);          // +hp
            } else if (pos == 4) {
                attrs[6] = uint16((57 + qtyParam * 57) * tmpVal / 100);            // +def
            } else {
                attrs[3] = uint16((380 + qtyParam * 380) * tmpVal / 100);          // +hp
            }
        }
        attrs[8] = 0;
    }

    function _addOrder(address _miner, uint64 _chestCnt) internal {
        uint64 newOrderId = uint64(ordersArray.length);
        ordersArray.length += 1;
        MiningOrder storage order = ordersArray[newOrderId];
        order.miner = _miner;
        order.chestCnt = _chestCnt;
        order.tmCreate = uint64(block.timestamp);

        MiningOrderPlatCreated(newOrderId, _miner, _chestCnt);
    }

    function _transferHelper(uint256 platVal) private {
        if (isRecommendOpen) {
            address recommender = dataContract.getRecommender(msg.sender);
            if (recommender != address(0)) {
                uint256 rVal = platVal.div(10);
                if (rVal > 0) {
                    bitGuildContract.transfer(recommender, rVal);
                }   
            }
        } 
    }

    function _getExtraParam(bytes _extraData) internal pure returns(uint32) {
        uint32 val = 0;
        if (_extraData[0] >= 48 && _extraData[0] <= 57) {
            val = val + uint32(_extraData[0]) - 48;
        }
        if (_extraData.length > 1) {
            if (_extraData[1] >= 48 && _extraData[1] <= 57) {
                val = val + (uint32(_extraData[1]) - 48) * 10;
            }
        }
        return val;    
    }

    function receiveApproval(address _sender, uint256 _value, address _tokenContract, bytes _extraData) 
        external 
        whenNotPaused 
    {
        require(msg.sender == address(bitGuildContract));
        require(_extraData.length == 2 || _extraData.length == 1);
        uint32 miningType = _getExtraParam(_extraData);
        if (miningType == 0) {
            require(_value == miningOnePlat);
            require(bitGuildContract.transferFrom(_sender, address(this), _value));
            _miningOneSelf(_sender, _value);
        } else if (miningType == 10) {
            require(_value == miningTenPlat);
            require(bitGuildContract.transferFrom(_sender, address(this), _value));
            _addOrder(_sender, 10);
        } else if (miningType == 3) {
            require(_value == miningThreePlat);
            require(bitGuildContract.transferFrom(_sender, address(this), _value));
            _addOrder(_sender, 3);
        } else if (miningType == 5) {
            require(_value == miningFivePlat);
            require(bitGuildContract.transferFrom(_sender, address(this), _value));
            _addOrder(_sender, 5);
        } else if (miningType == 1) {
            require(_value == miningOnePlat);
            require(bitGuildContract.transferFrom(_sender, address(this), _value));
            _addOrder(_sender, 1);
        } else {
            require(false);
        }
        _transferHelper(_value);
    }

    function _miningOneSelf(address _sender, uint256 _platVal) internal {
        uint256 seed = _rand();
        uint16[9] memory attrs = _getFashionParam(seed);

        tokenContract.createFashion(_sender, attrs, 6);

        MiningPlatResolved(0, msg.sender, 1);
    }

    function miningResolve(uint256 _orderIndex, uint256 _seed) 
        external 
        onlyService
    {
        require(_orderIndex > 0 && _orderIndex < ordersArray.length);
        MiningOrder storage order = ordersArray[_orderIndex];
        require(order.tmResolve == 0);
        address miner = order.miner;
        require(miner != address(0));
        uint64 chestCnt = order.chestCnt;
        require(chestCnt >= 1 && chestCnt <= 10);

        uint256 rdm = _seed;
        uint16[9] memory attrs;
        for (uint64 i = 0; i < chestCnt; ++i) {
            rdm = _randBySeed(rdm);
            attrs = _getFashionParam(rdm);
            tokenContract.createFashion(miner, attrs, 6);
        }
        order.tmResolve = uint64(block.timestamp);
        MiningPlatResolved(_orderIndex, miner, chestCnt);
    }
}
