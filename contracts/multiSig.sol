
//pragma solidity 0.8.17;

/** 
contract MultiSig {
    
    
        a contract that receives and sends ether
        allows at least 70% approval of admins before withdrawal 
        requires 70% of signature admins before addition of admin
        requires 70% sign from admins before removal of admin
        minimum of 3 admins must be attached to the contract at every point ***
     


uint256 private AdminsTotal;
uint256 private TreasuryBalance;
uint256 private TotalVotes;

constructor(address[] memory _admins) {
    require(_admins.length >= 3);
    admins = _admins;
    AdminsTotal = admins.length;
    for(uint i = 0; i < AdminsTotal; i++){
        IsAdmin[_admins[i]] == true;
    }
}

mapping (address => mapping (address => bool)) private VoteTracker;
mapping (address => bool) IsAdmin;
address[] public admins;

event adminAdded(address newAdmin, string);
event adminRemoved(address _adminPop, string);
event withdraw_(address _admin, address _to, uint256 _amount, string);
event voted_(address voter);


modifier AdminThreshold(){
    require(TotalVotes >= (AdminsTotal * 70 / 100));
    _;
}

function addAdmin(address _newAdmin, address _admin) public AdminThreshold(){
    //require(IsAdmin[_admin] == true, "Not Authorized");
    require(IsAdmin[_newAdmin] == false, "Account already an admin");
    require(_newAdmin != address(0), "Cannot add zero address");
    IsAdmin[_newAdmin] = true;
    AdminsTotal = AdminsTotal + 1;
    admins.push(_newAdmin);
    emit adminAdded(_newAdmin, "Admin added successfully");
}


function vote(address _voter, address _newAdmin) public returns(bool voted) {
    //require(IsAdmin[_voter] == true);
    require(_newAdmin != address(0));
    VoteTracker[_voter][_newAdmin] == true;
    TotalVotes = TotalVotes + 1;
    voted = true;
    emit voted_(_voter);
}

function removeAdmin(address _admin, address _adminPop) public {
    require(IsAdmin[_admin]);
    IsAdmin[_adminPop] = false;
    AdminsTotal = AdminsTotal - 1;
    popAdmin(_adminPop);
    emit adminRemoved(_adminPop, "Admin removed successfully");
}

function popAdmin(address _adminPop) private {
    for (uint i = 0; i < AdminsTotal; i++){
        if(_adminPop == admins[i]){
            admins[i] = admins[AdminsTotal - 1];
            admins.pop();
            break;
        }
    }
}

function withdraw(address _admin , address payable _to, uint256 _amount) public payable AdminThreshold returns(bool status) {
    require(_to != address(0));
    require(IsAdmin[_admin]);
    (bool success, ) = _to.call{value: _amount}("");
    require(success, "Withdrawal FAIL!!!");
    status = true;
    emit withdraw_(_admin, _to, _amount, "Withdrawal successful");
}

receive() external payable{}

}   
//["0x617F2E2fD72FD9D5503197092aC168c91465E7f2", "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"]
 */


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MultiSig {
    // a contract that receives and send ethers
    //allows atleast 70% approval of admins before withdrawal is made.
    //allows atleast 70% approval of admins before removal of admin;
    //allows atleast 70% approval of admins before addition of admin;
    //minimum of 3 admins at every point in time
    address[] Admins;

    address MasterOwner;

    //    // admin ==> newAdmin ==> bool
    mapping(address => mapping(address => bool)) votesStatus;
    // newAmin ==> no of vote
    mapping(address => uint256) voteCount;
    mapping(address => bool) isAdmin;

    constructor(address[] memory _admins, address _owner) {
        require(_admins.length >= 3, "minimum Admins not met");
        Admins = _admins;
        for (uint256 i = 0; i < _admins.length; i++) {
            isAdmin[_admins[i]] = true;
        }
        MasterOwner = _owner;
    }

    modifier onlyAdmin(address _admin) {
        bool valid;
        for (uint256 i = 0; i < Admins.length; i++) {
            if (_admin == Admins[i]) {
                valid = true;
                break;
            }
        }
        require(valid, "not admin");
        _;
    }

    receive() external payable {}

    function addAdmin(address _newAdmin) external onlyAdmin(msg.sender) {
        require(
            isAdmin[_newAdmin] == false && _newAdmin != address(0),
            "cannot address(0) as admin"
        );
        bool status = votesStatus[msg.sender][_newAdmin];
        require(status == false, "previously voted");
        voteCount[_newAdmin]++;
        votesStatus[msg.sender][_newAdmin] = true;
        uint256 _perc = calcPercentage();
        if (voteCount[_newAdmin] >= _perc) {
            Admins.push(_newAdmin);
            isAdmin[_newAdmin] = true;
            voteCount[_newAdmin] = 0;
        }
    }

    function calcPercentage() public view returns (uint256 _perc) {
        uint256 size = Admins.length;
        _perc = (size * 70) / 100;
    }

    function returnAdmins() public view returns (address[] memory _admins) {
        uint256 size = Admins.length;
        _admins = new address[](size);
        _admins = Admins;
    }
}