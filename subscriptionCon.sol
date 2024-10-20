// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract SubscriptionService {
    address public contractOwner;

    struct Plan {
        uint256 fee; // Subscription fee
        uint256 duration; // Payment duration (in seconds)
        uint256 nextDue; // Timestamp for the next payment
        bool isActive; // Status of the subscription
    }

    // Mapping to store each user's subscription plans
    mapping(address => Plan) public userPlans;

    // Events for logging subscriptions
    event Subscribed(address indexed user, uint256 fee, uint256 duration);
    event SubscriptionCanceled(address indexed user);

    constructor() {
        contractOwner = msg.sender; // Set the deployer as the contract owner
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Caller is not the contract owner");
        _;
    }

    // Function for users to subscribe
    function subscribe(uint256 fee, uint256 duration) external payable {
        require(msg.value == fee, "Incorrect fee amount");
        require(duration > 0, "Dauration must be greater than 0");
        require(!userPlans[msg.sender].isActive, "Already subscribed to a plan");

        // Save the subscription details
        userPlans[msg.sender] = Plan({
            fee: fee,
            duration: duration,
            nextDue: block.timestamp + duration,
            isActive: true
        });

        emit Subscribed(msg.sender, fee, duration);
    }

    // Function to cancel the subscription
    function cancelSubscription() external {
        Plan storage userPlan = userPlans[msg.sender];
        require(userPlan.isActive, "No active subscription found");

        // Mark the subscription as inactive
        userPlan.isActive = false;
        emit SubscriptionCanceled(msg.sender);
    }

    // Owner can withdraw funds from the contract
    function withdrawFunds() external onlyOwner {
        payable(contractOwner).transfer(address(this).balance);
    }

    // Function to process a user's payment if the due time has arrived
    function processUserPayment() external {
        Plan storage userPlan = userPlans[msg.sender];
        require(userPlan.isActive, "No active subscription");
        require(block.timestamp >= userPlan.nextDue, "Payment not due yet");

        // Transfer the payment to the owner
        payable(contractOwner).transfer(userPlan.fee);

        // Update the next payment time
        userPlan.nextDue = block.timestamp + userPlan.duration;
    }

    // Function to receive payments directly
    receive() external payable {}
}
