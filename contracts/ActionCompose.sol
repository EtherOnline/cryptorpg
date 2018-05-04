pragma solidity ^0.4.20;

import "./WarToken.sol";
import "./AccessService.sol";
import "./Random.sol";
import "./IDataInterface.sol";
import "./SafeMath.sol";

contract ActionCompose is Random, AccessService {
    using SafeMath for uint256;

    event ComposeSuccess(address indexed owner, uint256 tokenId, uint16 protoId, uint16 quality, uint16 pos);
    
    /// @dev If the recommender can get reward 
    bool isRecommendOpen;
    /// @dev prizepool percent
    uint256 constant prizePoolPercent = 50;
    /// @dev prizepool contact address
    address poolContract;
    /// @dev DataMining contract address
    IDataMining public dataContract;
    /// @dev DataEquip contract address
    IDataEquip public equipContract;
    /// @dev WarToken(NFT) contract address
    WarToken public tokenContract;

    function ActionCompose(address _nftAddr) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = WarToken(_nftAddr);
    }

    function() external payable {

    }

    function setRecommendStatus(bool _isOpen) external onlyAdmin {
        require(_isOpen != isRecommendOpen);
        isRecommendOpen = _isOpen;
    }

    function setDataMining(address _addr) external onlyAdmin {
        require(_addr != address(0));
        dataContract = IDataMining(_addr);
    }

    function setPrizePool(address _addr) external onlyAdmin {
        require(_addr != address(0));
        poolContract = _addr;
    }

    function setDataEquip(address _addr) external onlyAdmin {
        require(_addr != address(0));
        equipContract = IDataEquip(_addr);
    }

    function _getFashionParam(uint256 _seed, uint16 _protoId, uint16 _quality, uint16 _pos) internal pure returns(uint16[9] attrs) {
        uint256 curSeed = _seed;
        attrs[0] = _protoId;
        attrs[1] = _quality;
        attrs[2] = _pos;

        uint16 qtyParam = 0;
        if (_quality <= 3) {
            qtyParam = _quality - 1;
        } else if (_quality == 4) {
            qtyParam = 4;
        } else if (_quality == 5) {
            qtyParam = 6;
        }

        // 生成属性
        uint256 rdm = _protoId % 3;

        curSeed /= 10000;
        uint256 tmpVal = (curSeed % 10000) % 21 + 90;

        // 武器1/帽子2/衣服3/裤子4/鞋子5
        if (rdm == 0) {
            if (_pos == 1) {
                uint256 attr = (200 + qtyParam * 200) * tmpVal / 100;              // 武器+atk
                attrs[4] = uint16(attr * 40 / 100);
                attrs[5] = uint16(attr * 160 / 100);
            } else if (_pos == 2) {
                attrs[6] = uint16((40 + qtyParam * 40) * tmpVal / 100);            // 帽子+def
            } else if (_pos == 3) {
                attrs[3] = uint16((600 + qtyParam * 600) * tmpVal / 100);          // 衣服+hp
            } else if (_pos == 4) {
                attrs[6] = uint16((60 + qtyParam * 60) * tmpVal / 100);            // 裤子+def
            } else {
                attrs[3] = uint16((400 + qtyParam * 400) * tmpVal / 100);          // 鞋子+hp
            }
        } else if (rdm == 1) {
            if (_pos == 1) {
                uint256 attr2 = (190 + qtyParam * 190) * tmpVal / 100;              // 武器+atk
                attrs[4] = uint16(attr2 * 50 / 100);
                attrs[5] = uint16(attr2 * 150 / 100);
            } else if (_pos == 2) {
                attrs[6] = uint16((42 + qtyParam * 42) * tmpVal / 100);            // 帽子+def
            } else if (_pos == 3) {
                attrs[3] = uint16((630 + qtyParam * 630) * tmpVal / 100);          // 衣服+hp
            } else if (_pos == 4) {
                attrs[6] = uint16((63 + qtyParam * 63) * tmpVal / 100);            // 裤子+def
            } else {
                attrs[3] = uint16((420 + qtyParam * 420) * tmpVal / 100);          // 鞋子+hp
            }
        } else {
            if (_pos == 1) {
                uint256 attr3 = (210 + qtyParam * 210) * tmpVal / 100;             // 武器+atk
                attrs[4] = uint16(attr3 * 30 / 100);
                attrs[5] = uint16(attr3 * 170 / 100);
            } else if (_pos == 2) {
                attrs[6] = uint16((38 + qtyParam * 38) * tmpVal / 100);            // 帽子+def
            } else if (_pos == 3) {
                attrs[3] = uint16((570 + qtyParam * 570) * tmpVal / 100);          // 衣服+hp
            } else if (_pos == 4) {
                attrs[6] = uint16((57 + qtyParam * 57) * tmpVal / 100);            // 裤子+def
            } else {
                attrs[3] = uint16((380 + qtyParam * 380) * tmpVal / 100);          // 鞋子+hp
            }
        }
        attrs[8] = 0;
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

    // gas 210019
    function lowCompose(uint256 token1, uint256 token2) 
        external
        payable
        whenNotPaused
    {
        require(msg.value >= 0.003 ether);
        require(tokenContract.ownerOf(token1) == msg.sender);
        require(tokenContract.ownerOf(token2) == msg.sender);
        require(!equipContract.isEquipedAny2(msg.sender, token1, token2));

        tokenContract.ownerOf(token1);

        uint16 protoId;
        uint16 quality;
        uint16 pos; 
        uint16[12] memory fashionData = tokenContract.getFashion(token1);
        protoId = fashionData[0];
        quality = fashionData[1];
        pos = fashionData[2];

        require(quality == 1 || quality == 2); 

        fashionData = tokenContract.getFashion(token2);
        require(protoId == fashionData[0]);
        require(quality == fashionData[1]);
        require(pos == fashionData[2]);

        uint256 seed = _rand();
        uint16[9] memory attrs = _getFashionParam(seed, protoId, quality + 1, pos);

        tokenContract.destroyFashion(token1, 1);
        tokenContract.destroyFashion(token2, 1);

        uint256 newTokenId = tokenContract.createFashion(msg.sender, attrs, 3);
        _transferHelper(0.003 ether);

        if (msg.value > 0.003 ether) {
            msg.sender.transfer(msg.value - 0.003 ether);
        }

        ComposeSuccess(msg.sender, newTokenId, attrs[0], attrs[1], attrs[2]);
    }

    // gas 198125
    function highCompose(uint256 token1, uint256 token2, uint256 token3) 
        external
        payable
        whenNotPaused
    {
        require(msg.value >= 0.005 ether);
        require(tokenContract.ownerOf(token1) == msg.sender);
        require(tokenContract.ownerOf(token2) == msg.sender);
        require(tokenContract.ownerOf(token3) == msg.sender);
        require(!equipContract.isEquipedAny3(msg.sender, token1, token2, token3));

        uint16 protoId;
        uint16 quality;
        uint16 pos; 
        uint16[12] memory fashionData = tokenContract.getFashion(token1);
        protoId = fashionData[0];
        quality = fashionData[1];
        pos = fashionData[2];

        require(quality == 3 || quality == 4);       

        fashionData = tokenContract.getFashion(token2);
        require(protoId == fashionData[0]);
        require(quality == fashionData[1]);
        require(pos == fashionData[2]);

        fashionData = tokenContract.getFashion(token3);
        require(protoId == fashionData[0]);
        require(quality == fashionData[1]);
        require(pos == fashionData[2]);

        uint256 seed = _rand();
        uint16[9] memory attrs = _getFashionParam(seed, protoId, quality + 1, pos);

        tokenContract.destroyFashion(token1, 1);
        tokenContract.destroyFashion(token2, 1);
        tokenContract.destroyFashion(token3, 1);

        uint256 newTokenId = tokenContract.createFashion(msg.sender, attrs, 4);
        _transferHelper(0.005 ether);

        if (msg.value > 0.005 ether) {
            msg.sender.transfer(msg.value - 0.005 ether);
        }

        ComposeSuccess(msg.sender, newTokenId, attrs[0], attrs[1], attrs[2]);
    }
}
