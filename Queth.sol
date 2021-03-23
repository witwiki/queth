pragma solidity >=0.4.21 <0.8.1;

contract Queth {
    // To optimise for Gas we create a data structure
    struct LilMinion {
        uint qAmount;
        uint qMaturity;      // maturity date
        bool isPaid;        //To prevent kids stealing from each other by calling the withdraw() multiple timestamp, we introduce a boolean mapping 
    }
    mapping(address => LilMinion) public minions;
    address public admin;  // To prevent anyone from adding a kid but only the parents
    
    constructor() {
        admin = msg.sender;
    }

    function addMinion(address kid, uint timeToMaturity) external payable {
        require(msg.sender == admin, 'only admin/parents');       //   make sure the sender is the admin/parents
        require(minions[msg.sender].qAmount == 0, 'Kid already exists');    // make sure we haven't already added the kid
        minions[kid] = LilMinion(msg.value, block.timestamp + timeToMaturity, false);
    }
    
    // function withdraw(address kid) external {
    //     require(maturities[kid] <= block.timestamp, 'too early');   //the maturity date needs to be greater than the current blocktime
    //     /*
    //         In solidity, one can still access an entry in the address mapping even if it doesn't exist. 
    //         When someone's address is not mapped into a variable (in this case 'amounts'), then the 
    //         address maps to the default value of uint that is 0. So, if we find a 0 associated with an 
    //         address mapped to a variable then we know this address does not belong and is not the 
    //         person required to withdraw the funds.
    //     */
    //     require(amounts[kid] > 0, 'only the kid can withdraw');
    //     payable(kid).transfer(amounts[kid]);
    // }

    // To create a more secure version of the above function so less chances of hacking we remove the argument    
    function withdraw() external {
        LilMinion storage kid = minions[msg.sender];
        require(kid.qMaturity <= block.timestamp, 'too early');   //the maturity date needs to be greater than the current blocktime
        /* 'msg.sender' is guaranteed by the Ethereum protocol layer as its in built    */
        require(kid.qAmount > 0, 'only the kid can withdraw');
        require(kid.isPaid == false, 'paid already');
        kid.isPaid = true;          //  set to true once paid
        payable(msg.sender).transfer(kid.qAmount);
    }
    
}