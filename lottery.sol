// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Lottery{   
    address public Token;
    address public owner;
    address[] tokensForThisMounts;
    uint256 tekitId=0;
    address[]  lastWinners;
    Ticket[]  EmptyArray;
    LOTTERY_STATE public lotteryState=LOTTERY_STATE.CLOSED;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    event StartLottery(address[]  tokens);
    event PauseLotteryForCalculWinner();
    event SetWinners(uint numberWinners);
    struct Ticket{
        uint TicketId;
        address user;
        address token;
    }
    Ticket[] tikets;
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerTiketsCount;

    constructor(address _adreessToken){
          Token=_adreessToken;
          owner=msg.sender;
      }
    modifier onlyOwner() {
        require(_owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
     function _msgSender() internal view virtual returns (address) {
        return msg.sender;
      }
      function _owner() public view virtual returns (address) {
        return owner;
      }
    function LotteryMount(address[] memory _tokensForThisMounts) public {
        tokensForThisMounts=_tokensForThisMounts;
    }
    function checkBalanceToken(address _tokenAddress,address _user) public view returns(uint ){
         return ERC20(_tokenAddress).balanceOf(_user);
    }
    function startLottery(address[] memory _tokens) public onlyOwner {
         tokensForThisMounts=_tokens;
         lotteryState=LOTTERY_STATE.OPEN;
         emit StartLottery(_tokens);
    }
    function checkAddressInLotteryMount(address _tokenAddress) public view returns (bool){
        bool check=false;
        for(uint i=0;i<tokensForThisMounts.length;i++){
           if(tokensForThisMounts[i]==_tokenAddress)
           check=true;
        }
        return check;
    }
    function checkUseralreadyParticipating(address _user,address _token) public view returns(bool){
         bool check=false;
        for(uint i=0;i<tikets.length;i++){
           if(tikets[i].user==_user && tikets[i].token== _token)
           check=true;
        }
        return check;
    }
    function _approve(address _spender, uint256 _amount) public returns(bool) {
      return ERC20(Token).approve(_spender, _amount);
    }
    function _allowance() public view returns(uint256){
        return ERC20(Token).allowance(msg.sender,address(this));
    }

    function enterToLuttory(address _tokenAddress) public {
        //  require(lotteryState == LOTTERY_STATE.OPEN ,"Lottery Is Closed");
        //  require(checkBalanceToken(_tokenAddress,msg.sender)>0,"Your balance not suffisant");
        //  require(checkAddressInLotteryMount(_tokenAddress),"this token not in list address for this mounts");
        //  require(!checkUseralreadyParticipating(msg.sender,_tokenAddress),"this user is already participating for this token");
        //  uint256 amount = checkBalanceToken(_tokenAddress,msg.sender);
        // _safeTransferFrom(ERC20(_tokenAddress),msg.sender,owner,amount);
        uint256 numberOfTikets=12;
        for(uint i=0;i<numberOfTikets;i++){
            tekitId++;
            Ticket memory T = Ticket(tekitId,msg.sender,_tokenAddress);
            tikets.push(T);
            zombieToOwner[tekitId] = msg.sender;
        }
        ownerTiketsCount[msg.sender]+=numberOfTikets;
    }

    function getNumberOfTiketsForUser(address _user) public view returns(uint){
        return ownerTiketsCount[_user];
    }

    function pauseLotteryForCalculatingWinner() public onlyOwner{
      lotteryState=LOTTERY_STATE.CALCULATING_WINNER;
      emit PauseLotteryForCalculWinner();

    }
    function getUserByTicket(uint _idTiket) public view returns(address){
        return zombieToOwner[_idTiket];
    }
    
    //Erreur not fixed
    function getAllTicketByUser(address _user) public view returns(uint[] memory){
     uint[] memory allTicket=new uint[](getNumberOfTiketsForUser(_user));
     uint index=0;
     for(uint indexOfTikets=0;indexOfTikets<tikets.length;indexOfTikets++){
        if(tikets[indexOfTikets].user==_user){
          allTicket[index]=tikets[indexOfTikets].TicketId;
          index++;
        }
     }
    return allTicket;
    }
    
    function getLastWinners() public view returns(address[] memory){
         return lastWinners;
    }
    

    function redum(uint256 MAX_INT_FROM_BYTE,uint256 NUM_RANDOM_BYTES_REQUESTED) public view returns(uint){
        uint ceiling = (MAX_INT_FROM_BYTE * NUM_RANDOM_BYTES_REQUESTED);
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp)))+ceiling;
        uint spin = (randomNumber % 10009) + 1;
        return spin ;
    }

    function setWinnerTicket(uint8 _nuberWinner) public view returns(uint[] memory) {
      require(tikets.length>_nuberWinner,"The number of participants is small");
      uint[] memory a = new uint[](_nuberWinner);
      for(uint i=0;i<_nuberWinner;i++){
          uint256 hash=112233445566778899**2;
          uint256  rnd=uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,redum(i,hash))));
          a[i]=rnd % tikets.length;
      }
      return a;
    }

    function setWinnersAddress(uint8 _nuberWinner) public onlyOwner{
        uint[] memory winnersTiket=setWinnerTicket(_nuberWinner);
        address[] memory winnersAddress = new address[](_nuberWinner);
        for(uint indexWinnersTiket=0;indexWinnersTiket<winnersTiket.length;indexWinnersTiket++){
            for(uint indexOfTikets=0;indexOfTikets<tikets.length;indexOfTikets++){
                if(winnersTiket[indexWinnersTiket]==tikets[indexOfTikets].TicketId)
                winnersAddress[indexWinnersTiket]=tikets[indexOfTikets].user;
            }
        }
        require(winnersAddress.length==_nuberWinner,"erreur");
        lastWinners=winnersAddress;
        lotteryState=LOTTERY_STATE.CLOSED;
        tikets=EmptyArray;
        emit SetWinners(_nuberWinner);
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
 
 

}
