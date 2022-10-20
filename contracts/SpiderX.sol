// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SpiderX {

    IERC20 token;
    
    address private owner;

    address private admin;

    mapping (string => uint)private prices;

    mapping (address => uint) public balances;

    mapping (uint => uint) private rooms;

    mapping (address => string) private nicknames;

    mapping (address => string) private avatars;


    modifier OnlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "not an owner!");
        _;
    }

    event Deposit(address indexed player, uint amount);

    event Withdraw(address indexed player, uint amount);

    event CreateRoom(uint indexed roomId, address[] indexed players, uint amount);

    event CancellGame(uint indexed roomId);

    event Payment(uint indexed roomId, address winner, uint amount);

    event NicknameChange(address indexed player);

    event AvatarChange(address indexed player);

    event PayMessage(address indexed player);

    event Delegate(address indexed admin, address indexed newAdmin);

    event NewPrice(string indexed service, uint newPrice);

    constructor() {
        token = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        owner = msg.sender;
        admin = 0xA9485322f292196B5c270318eE3a093Cb86dA2DF;
        prices["nickname"] = 0;
        prices["avatar"] = 0;
        prices["message"] = 0;
        prices["commission"] = 1;
    }
    
    function deposit(uint amount, address user) public OnlyAdmin {
        require(token.balanceOf(user) >= amount, "zero balance!");
        balances[user] += amount;
        emit Deposit(user, amount);
    }

    function withdraw(uint amount) public {
        require(amount <= balances[msg.sender], "insufficient funds!");
        balances[msg.sender] -= amount;
        uint commission = amount*prices["commission"]/100;
        balances[owner] += commission;
        token.transfer(msg.sender, amount - commission);
        emit Withdraw(msg.sender, amount - commission);
    }

    function createRoom(uint roomId, address[] memory players, uint amount) internal OnlyAdmin {
        for (uint i = 0; i < players.length; i++){
            require(amount <= balances[players[i]], "insufficient funds!");
        }
        for (uint i = 0; i < players.length; i++){
            balances[players[i]] -= amount;
            rooms[roomId] += amount;
        }
        emit CreateRoom (roomId, players, rooms[roomId]);
    }

    function gameResult(uint roomId, address winner) internal OnlyAdmin {
        uint amount = rooms[roomId];
        balances[winner] += amount;
        rooms[roomId] -= amount;
        emit Payment (roomId, winner, amount);
    }

    function gameCancellation(uint roomId) internal OnlyAdmin {
        emit CancellGame (roomId);
    }

    function setNickname(string memory newNickname) internal {
        require(balances[msg.sender] >= prices["nickname"], "insufficient funds!");
        balances[msg.sender] -= prices["nickname"];
        nicknames[msg.sender] = newNickname;
        emit NicknameChange(msg.sender);
    }

    function setAvatar(string memory newAvatarUri) internal {
        require(balances[msg.sender] >= prices["avatar"], "insufficient funds!");
        balances[msg.sender] -= prices["avatar"];
        avatars[msg.sender] = newAvatarUri;
        emit AvatarChange(msg.sender);
    }

    function payMessage() internal {
        require(balances[msg.sender] >= prices["message"], "insufficient funds!");
        balances[msg.sender] -= prices["message"];
        emit PayMessage(msg.sender);
    }

    function setPrices(string memory service, uint newPrice) internal OnlyAdmin {
        prices[service] = newPrice;
        emit NewPrice(service, newPrice);
    }

    function delegateAdmin(address newAdmin) internal OnlyOwner {
        emit Delegate(admin, newAdmin);
        admin = newAdmin;
    } 

    function GetPoolBalance() public view returns (uint256 balance) {
        return token.balanceOf(address(this));
    }

    function GetUserBalance() public view returns(uint256){ 
       return token.balanceOf(msg.sender);
    }

}
