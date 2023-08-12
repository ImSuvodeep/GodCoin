//SPDX-License-Identifier:MIT

pragma solidity 0.8.0;


contract proxy{
    address public owner;
    address public implementation;
    uint public count;
    string public name;
    string public symbol;
    uint timeBeforeSend;
    uint public  totalSupply;
    uint feesAmount;
    uint minFeesClaim;
    uint public buytime;
    uint public sellTime;
    mapping(address=>mapping(address=>uint)) transferTime;
    mapping(address=>uint ) public feesCollected;
    mapping(address=>mapping(address=>uint)) public partialSpending;
    mapping(address=>uint) totalApprovalTime;
    mapping(address=>mapping(address=>uint)) approveAmount;
    mapping(address=>mapping(address=>bool)) public isApproved;
    mapping(address=>mapping(address=>uint)) public  approvalTime;
    mapping(address=>address)approvalOwner;
    mapping(address=>uint)public partialApproval;
    mapping(address=>bool) public approved;
    mapping(address=>mapping(address=>uint)) public transactionFeesCollected;
    mapping(address=>bool) internal isBlackListed;
    mapping(address=>mapping(address=>bool)) hasSendOnce;
    mapping(address=>buyer) public buyerDetails;
    mapping(address=>uint) public balance;
    event TransferWithFees(address from, address to, uint totalAmount, uint fees);

    struct buyer{
        address _buyer;
        mapping(address=>uint) timestamp;
        mapping(address=>uint ) timeToBeSend;
        uint _amount;
    }

    constructor(){
        owner = msg.sender;
    }

    function delegate()private{
        (bool ok, bytes memory data) = implementation.delegatecall(msg.data);
        require(ok, "delegatecall failed");
    }

    function setImplementation(address _implementation) public{
        require(owner == msg.sender,"Only Onwers can assign new upgreade");
        implementation = _implementation;
    }

    fallback()external payable{
        delegate();
    }
    
    receive()external payable{
        delegate();
    }
}

