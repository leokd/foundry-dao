// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "src/MyGovernor.sol";
import {GovToken} from "src/GovToken.sol";
import {TimeLock} from "src/TimeLock.sol";
import {Box} from "src/Box.sol";

contract MyGovernorTest is Test {
    GovToken govToken;
    TimeLock timelock;
    MyGovernor governor;
    Box box;

    address public USER = makeAddr("user");
    uint256 INITIAL_SUPPLY = 100 ether;

    uint256 public constant MIN_DELAY = 3600; // 1 hour - after a vote passes, you have 1 hour before you can enact
    uint256 public constant QUORUM_PERCENTAGE = 4; // Need 4% of voters to pass
    uint256 public constant VOTING_PERIOD = 50400; // This is how long voting lasts
    uint256 public constant VOTING_DELAY = 1; // How many blocks till a proposal vote becomes active

    address[] proposers;
    address[] executors;

    bytes[] calldatas;
    address[] targets;
    uint256[] values;

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.prank(USER);
        govToken.delegate(USER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, USER);
        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 555;
        string memory description = "Store 1 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));

        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // View the state before the vote
        uint256 proposalStateBeforeVote = uint256(governor.state(proposalId));
        console.log("Proposal State (before vote):", proposalStateBeforeVote);
        require(proposalStateBeforeVote == 0, "Proposal is not in pending state before voting");

        // Simulate passing the voting delay
        vm.warp(block.timestamp + VOTING_DELAY + 7200 + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        uint256 proposalStateAfterDelay = uint256(governor.state(proposalId));
        console.log("Proposal State (after voting delay):", proposalStateAfterDelay);
        require(proposalStateAfterDelay == 1, "Proposal did not transition to voting state");

        // 2. Vote
        string memory reason = "I like a do da cha cha";
        uint8 voteWay = 1; // 1 = For
        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        // Warp to end of voting period
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        uint256 proposalStateAfterVoting = uint256(governor.state(proposalId));
        console.log("Proposal State (after voting):", proposalStateAfterVoting);
        require(proposalStateAfterVoting == 4, "Proposal did not transition to succeeded state");

        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        // 4. Execute
        uint256 proposalStateAfterExecution = uint256(governor.state(proposalId));
        console.log("Proposal State (after execution):", proposalStateAfterExecution);
        require(proposalStateAfterExecution == 5, "Proposal did not transition to executed state");

        governor.execute(targets, values, calldatas, descriptionHash);

        console.log("Box value: ", box.getNumber());
        assert(box.getNumber() == valueToStore);
    }
}
