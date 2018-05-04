pragma solidity ^0.4.20;

interface IBitGuildToken {
    function transfer(address _to, uint256 _value) external;
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external; 
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool);
    function balanceOf(address _from) external view returns(uint256);
}
