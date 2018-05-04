pragma solidity ^0.4.20;

import "./WarToken.sol";
import "./AccessService.sol";
import "./Random.sol";
import "./IDataInterface.sol";
import "./SafeMath.sol";

contract ActionMining is Random, AccessService {
    using SafeMath for uint256;

    event MiningOrderCreated(uint256 indexed index, address indexed miner, uint64 chestCnt);
    event MiningResolved(uint256 indexed index, address indexed miner, uint64 chestCnt);

    struct MiningOrder {
        address miner;      // 挖宝人
        uint64 chestCnt;    // 挖宝次数
        uint64 tmCreate;    // 创建时间
        uint64 tmResolve;   // 解决时间
    }

    /// @dev Max fashion suit id
    uint16 maxProtoId;
    /// @dev If the recommender can get reward 
    bool isRecommendOpen;
    /// @dev prizepool percent
    uint256 constant prizePoolPercent = 50;
    /// @dev prizepool contact address
    address poolContract;
    /// @dev WarToken(NFT) contract address
    WarToken public tokenContract;
    /// @dev DataMining contract address
    IDataMining public dataContract;
    /// @dev mining order array
    MiningOrder[] public ordersArray;
    /// @dev 特殊套装数量(默认都是5件套)
    mapping (uint16 => uint256) public protoIdToCount;


    function ActionMining(address _nftAddr, uint16 _maxProtoId) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = WarToken(_nftAddr);
        maxProtoId = _maxProtoId;
        
        MiningOrder memory order = MiningOrder(0, 0, 1, 1);
        ordersArray.push(order);
    }

    function() external payable {

    }

    function getOrderCount() external view returns(uint256) {
        return ordersArray.length - 1;
    }

    function setDataMining(address _addr) external onlyAdmin {
        require(_addr != address(0));
        dataContract = IDataMining(_addr);
    }
    
    function setPrizePool(address _addr) external onlyAdmin {
        require(_addr != address(0));
        poolContract = _addr;
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

        // 生成属性
        rdm = attrs[0] % 3;

        curSeed /= 10000;
        tmpVal = (curSeed % 10000) % 21 + 90;

        // 武器1/帽子2/衣服3/裤子4/鞋子5
        if (rdm == 0) {
            if (pos == 1) {
                uint256 attr = (200 + qtyParam * 200) * tmpVal / 100;              // 武器+atk
                attrs[4] = uint16(attr * 40 / 100);
                attrs[5] = uint16(attr * 160 / 100);
            } else if (pos == 2) {
                attrs[6] = uint16((40 + qtyParam * 40) * tmpVal / 100);            // 帽子+def
            } else if (pos == 3) {
                attrs[3] = uint16((600 + qtyParam * 600) * tmpVal / 100);          // 衣服+hp
            } else if (pos == 4) {
                attrs[6] = uint16((60 + qtyParam * 60) * tmpVal / 100);            // 裤子+def
            } else {
                attrs[3] = uint16((400 + qtyParam * 400) * tmpVal / 100);          // 鞋子+hp
            }
        } else if (rdm == 1) {
            if (pos == 1) {
                uint256 attr2 = (190 + qtyParam * 190) * tmpVal / 100;              // 武器+atk
                attrs[4] = uint16(attr2 * 50 / 100);
                attrs[5] = uint16(attr2 * 150 / 100);
            } else if (pos == 2) {
                attrs[6] = uint16((42 + qtyParam * 42) * tmpVal / 100);            // 帽子+def
            } else if (pos == 3) {
                attrs[3] = uint16((630 + qtyParam * 630) * tmpVal / 100);          // 衣服+hp
            } else if (pos == 4) {
                attrs[6] = uint16((63 + qtyParam * 63) * tmpVal / 100);            // 裤子+def
            } else {
                attrs[3] = uint16((420 + qtyParam * 420) * tmpVal / 100);          // 鞋子+hp
            }
        } else {
            if (pos == 1) {
                uint256 attr3 = (210 + qtyParam * 210) * tmpVal / 100;             // 武器+atk
                attrs[4] = uint16(attr3 * 30 / 100);
                attrs[5] = uint16(attr3 * 170 / 100);
            } else if (pos == 2) {
                attrs[6] = uint16((38 + qtyParam * 38) * tmpVal / 100);            // 帽子+def
            } else if (pos == 3) {
                attrs[3] = uint16((570 + qtyParam * 570) * tmpVal / 100);          // 衣服+hp
            } else if (pos == 4) {
                attrs[6] = uint16((57 + qtyParam * 57) * tmpVal / 100);            // 裤子+def
            } else {
                attrs[3] = uint16((380 + qtyParam * 380) * tmpVal / 100);          // 鞋子+hp
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

        MiningOrderCreated(newOrderId, _miner, _chestCnt);
    }

    function _transferHelper(uint256 ethVal) private {
        bool recommenderSended = false;
        uint256 fVal;
        uint256 pVal;
        if (isRecommendOpen) {
            address recommender = dataContract.getRecommender(msg.sender);
            if (recommender != address(0)) {
                uint256 rVal = ethVal.div(10);
                fVal = ethVal.sub(rVal).mul(prizePoolPercent).div(100);
                addrFinance.transfer(fVal);
                recommenderSended = true;
                recommender.transfer(rVal);
                pVal = ethVal.sub(rVal).sub(fVal);
                if (poolContract != address(0) && pVal > 0) {
                    poolContract.transfer(pVal);
                }
            } 
        } 
        if (!recommenderSended) {
            fVal = ethVal.mul(prizePoolPercent).div(100);
            pVal = ethVal.sub(fVal);
            addrFinance.transfer(fVal);
            if (poolContract != address(0) && pVal > 0) {
                poolContract.transfer(pVal);
            }
        }
    }

    function miningOneFree()
        external
        whenNotPaused
    {
        require(dataContract != address(0));

        uint256 seed = _rand();
        uint16[9] memory attrs = _getFashionParam(seed);

        require(dataContract.subFreeMineral(msg.sender));

        tokenContract.createFashion(msg.sender, attrs, 5);

        MiningResolved(0, msg.sender, 1);
    }

    function miningOneSelf() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.01 ether);

        uint256 seed = _rand();
        uint16[9] memory attrs = _getFashionParam(seed);

        tokenContract.createFashion(msg.sender, attrs, 2);
        _transferHelper(0.01 ether);

        if (msg.value > 0.01 ether) {
            msg.sender.transfer(msg.value - 0.01 ether);
        }

        MiningResolved(0, msg.sender, 1);
    }

    function miningOne() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.01 ether);

        _addOrder(msg.sender, 1);
        _transferHelper(0.01 ether);

        if (msg.value > 0.01 ether) {
            msg.sender.transfer(msg.value - 0.01 ether);
        }
    }

    function miningThree() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.03 ether);

        _addOrder(msg.sender, 3);
        _transferHelper(0.03 ether);

        if (msg.value > 0.03 ether) {
            msg.sender.transfer(msg.value - 0.03 ether);
        }
    }

    function miningFive() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.0475 ether);

        _addOrder(msg.sender, 5);
        _transferHelper(0.0475 ether);

        if (msg.value > 0.0475 ether) {
            msg.sender.transfer(msg.value - 0.0475 ether);
        }
    }

    function miningTen() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.09 ether);
        
        _addOrder(msg.sender, 10);
        _transferHelper(0.09 ether);

        if (msg.value > 0.09 ether) {
            msg.sender.transfer(msg.value - 0.09 ether);
        }
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
            tokenContract.createFashion(miner, attrs, 2);
        }
        order.tmResolve = uint64(block.timestamp);
        MiningResolved(_orderIndex, miner, chestCnt);
    }
}
