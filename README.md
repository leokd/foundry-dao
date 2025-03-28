# **Foundry DAO**

Foundry DAO is a decentralized autonomous organization (DAO) powered by smart contracts deployed on a blockchain. This project leverages OpenZeppelin's governance modules to create a flexible and secure governance system, allowing token holders to propose and vote on changes to the DAO.

**Features**

- **Governance**: Built with OpenZeppelin's `Governor` contract, allowing decentralized governance through proposals, voting, and execution.
- **Token-based Voting**: Utilizes `GovernorVotes` and `GovernorVotesQuorumFraction` for token-based voting and quorum calculation.
- **Timelock Control**: Uses `GovernorTimelockControl` to ensure all governance actions are delayed and can be executed after a certain period.
- **Simple Proposal Workflow**: Proposals can be made, voted on, queued for execution, and executed via smart contracts.
  
**Technologies Used**

- **Solidity**: Smart contract development.
- **OpenZeppelin**: Smart contract libraries for governance and security.
- **Foundry**: A fast, modern framework for Ethereum smart contract development.
  
## Getting Started

### Prerequisites

To get started with the project, you'll need to have the following installed:

- [Foundry](https://github.com/foundry-rs/foundry) (Forge, Cast, and Anvil tools)
- [Solidity](https://soliditylang.org/) (Compiler version 0.8.22 or higher)

### Installing Dependencies

Clone the repository and install the necessary dependencies:

```bash
git clone https://github.com/leokd/foundry-dao.git
cd foundry-dao
forge install
Building the Project
Once the dependencies are installed, you can build the smart contracts using Forge:

bash
Copy
Edit
forge build
This will compile the Solidity files and generate the necessary artifacts.

Running Tests
To ensure everything is working as expected, you can run the tests:

bash
Copy
Edit
forge test
Deploying the Contracts
You can deploy the smart contracts to a local or test network. First, start a local network with Anvil:

bash
Copy
Edit
anvil
Then deploy the contracts using Forge:

bash
Copy
Edit
forge create MyGovernor --rpc-url http://localhost:8545 --private-key <YOUR_PRIVATE_KEY>
Make sure to replace <YOUR_PRIVATE_KEY> with the private key for the account that will deploy the contracts.

Contract Details
MyGovernor
MyGovernor is the main governance contract, responsible for managing proposals, voting, and execution of the DAO. The contract is built using the following OpenZeppelin extensions:

Governor: Base contract for managing governance proposals.

GovernorSettings: Configures the governance parameters such as voting delay, voting period, and proposal threshold.

GovernorCountingSimple: Simplifies the counting of votes.

GovernorVotes: Handles token-based voting and voting power.

GovernorVotesQuorumFraction: Enforces a quorum fraction for proposals to pass.

GovernorTimelockControl: Adds a timelock to all governance actions to prevent immediate execution of proposals.

**TimelockController**

The TimelockController contract is used to manage the timelock delay for governance actions. This contract ensures that proposals cannot be executed immediately after they pass, giving participants time to challenge or review them.

**License**
This project is licensed under the MIT License.

**Contributing**
If you wish to contribute to this project, feel free to fork the repository, make improvements, and submit pull requests. We welcome contributions that help enhance the functionality or improve the security of the DAO.