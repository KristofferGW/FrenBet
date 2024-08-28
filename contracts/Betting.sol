// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// ERC-20 Interface to interact with USDC
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256); 
}

contract Betting {
    struct Bet {
        uint256 matchId;
        string predictedOutcome;
    }

    struct BetSlip {
        address better;
        uint256 betSlipId;
        uint256 groupId;
        Bet[] bets;
    }

    struct Group {
        uint256 groupId;
        uint256 totalBetAmount; // Total USDC amount associated with this group
        uint256[] betSlips; // List of bet slip IDs in this group
    }

    uint256 public betSlipCounter;
    uint256 public groupCounter;
    mapping(uint256 => BetSlip) public betSlips;
    mapping(address => uint256[]) public userBetSlips; // Mapping to store bet slip IDs by user address
    mapping(uint256 => Group) public groups; // Mapping to store groups by group ID

    IERC20 public usdcToken; // USDC token contract
    uint256 public constant BET_COST = 10 * 10 ** 6; // 10 USDC with 6 decimal places (assuming USDC has 6 decimals)

    event BetSlipCreated(address indexed better, uint256 indexed betSlipId, uint256 indexed groupId);
    event GroupCreated(uint256 indexed groupId);

    // Constructor to set the USDC token contract address
    constructor(address _usdcTokenAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
    }

    function createGroup() public returns (uint256) {
        Group storage newGroup = groups[groupCounter];
        newGroup.groupId = groupCounter;
        emit GroupCreated(groupCounter);
        return groupCounter++;
    }

    // Function to create a new bet slip and associate it with a group
    function createBetSlip(uint256 groupId, uint256[] memory matchIds, string[] memory predictedOutcomes) public {
        require(matchIds.length == predictedOutcomes.length, "Mismatched inputs");
        require(groups[groupId].groupId == groupId, "Invalid group ID");
        require(usdcToken.balanceOf(msg.sender) >= BET_COST, "Insufficient USDC balance");

        bool success = usdcToken.transferFrom(msg.sender, address(this), BET_COST);
        require(success, "USDC transfer failed");

        // Create a new BetSlip
        BetSlip storage newBetSlip = betSlips[betSlipCounter]; // what's happening here?
        newBetSlip.better = msg.sender;
        newBetSlip.betSlipId = betSlipCounter;
        newBetSlip.groupId = groupId;

        // Populate the bets array in the BetSlip struct
        for (uint256 i; i < matchIds.length; i++) { // is it cheaper not look up the length every time even though it's from memory?
            newBetSlip.bets.push(Bet({
                matchId: matchIds[i],
                predictedOutcome: predictedOutcomes[i]
            }));
        }

        // Store the bet slip ID in the user's record and the group
        userBetSlips[msg.sender].push(betSlipCounter);
        groups[groupId].betSlips.push(betSlipCounter);

        // Update the group's total bet amount
        groups[groupId].totalBetAmount += BET_COST;

        emit BetSlipCreated(msg.sender, betSlipCounter, groupId);

        betSlipCounter++;
    }

    // Function to get bet slips of a user
    function getBetSlipsByUser(address user) public view returns (uint256[] memory) {
        return userBetSlips[user];
    }

    // Function to get details of a specific bet slip
    function getBetSlipDetails(uint256 slipId) public view returns (BetSlip memory) {
        return betSlips[slipId];
    }

    // Function to get details of a specific group
    function getGroupDetails(uint256 groupId) public view returns (Group memory) {
        return groups[groupId];
    }
}