pragma solidity ^0.4.20;

/// This Random is inspired by https://github.com/axiomzen/eth-random
contract Random {
    uint256 _seed;

    /// @dev 根据合约记录的上一次种子生产一个随机数
    /// @return 返回一个随机数
    function _rand() internal returns (uint256) {
        _seed = uint256(keccak256(_seed, block.blockhash(block.number - 1), block.coinbase, block.difficulty));
        return _seed;
    }

    /// @dev 根据给定的种子生产一个随机数
    /// @param _outSeed 外部给定的种子
    /// @return 返回一个随机数
    function _randBySeed(uint256 _outSeed) internal view returns (uint256) {
        return uint256(keccak256(_outSeed, block.blockhash(block.number - 1), block.coinbase, block.difficulty));
    }

    /*
    function _randByRange(uint256 _min, uint256 _max) internal returns (uint256) {
        if (_min >= _max) {
            return _min;
        }
        return (_rand() % (_max - _min)) + _min;
    }

    function _rankByNumber(uint256 _max) internal returns (uint256) {
        return _rand() % _max;
    }
    */
}