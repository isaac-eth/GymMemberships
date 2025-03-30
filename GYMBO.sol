// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./GYM.sol";

contract GymMembership is ERC721, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;
    using Strings for uint256; 

    string public baseURI = "https://isaac-eth.github.io/GymMemberships/";

    GymToken public gym;

    struct memType {
        string memTypeName;
        uint256 memVigency;
        uint256 memCost;
        uint256 memBonus;
    }

    memType[] allMemberships;
    
    enum ExtraClasses {cross, cardio, gap, yoga}

    uint256 minVisitTime = 36000;
    uint256 weekTime = 604800;
    uint256 dayTime = 86400;

    struct visits {
        bool status;
        uint256 enterTime;
        uint256 exitTime;
        uint256 vigency;
        uint256 visitDuration;
        uint256 completedVisits;
        uint256 endOfWeek;
    }

    mapping (address => visits) VisitsInfo;

    constructor(address _gymAddress) ERC721("Gymbo Membership", "GBMS") Ownable(msg.sender) {
        gym = GymToken(_gymAddress);
        memType memory MonthMembership = memType ({
            memTypeName: "One Month",
            memVigency: 2592000,
            memCost: 100,
            memBonus: 5
        });
        allMemberships.push(MonthMembership);

        memType memory triMonthMembership = memType ({
            memTypeName: "Three Months",
            memVigency: 7776000,
            memCost: 250,
            memBonus: 20
        });
        allMemberships.push(triMonthMembership);

        memType memory sixMonthMembership = memType ({
            memTypeName: "Six Months",
            memVigency: 15552000,
            memCost: 450,
            memBonus: 30
        });
        allMemberships.push(sixMonthMembership);

        memType memory anualMembership = memType ({
            memTypeName: "Anual",
            memVigency: 31104000,
            memCost: 850,
            memBonus: 60
        });
        allMemberships.push(anualMembership);
    }

    function seeAllMemberships() public view returns (memType[] memory) {
        return allMemberships;
    }
    
    function buyMembership(address to, uint256 _memType) public payable {
        require (VisitsInfo[msg.sender].vigency == 0, "You already have a Membership");
        require (_memType < allMemberships.length, "Select only available Membership");
        memType memory SelectedMembership = allMemberships[_memType];

        require (msg.value == SelectedMembership.memCost, "Payment not valid");

        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);

        VisitsInfo[msg.sender].vigency = block.timestamp + SelectedMembership.memVigency;
        VisitsInfo[msg.sender].completedVisits = 0;

        gym.transfer(msg.sender, SelectedMembership.memBonus);
    }

    function tokenURI (uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "NFT does not exist");
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function enterGym () public {
       require (!VisitsInfo[msg.sender].status, "Member already entered gym");
       require (block.timestamp <= VisitsInfo[msg.sender].vigency, "Membership has expired");
       VisitsInfo[msg.sender].status = !VisitsInfo[msg.sender].status;
       VisitsInfo[msg.sender].enterTime = block.timestamp;

        if(block.timestamp > VisitsInfo[msg.sender].endOfWeek) {
            VisitsInfo[msg.sender].completedVisits = 0;
        }
    }

    function exitGym () public {
        require (VisitsInfo[msg.sender].status, "Member already exited gym");
        VisitsInfo[msg.sender].status = !VisitsInfo[msg.sender].status;
        VisitsInfo[msg.sender].exitTime = block.timestamp;      
        VisitsInfo[msg.sender].visitDuration = block.timestamp - VisitsInfo[msg.sender].enterTime;

        if(VisitsInfo[msg.sender].completedVisits == 0) {
            VisitsInfo[msg.sender].endOfWeek = block.timestamp + weekTime;  
            if(VisitsInfo[msg.sender].visitDuration == minVisitTime) {
                VisitsInfo[msg.sender].completedVisits++;
            }
        } else if(VisitsInfo[msg.sender].visitDuration >= minVisitTime) {
                require(block.timestamp > VisitsInfo[msg.sender].exitTime + dayTime);
                VisitsInfo[msg.sender].completedVisits++;
            }

        if (VisitsInfo[msg.sender].completedVisits == 4) {
            gym.transferFrom (address(this), msg.sender, 5);
        } else if (VisitsInfo[msg.sender].completedVisits > 4) {
            gym.transferFrom (address(this), msg.sender, 15);
        }
    }

    function signInExtraClass (uint256 _extraClass) public {
        require(gym.balanceOf(msg.sender) >= (5),"Not enough GYM balance");
        require (_extraClass <= uint256(ExtraClasses.yoga), "Extra class not valid");
        gym.transferFrom(msg.sender, address(this), 5);
    }

}
    