contract GodCoinV1{
    address public owner;
    address public implementation;
    uint public count;
    string public name;
    string public symbol;
    uint timeBeforeSend;
    uint public  totalSupply;
    uint feesAmount;
    uint minFeesClaim;
    uint public buytime;
    uint public sellTime;
    mapping(address=>mapping(address=>uint)) transferTime;
    mapping(address=>uint ) public feesCollected;
    mapping(address=>mapping(address=>uint)) public partialSpending;
    mapping(address=>uint) totalApprovalTime;
    mapping(address=>mapping(address=>uint)) approveAmount;
    mapping(address=>mapping(address=>bool)) public isApproved;
    mapping(address=>mapping(address=>uint)) public  approvalTime;
    mapping(address=>address)approvalOwner;
    mapping(address=>uint)public partialApproval;
    mapping(address=>bool) public approved;
    mapping(address=>mapping(address=>uint)) public transactionFeesCollected;
    mapping(address=>bool) internal isBlackListed;
    mapping(address=>mapping(address=>bool)) hasSendOnce;
    mapping(address=>buyer) public buyerDetails;
    mapping(address=>uint) public balance;
    event TransferWithFees(address from, address to, uint totalAmount, uint fees);

    constructor(){
        name = "GODCOIN";
        symbol = "GC";
        owner = msg.sender;
        feesAmount = 3;
        minFeesClaim = 100;
    }

    modifier onlyOwner(){
        require(owner == msg.sender,"Only Token Owner");
        _;
    }

    

    function mintTokens(uint _amount) public{
        mint(_amount);
    }

    function mint(uint _amount) private onlyOwner {
        require(_amount >= 0,"Amount should be greater than 0");
        balance[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function burn(uint _amount) private onlyOwner{
        require(_amount >= 0,"Amount should be greater than 0");
        balance[owner] -= _amount;
        totalSupply -= _amount;
    }

    function burnToken(uint _amount) public{
        burn(_amount);
    }

    function renounceOwnership() public{
        _renounceOwnership();
    }

    function _renounceOwnership() private onlyOwner{
        uint amount = balance[owner];
        balance[address(this)] = amount;
        balance[owner] = 0;
        owner = address(0);
        owner = address(this);
    }


    



    struct buyer{
        address _buyer;
        mapping(address=>uint) timestamp;
        mapping(address=>uint ) timeToBeSend;
        uint _amount;
    }

    

    function buyToken(uint _amount) public{
        buyTokens(_amount);
    }

    function buyTokens(uint _amount) private  {
        require(!isBlackListed[msg.sender],"Your account is blacklisted");
        require(msg.sender != owner,"Not owners");
        require(balance[msg.sender] <= totalSupply,"Not good");
        require(balance[owner] >= _amount*2 ,"Not Enough Tokens");
        balance[msg.sender] += _amount;
        balance[owner] -= _amount;
        buyer storage b = buyerDetails[msg.sender];
        b._buyer = msg.sender;
        b.timestamp[msg.sender] = block.timestamp;
        buytime = block.timestamp;
        b._amount = _amount;
        b.timeToBeSend[msg.sender] = block.timestamp + 20 seconds;
        sellTime = block.timestamp + 20 seconds;
        // timeBeforeSend = block.timestamp + 100 seconds;
        totalSupply -= _amount;


    }

    
   

    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

    //0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

    //0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

    modifier hasEnoughBalance(uint _amount){
        require(balance[msg.sender] >= _amount,"Not Enough Balance");
        _;
    }

    modifier hasTimePassed(){
        require(block.timestamp > buyerDetails[msg.sender].timeToBeSend[msg.sender]  ,"Time has not reached yet");
        _;
    }

    


    function time()public view returns (uint){
        return block.timestamp;
    }

    modifier isPartialApproved(uint _amount){
        require(partialApproval[msg.sender] >= _amount || balance[msg.sender] >= _amount,"Not Enough Balance");
        _;
    }

    
    

    function transferTokens(address to, uint _amount) public{
        transferToken(to, _amount);
    }

    function transferToken(address to, uint _amount) private _isBlackListed(to) isPartialApproved(_amount)  hasTimePassed { 
        require(!hasSendOnce[msg.sender][to]);
        require(to != msg.sender,"Self transfers are not allowed");
        uint valueToSend;
        uint fees;
        if (approved[msg.sender]){
            // address _owner = approvalOwner[msg.sender];
            require(totalApprovalTime[msg.sender] > block.timestamp,"Token Approval deadline is finished");
            fees = calculateFees(_amount);
            valueToSend = _amount - fees;
            partialApproval[msg.sender] -= _amount;
            feesCollected[msg.sender] += fees;
            hasSendOnce[msg.sender][to] = true;
            buyerDetails[msg.sender].timeToBeSend[msg.sender] = block.timestamp + 20 seconds;
            hasSendOnce[msg.sender][to] = false;
            // balance[_owner] -= _amount;
            balance[to] += valueToSend;
            // partialSpending[_owner][msg.sender] -= _amount;


        }else{
            balance[msg.sender] -= _amount;
            fees = calculateFees(_amount);
            valueToSend = _amount - fees;
            balance[to] += valueToSend;
            feesCollected[msg.sender] += fees;
            hasSendOnce[msg.sender][to] = true;

        if (hasSendOnce[msg.sender][to]){
            buyerDetails[msg.sender].timeToBeSend[msg.sender] = block.timestamp + 20 seconds;
            hasSendOnce[msg.sender][to] = false;

        }
        }

        emit TransferWithFees(msg.sender, to, valueToSend, fees);
        // transferTime[msg.sender][to] = block.timestamp;
        // balance[to] += valueToSend;
        
        
    }

    
    

    function increseAllowence(address to, uint amount) public {
        require(!isBlackListed[msg.sender],"Your account is blacklisted");
        require(balance[msg.sender] >= amount  ,"Not Enough Tokens");
        require(isApproved[msg.sender][to],"You've not approved this account");
        partialApproval[to] += amount;
        balance[msg.sender] -= amount;
        approveAmount[msg.sender][to] += amount;
        partialSpending[msg.sender][to] += amount;

    }



    function decreaseAllowence(address to, uint _amount) public{
        require(!isBlackListed[msg.sender],"Your account is blacklisted");
        require(isApproved[msg.sender][to],"You've not approve this account");
        require(partialSpending[msg.sender][to] >= _amount,"You're approved token are already spended");
        balance[msg.sender] += _amount;
        partialSpending[msg.sender][to] -= _amount;
        approveAmount[msg.sender][to] -= _amount;
        
        // uint _amount = partialApproval[to];
        // require(balance[msg.sender] >= amount  ,"Not Enough Tokens");
        // require(isApproved[msg.sender][to],"You've not approved this account");
        partialApproval[to] -= _amount;

    }




    function _assignApproval(address to, uint amount) private _isBlackListed(to) hasEnoughBalance(amount) {
        require(balance[msg.sender] >= amount,"Not enough balance to approve");
        require(!isApproved[msg.sender][to],"Already approved");
        require(approveAmount[msg.sender][to] == 0,"Alreadty some token are approve to this address ");
        approvalTime[msg.sender][to] = block.timestamp + 100 seconds;
        approvalOwner[to] = msg.sender;
        isApproved[msg.sender][to] = true;
        partialApproval[to] += amount;
        approved[to] = true;
        totalApprovalTime[to] = block.timestamp + 60;
        approveAmount[msg.sender][to] = amount;
        partialSpending[msg.sender][to] = amount;
        balance[msg.sender] -= amount;
    }

    function assignApproval(address to, uint amount)public{
        _assignApproval(to, amount);
    }




    function _rejectApproval(address _of) private{
        // require(approvalTime[msg.sender][_of] >= block.timestamp,"You can't reject approval before time");
        require(isApproved[msg.sender][_of],"You've not approved this address to use your tokens");
        uint _amount = partialSpending[msg.sender][_of];
        approveAmount[msg.sender][_of] = 0;
        partialSpending[msg.sender][_of] = 0;
        partialApproval[_of] -= _amount;
        isApproved[msg.sender][_of]  = false;

    }

    function rejectApproval(address _of) public{
        _rejectApproval(_of);
    }

    
    

    function collectFees() private{
        uint amount = feesCollected[msg.sender];
        require(amount >= minFeesClaim,"Your collected fees is not satisfying our mim claim");
        balance[msg.sender] += amount;
        feesCollected[msg.sender] = 0;
    }

    

    function collectYourFees()public{
        collectFees();
    }

    function calculateFees(uint value) public view returns (uint){
        return (value * feesAmount) / 10000;
    }





    modifier _isBlackListed(address _to){
        require(!isBlackListed[_to] && !isBlackListed[msg.sender],"This Acccount is blacklisted");
        _;
    }

    function addToBlackList(address to) private {
        isBlackListed[to] = true;

    }

    function inc()external {
        count += 1;
    }

    // function dec()external {
    //     count -= 1;
    // }


}

contract GodCoinV2{
    address public owner;
    address public implementation;
    uint public count;
    string public name;
    string public symbol;
    uint timeBeforeSend;
    uint public  totalSupply;
    uint feesAmount;
    uint minFeesClaim;
    uint public buytime;
    uint public sellTime;
    mapping(address=>mapping(address=>uint)) transferTime;
    mapping(address=>uint ) public feesCollected;
    mapping(address=>mapping(address=>uint)) public partialSpending;
    mapping(address=>uint) totalApprovalTime;
    mapping(address=>mapping(address=>uint)) approveAmount;
    mapping(address=>mapping(address=>bool)) public isApproved;
    mapping(address=>mapping(address=>uint)) public  approvalTime;
    mapping(address=>address)approvalOwner;
    mapping(address=>uint)public partialApproval;
    mapping(address=>bool) public approved;
    mapping(address=>mapping(address=>uint)) public transactionFeesCollected;
    mapping(address=>bool) internal isBlackListed;
    mapping(address=>mapping(address=>bool)) hasSendOnce;
    mapping(address=>buyer) public buyerDetails;
    mapping(address=>uint) public balance;
    event TransferWithFees(address from, address to, uint totalAmount, uint fees);

    constructor(){
        name = "GODCOIN";
        symbol = "GC";
        owner = msg.sender;
        feesAmount = 3;
        minFeesClaim = 100;
    }

    modifier onlyOwner(){
        require(owner == msg.sender,"Only Token Owner");
        _;
    }

    

    function mintTokens(uint _amount) public{
        mint(_amount);
    }

    function mint(uint _amount) private onlyOwner {
        require(_amount >= 0,"Amount should be greater than 0");
        balance[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function burn(uint _amount) private onlyOwner{
        require(_amount >= 0,"Amount should be greater than 0");
        balance[owner] -= _amount;
        totalSupply -= _amount;
    }

    function burnToken(uint _amount) public{
        burn(_amount);
    }

    function renounceOwnership() public{
        _renounceOwnership();
    }

    function _renounceOwnership() private onlyOwner{
        uint amount = balance[owner];
        balance[address(this)] = amount;
        balance[owner] = 0;
        owner = address(0);
        owner = address(this);
    }


    



    struct buyer{
        address _buyer;
        mapping(address=>uint) timestamp;
        mapping(address=>uint ) timeToBeSend;
        uint _amount;
    }

    

    function buyToken(uint _amount) public{
        buyTokens(_amount);
    }

    function buyTokens(uint _amount) private  {
        require(!isBlackListed[msg.sender],"Your account is blacklisted");
        require(msg.sender != owner,"Not owners");
        require(balance[msg.sender] <= totalSupply,"Not good");
        require(balance[owner] >= _amount*2 ,"Not Enough Tokens");
        balance[msg.sender] += _amount;
        balance[owner] -= _amount;
        buyer storage b = buyerDetails[msg.sender];
        b._buyer = msg.sender;
        b.timestamp[msg.sender] = block.timestamp;
        buytime = block.timestamp;
        b._amount = _amount;
        b.timeToBeSend[msg.sender] = block.timestamp + 20 seconds;
        sellTime = block.timestamp + 20 seconds;
        // timeBeforeSend = block.timestamp + 100 seconds;
        totalSupply -= _amount;


    }

    
   

    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

    //0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

    //0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

    modifier hasEnoughBalance(uint _amount){
        require(balance[msg.sender] >= _amount,"Not Enough Balance");
        _;
    }

    modifier hasTimePassed(){
        require(block.timestamp > buyerDetails[msg.sender].timeToBeSend[msg.sender]  ,"Time has not reached yet");
        _;
    }

    


    function time()public view returns (uint){
        return block.timestamp;
    }

    modifier isPartialApproved(uint _amount){
        require(partialApproval[msg.sender] >= _amount || balance[msg.sender] >= _amount,"Not Enough Balance");
        _;
    }

    
    

    function transferTokens(address to, uint _amount) public{
        transferToken(to, _amount);
    }

    function transferToken(address to, uint _amount) private _isBlackListed(to) isPartialApproved(_amount)  hasTimePassed { 
        require(!hasSendOnce[msg.sender][to]);
        require(to != msg.sender,"Self transfers are not allowed");
        uint valueToSend;
        uint fees;
        if (approved[msg.sender]){
            // address _owner = approvalOwner[msg.sender];
            require(totalApprovalTime[msg.sender] > block.timestamp,"Token Approval deadline is finished");
            fees = calculateFees(_amount);
            valueToSend = _amount - fees;
            partialApproval[msg.sender] -= _amount;
            feesCollected[msg.sender] += fees;
            hasSendOnce[msg.sender][to] = true;
            buyerDetails[msg.sender].timeToBeSend[msg.sender] = block.timestamp + 20 seconds;
            hasSendOnce[msg.sender][to] = false;
            // balance[_owner] -= _amount;
            balance[to] += valueToSend;
            // partialSpending[_owner][msg.sender] -= _amount;


        }else{
            balance[msg.sender] -= _amount;
            fees = calculateFees(_amount);
            valueToSend = _amount - fees;
            balance[to] += valueToSend;
            feesCollected[msg.sender] += fees;
            hasSendOnce[msg.sender][to] = true;

        if (hasSendOnce[msg.sender][to]){
            buyerDetails[msg.sender].timeToBeSend[msg.sender] = block.timestamp + 20 seconds;
            hasSendOnce[msg.sender][to] = false;

        }
        }

        emit TransferWithFees(msg.sender, to, valueToSend, fees);
        // transferTime[msg.sender][to] = block.timestamp;
        // balance[to] += valueToSend;
        
        
    }

    
    

    function increseAllowence(address to, uint amount) public {
        require(!isBlackListed[msg.sender],"Your account is blacklisted");
        require(balance[msg.sender] >= amount  ,"Not Enough Tokens");
        require(isApproved[msg.sender][to],"You've not approved this account");
        partialApproval[to] += amount;
        balance[msg.sender] -= amount;
        approveAmount[msg.sender][to] += amount;
        partialSpending[msg.sender][to] += amount;

    }



    function decreaseAllowence(address to, uint _amount) public{
        require(!isBlackListed[msg.sender],"Your account is blacklisted");
        require(isApproved[msg.sender][to],"You've not approve this account");
        require(partialSpending[msg.sender][to] >= _amount,"You're approved token are already spended");
        balance[msg.sender] += _amount;
        partialSpending[msg.sender][to] -= _amount;
        approveAmount[msg.sender][to] -= _amount;
        
        // uint _amount = partialApproval[to];
        // require(balance[msg.sender] >= amount  ,"Not Enough Tokens");
        // require(isApproved[msg.sender][to],"You've not approved this account");
        partialApproval[to] -= _amount;

    }




    function _assignApproval(address to, uint amount) private _isBlackListed(to) hasEnoughBalance(amount) {
        require(balance[msg.sender] >= amount,"Not enough balance to approve");
        require(!isApproved[msg.sender][to],"Already approved");
        require(approveAmount[msg.sender][to] == 0,"Alreadty some token are approve to this address ");
        approvalTime[msg.sender][to] = block.timestamp + 100 seconds;
        approvalOwner[to] = msg.sender;
        isApproved[msg.sender][to] = true;
        partialApproval[to] += amount;
        approved[to] = true;
        totalApprovalTime[to] = block.timestamp + 60;
        approveAmount[msg.sender][to] = amount;
        partialSpending[msg.sender][to] = amount;
        balance[msg.sender] -= amount;
    }

    function assignApproval(address to, uint amount)public{
        _assignApproval(to, amount);
    }




    function _rejectApproval(address _of) private{
        // require(approvalTime[msg.sender][_of] >= block.timestamp,"You can't reject approval before time");
        require(isApproved[msg.sender][_of],"You've not approved this address to use your tokens");
        uint _amount = partialSpending[msg.sender][_of];
        approveAmount[msg.sender][_of] = 0;
        partialSpending[msg.sender][_of] = 0;
        partialApproval[_of] -= _amount;
        isApproved[msg.sender][_of]  = false;

    }

    function rejectApproval(address _of) public{
        _rejectApproval(_of);
    }

    
    

    function collectFees() private{
        uint amount = feesCollected[msg.sender];
        require(amount >= minFeesClaim,"Your collected fees is not satisfying our mim claim");
        balance[msg.sender] += amount;
        feesCollected[msg.sender] = 0;
    }

    

    function collectYourFees()public{
        collectFees();
    }

    function calculateFees(uint value) public view returns (uint){
        return (value * feesAmount) / 10000;
    }





    modifier _isBlackListed(address _to){
        require(!isBlackListed[_to] && !isBlackListed[msg.sender],"This Acccount is blacklisted");
        _;
    }

    function addToBlackList(address to) private {
        isBlackListed[to] = true;

    }

    function inc()external {
        count += 1;
    }

    function dec()external {
        count -= 1;
    }


}



