pragma solidity 0.4.24;

import "@goplugin/contracts/src/v0.4/vendor/Ownable.sol";
import "@goplugin/contracts/src/v0.4/PluginClient.sol";

contract InternalContract is PluginClient, Ownable {
    
  //Initialize Oracle Payment     
  uint256 constant private ORACLE_PAYMENT = 0.01 * 10**18;
  address public oracle;  // "0x97A6d407f4CD30936679d0a28A3bc2A7F13a2185"
  string  public jobId;   // "32abe898ea834e328ebeb714c5a0991d"
  uint256 public currentValue;

  //struct to keep track of PLI Deposits
  struct PLIDatabase{
    address depositor;
    uint256 totalcredits;
  }

  mapping(address => PLIDatabase) public plidbs;

  //Initialize event RequestFulfilled   
  event RequestFulfilled(
    bytes32 indexed requestId,
    uint256 indexed currentVal
  );

  //Initialize event requestCreated   
  event requestCreated(address indexed requester,bytes32 indexed jobId, bytes32 indexed requestId);
  event requestCreatedTest(bytes32 indexed jobId, bytes32 indexed requestId);

  //Constructor to pass Pli Token Address during deployment
  constructor(address _pli,address _oracle,string memory _jobid) public Ownable() {
    setPluginToken(_pli);
    oracle = address(_oracle);
    jobId = _jobid;
  }

  function depositPLI(uint256 _value) public returns(bool) {
      require(_value<=100*10**18,"NOT_MORE_THAN_100_ALLOWED");
      //Transfer PLI to contract
      PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
      pli.transferFrom(msg.sender,address(this),_value);
      //Track the PLI deposited for the user
      PLIDatabase memory _plidb = plidbs[msg.sender];
      uint256 _totalCredits = _plidb.totalcredits + _value;
      plidbs[msg.sender] = PLIDatabase(
        msg.sender,
        _totalCredits
      );
      return true;
  }

  function showPrice() public view returns(uint256){
    return currentValue;
  }
  //_fsyms should be the name of your source token from which you want the comparison 
  //_tsyms should be the name of your destinaiton token to which you need the comparison
  //_jobID should be tagged in Oracle
  //_oracle should be fulfiled with your plugin node address

  function requestData(address _caller)
    public
    returns (bytes32 requestId)
  {
    //Check the total Credits available for the user to perform the transaction
    uint256 _a_totalCredits = plidbs[_caller].totalcredits;
    require(_a_totalCredits>ORACLE_PAYMENT,"NO_SUFFICIENT_CREDITS");
    plidbs[_caller].totalcredits = _a_totalCredits - ORACLE_PAYMENT;
    
    //Built a oracle request with the following params
    Plugin.Request memory req = buildPluginRequest(stringToBytes32(jobId), this, this.fulfill.selector);
    req.add("_fsyms","XDC");
    req.add("_tsyms","USDT");
    req.addInt("times", 10000);
    requestId = sendPluginRequestTo(oracle, req, ORACLE_PAYMENT);
    emit requestCreated(_caller, stringToBytes32(jobId), requestId);
  }

 function testMyFunc()
    public
    onlyOwner
    returns (bytes32 requestId)
  {    
    //Built a oracle request with the following params
    Plugin.Request memory req = buildPluginRequest(stringToBytes32(jobId), this, this.fulfill.selector);
    req.add("_fsyms","XDC");
    req.add("_tsyms","USDT");
    req.addInt("times", 10000);
    requestId = sendPluginRequestTo(oracle, req, ORACLE_PAYMENT);
    emit requestCreatedTest(stringToBytes32(jobId), requestId);
  }


  //callBack function
  function fulfill(bytes32 _requestId, uint256 _currentval)
    public
    recordPluginFulfillment(_requestId)
  {
    // if that speed < 65kmph
    // do write logic for token transfer
    emit RequestFulfilled(_requestId, _currentval);
    currentValue = _currentval;
  }

  function getPluginToken() public view returns (address) {
    return pluginTokenAddress();
  }

  //With draw pli can be invoked only by owner
  function withdrawPli() public onlyOwner {
    PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
    require(pli.transfer(msg.sender, pli.balanceOf(address(this))), "Unable to transfer");
  }

  //Cancel the existing request
  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
    public
    onlyOwner
  {
    cancelPluginRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  //String to bytes to convert jobid to bytest32
  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }
    assembly { 
      result := mload(add(source, 32))
    }
  }

}
