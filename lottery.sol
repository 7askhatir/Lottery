// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Lottery{   
    address public Token;
    address public owner;
    address[] tokensForThisMounts;
    uint256 tekitId=0;
    mapping (address => uint) public AllTekit;

    LOTTERY_STATE public lotteryState;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    address payable[] public players;
    struct Ticket{
        uint TicketId;
        address user;
    }
    Ticket[] tikets;
    mapping (uint => address) public zombieToOwner;
    constructor(address _adreessToken){
          Token=_adreessToken;
          owner=msg.sender;
      }
    function LotteryMount(address[] memory _tokensForThisMounts) public {
        tokensForThisMounts=_tokensForThisMounts;
    }
    function checkBalanceToken(address _tokenAddress,address _user) public view returns(uint ){
         return ERC20(_tokenAddress).balanceOf(_user);
    }
    function startLottery(address[] memory _tokens) public {
         tokensForThisMounts=_tokens;
         lotteryState==LOTTERY_STATE.OPEN;
    }
    function checkAddressInLotteryMount(address _tokenAddress) public view returns (bool){
        bool check=false;
        for(uint i=0;i<tokensForThisMounts.length;i++){
           if(tokensForThisMounts[i]==_tokenAddress)
           check=true;
        }
        return check;
    }
    function checkUseralreadyParticipating(address _user) public view returns(bool){
         bool check=false;
        for(uint i=0;i<players.length;i++){
           if(players[i]==_user)
           check=true;
        }
        return check;
    }
    function enterToLuttory(address _tokenAddress ,address _user) public {
        require(lotteryState==LOTTERY_STATE.OPEN ,"Lottery Is Closed");
        require(checkBalanceToken(_tokenAddress,_user)>0,"Your balance");
        require(checkAddressInLotteryMount(_tokenAddress),"this token not in list address for this mounts");
        require(!checkUseralreadyParticipating(_user),"this user is already participating");
        uint amount = checkBalanceToken(_tokenAddress,_user);
        _safeTransferFrom(ERC20(_tokenAddress),msg.sender,owner,amount);
        for(uint i=0;i<_balanceFromAdress(Token,_user)/10**18;i++){
            tekitId++;
            Ticket memory T = Ticket(tekitId,_user);
            tikets.push(T);
            zombieToOwner[tekitId] = _user;
        }
        players.push(payable(_user));
    }
    function getUserByTicket(uint _idTiket) public view returns(address){
        return zombieToOwner[_idTiket];
    }
    function allPlayers() public view returns(address payable[] memory){
        return players;
    }
    function getAllTicketByUser(address _user) public view returns(uint[] memory){
     uint[] memory allTicket;
     for(uint indexOfTikets=0;indexOfTikets<tikets.length;indexOfTikets++){
         uint index=0;
         if(tikets[indexOfTikets].user==_user){
          allTicket[index]=tikets[indexOfTikets].TicketId;
          index++;
         }
     }
    return allTicket;
    }
    function redum(uint256 MAX_INT_FROM_BYTE,uint256 NUM_RANDOM_BYTES_REQUESTED) public view returns(uint){
        uint ceiling = (MAX_INT_FROM_BYTE * NUM_RANDOM_BYTES_REQUESTED);
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp)))+ceiling;
        uint spin = (randomNumber % 10009) + 1;
        return spin ;
    }

    function getWinnerTicket(uint8 _nuberWinner) public view returns(uint[] memory) {
      require(tikets.length>_nuberWinner,"The number of participants is small");
      uint[] memory a = new uint[](_nuberWinner);
      for(uint i=0;i<_nuberWinner;i++){
          uint256 hash=112233445566778899**2;
          uint256  rnd=uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,redum( i,hash))));
          a[i]=rnd % tikets.length;
      }
      return a;

    }
        function _safeTransferFrom(
        ERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        require(sender != address(0),"address of sender Incorrect ");
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
    function _balanceFromAdress(address _user,address _token) private view returns(uint){
        require(_user != address(0),"address of sender Incorrect ");
        uint balance =ERC20(_token).balanceOf(_user);
        return balance;
    }
 

}
