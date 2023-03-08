# NFT TCR

Decentralized projects can raise funds by selling NFTs, but fund distribution remains a manual process requiring lots of human intervention, whether it be via EOA, Multisig, or Onchain DAO governance. 

The goal of the NFT TCR is to demonstrate that projects can raise funds using NFTs, point the revenues from those sales at a Juicebox project, and then administer regular funding rounds by voting using an onchain token curated registry (TCR). 

Advantages: 
- Fully autonomous: Set it and forget it, and the project continues to distribute funds at a regular interval
- Donor empowerment: NFT collectors are able to express their preference for which project receives funding, without having to vote in many independent timed proposal rounds
- Minimal design: Purpose built for configuring a Juicebox treasury, this minimal NFT TCR is comprehensible and an achievable short-term experiment towards NFT TCR PMF


Architecture:
- Each NFT constitutes a vote
- Collectors can vote for any Juicebox Project ID
- The Project with the most votes is elected the People's Choice
- Funding cycles are of a fixed duration and distribution limit (e.g., 1 weekly $1000 grant)
- An external function allows anyone to update the treasury's funding cycle configuration to point the next payout to the current People's Choice
- Vote tracking is kept lightweight; every time a collector sends or receives an NFT, thier prior votes are reset.





Tempalte info

# juice-contract-template
Template used to code juicy solidity stuff - includes forge, libs, etc. 

This template is a good starting point for building solidity extensions to the Juicebox Protocol. Forking this template may help you to avoid submodule related dependency issues down the road.

# Getting started
## Prerequisites
### Install & Update Foundry
Install Forge with `curl -L https://foundry.paradigm.xyz | bash`. If you already have Foundry installed, run `foundryup` to update to the latest version. More detailed instructions can be found in the [Foundry Book](https://book.getfoundry.sh/getting-started/installation).

### Install & Update Yarn
Follow the instructions in the [Yarn Docs](https://classic.yarnpkg.com/en/docs/install). People tend to use the latest version of Yarn 1 (not Yarn 2+).

## Install Included Dependencies
Install the included dependencies (forge tests, Juice-contracts-V3, OZ) with `forge install && yarn install`.

# Adding dependencies
## With Yarn
If the dependency you would like to install has an NPM package, use `yarn add [package]` where [package] is the package name. This will install the dependency to `node_modules`.

Tell forge to look for node libraries by adding `node_modules` to the `foundry.toml` by updating `libs` like so: `libs = ['lib', 'node_modules']`.

Add dependencies to `remappings.txt` by running `forge remappings >> remappings.txt`. For example, the NPM package `jbx-protocol` is remapped as `@jbx-protocol/=node_modules/@jbx-protocol/`.

## With Forge
If the dependency you would like to install does not have an up-to-date NPM package, use `forge install [dependency]` where [dependency] is the path to the dependency repo. This will install the dependency to `/lib`. Forge manages dependencies using git submodules.

Run `forge remappings > remappings.txt` to write the dependencies to `remappings.txt`. Note that this will overwrite that file. 

If nested dependencies are not installing, try this workaround `git submodule update --init --recursive --force`. Nested dependencies are dependencies of the dependencies you have installed. 

More information on remappings is available in the Forge Book.

# Updating dependencies
## With Yarn
Run `yarn upgrade [package]`.

## With Forge
Run `foundryup` to update forge. 

Run `forge update` to update all dependencies, or run `forge update [dependency]` to 