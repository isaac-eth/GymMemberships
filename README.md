# Gym Membership Management System on Blockchain
This repository contains all the code and files necessary to implement a gym membership management system using blockchain technology. The project includes:

Main Membership Contract (GymMembership):
Manages membership purchases, minting unique NFTs, visit control, and gym access.

GYM Token Contract:
An ERC20 token used as an incentive and for paying additional classes.

NFT Metadata:
JSON files that contain the information (name, description, image, attributes) for each type of membership. These files are hosted on GitHub Pages (or another public hosting service) so they can be publicly accessed.

# Features
Membership Types:
Four types are defined: Monthly, Quarterly, Semiannual, and Annual, each with its own cost, validity period, and token bonus.

NFT Minting:
Every time a membership is purchased, an NFT is minted that certifies the authenticity and traceability of the membership.

Visit and Access Control:
The contract records gym entry and exit, the duration of each visit, and the accumulation of complete visits to reward the user with tokens.

Additional Classes:
Users can register for extra classes (Cross, Cardio, GAP, Yoga) using tokens.

# Repository Structure
/contracts:
Contains the Solidity smart contracts.

GymMembership.sol – Main membership management contract.

GymToken.sol – GYM token contract (ERC20).

/metadata:
JSON files that describe the NFT metadata (e.g., 0.json, 1.json, etc.).
These files are hosted on GitHub Pages so they can be referenced in the contract.

/scripts:
Scripts for deploying and testing the contracts (optional).

README.md:
This file.



