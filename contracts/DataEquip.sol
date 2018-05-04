pragma solidity ^0.4.20;

import "./WarToken.sol";
import "./AccessService.sol";
import "./IDataInterface.sol";

contract DataEquip is AccessService, IDataEquip {
    event EquipChanged(address indexed _target);

    /// @dev WarToken(NFT) contract address
    WarToken public tokenContract;
    mapping (address => uint256) public slotWeapon;
    mapping (address => uint256) public slotHat;
    mapping (address => uint256) public slotCloth;
    mapping (address => uint256) public slotPant;
    mapping (address => uint256) public slotShoes;
    mapping (address => uint256) public slotPet;

    function DataEquip(address _nftAddr) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = WarToken(_nftAddr);
    }

    function _equipUpOne(address _owner, uint256 _tokenId) private {
        require(tokenContract.ownerOf(_tokenId) == _owner);
        uint16[12] memory attrs = tokenContract.getFashion(_tokenId);
        uint16 pos = attrs[2];
        if (pos == 1) {
            if (slotWeapon[_owner] != _tokenId) {
                slotWeapon[_owner] = _tokenId;
            }
        } else if (pos == 2) {
            if (slotHat[_owner] != _tokenId) {
                slotHat[_owner] = _tokenId;
            }
        } else if (pos == 3) {
            if (slotCloth[_owner] != _tokenId) {
                slotCloth[_owner] = _tokenId;
            }
        } else if (pos == 4) {
            if (slotPant[_owner] != _tokenId) {
                slotPant[_owner] = _tokenId;
            }
        } else if (pos == 5) {
            if (slotShoes[_owner] != _tokenId) {
                slotShoes[_owner] = _tokenId;
            }
        } else if (pos == 9) {
            if (slotPet[_owner] != _tokenId) {
                slotPet[_owner] = _tokenId;
            }
        }
    }

    function _equipDownOne(address _owner, uint16 _index) private {
        if (_index == 0) {
            if (slotWeapon[_owner] != 0) {
                slotWeapon[_owner] = 0;
            }
        } else if (_index == 1) {
            if (slotHat[_owner] != 0) {
                slotHat[_owner] = 0;
            }
        } else if (_index == 2) {
            if (slotCloth[_owner] != 0) {
                slotCloth[_owner] = 0;
            }
        } else if (_index == 3) {
            if (slotPant[_owner] != 0) {
                slotPant[_owner] = 0;
            }
        } else if (_index == 4) {
            if (slotShoes[_owner] != 0) {
                slotShoes[_owner] = 0;
            }
        } else if (_index == 5) {
            if (slotPet[_owner] != 0) {
                slotPet[_owner] = 0;
            }
        }
    }

    // gas: 204885
    function equipUp(uint256[6] _tokens) 
        external 
        whenNotPaused
    {
        for (uint16 i = 0; i < 6; ++i) {
            if (_tokens[i] > 0) {
                _equipUpOne(msg.sender, _tokens[i]);
            } else {
                _equipDownOne(msg.sender, i);      // tokenId 0 will be equip down
            }  
        }
        EquipChanged(msg.sender);
    }

    function equipDown(uint256 _tokenId) 
        external
        whenNotPaused 
    {
        
    }    

    function isEquiped(address _target, uint256 _tokenId) external view returns(bool) {
        require(_target != address(0));
        require(_tokenId > 0);

        if (slotWeapon[_target] == _tokenId) {
            return true;
        }

        if (slotHat[_target] == _tokenId) {
            return true;
        }

        if (slotCloth[_target] == _tokenId) {
            return true;
        }

        if (slotPant[_target] == _tokenId) {
            return true;
        }

        if (slotShoes[_target] == _tokenId) {
            return true;
        }

        if (slotPet[_target] == _tokenId) {
            return true;
        }
        return false;
    }

    function isEquipedAny2(address _target, uint256 _tokenId1, uint256 _tokenId2) external view returns(bool) {
        require(_target != address(0));
        require(_tokenId1 > 0);
        require(_tokenId2 > 0);
        
        uint256 equipTokenId = slotWeapon[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2) {
            return true;
        }

        equipTokenId = slotHat[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2) {
            return true;
        }

        equipTokenId = slotCloth[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2) {
            return true;
        }

        equipTokenId = slotPant[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2) {
            return true;
        }

        equipTokenId = slotShoes[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2) {
            return true;
        }

        equipTokenId = slotPet[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2) {
            return true;
        }
        return false;
    }

    function isEquipedAny3(address _target, uint256 _tokenId1, uint256 _tokenId2, uint256 _tokenId3) external view returns(bool) {
        require(_target != address(0));
        require(_tokenId1 > 0);
        require(_tokenId2 > 0);
        require(_tokenId3 > 0);
        
        uint256 equipTokenId = slotWeapon[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2 || equipTokenId == _tokenId3) {
            return true;
        }

        equipTokenId = slotHat[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2 || equipTokenId == _tokenId3) {
            return true;
        }

        equipTokenId = slotCloth[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2 || equipTokenId == _tokenId3) {
            return true;
        }

        equipTokenId = slotPant[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2 || equipTokenId == _tokenId3) {
            return true;
        }

        equipTokenId = slotShoes[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2 || equipTokenId == _tokenId3) {
            return true;
        }

        equipTokenId = slotPet[_target];
        if (equipTokenId == _tokenId1 || equipTokenId == _tokenId2 || equipTokenId == _tokenId3) {
            return true;
        }
        return false;
    }

    function getEquipTokens(address _target) external view returns(uint256[6] tokens) {
        tokens[0] = slotWeapon[_target];
        tokens[1] = slotHat[_target];
        tokens[2] = slotCloth[_target];
        tokens[3] = slotPant[_target];
        tokens[4] = slotShoes[_target];
        tokens[5] = slotPet[_target];
    }
}
