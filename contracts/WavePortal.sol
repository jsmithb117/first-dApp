// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
  uint256 totalWaves;
  uint256 private seed;
  event NewWave(address indexed from, uint256 timestamp, string message);


  // creates Wave struct to store data
  struct Wave {
      address waver; // The address of the user who waved.
      string message; // The message the user sent.
      uint256 timestamp; // The timestamp when the user waved.
  }

  // An array of Waves
  Wave[] waves;

  // maps the time the user last waved, used for rate limiting
  mapping(address => uint256) public lastWavedAt;

  // constructor which creates a pseudorandom seed
  constructor() payable {
      console.log("Let's do some smart contract things.");
      // 0 <= seed < 100
      seed = (block.timestamp + block.difficulty) % 100;
  }

  // creates new waves and determines if user will 'win' .001 eth
  function wave(string memory _message) public {

    // solidity require statements are similar to javascript if statements.  Javascript equivalent(ish):
    // if (lastWavedAt[msg.sender] + 30 seconds < block.timestamp) {
    //   console.log("NOSPAM!\nYou can only wave once every 30 seconds.");
    //   return; // stops further progress in the function
    //   }
    require(
        lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
        "NOSPAM!\nYou can only wave once every 30 seconds."
    );

    // updates lastWavedAt map
    lastWavedAt[msg.sender] = block.timestamp;

    totalWaves += 1;
    console.log("%s has waved with the message %s", msg.sender, _message);
    waves.push(Wave(msg.sender, _message, block.timestamp));

    // generates a new seed for the next wave
    seed = (block.difficulty + block.timestamp + seed) % 100;

    // sends prizeAmount ether to user if seed meets condition
    if (seed <= 50) {
      console.log("%s won!", msg.sender);

      uint256 prizeAmount = 0.0001 ether;
      require(
          prizeAmount <= address(this).balance,
          "Oops, all the eth has been given away."
      );
      (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        require(success, "Failed to withdraw money from contract.");
    }

    emit NewWave(msg.sender, block.timestamp, _message);
  }

  function getAllWaves() public view returns (Wave[] memory) {
      return waves;
  }

  function getTotalWaves() public view returns (uint256) {
      console.log("We have %d total waves!", totalWaves);
      return totalWaves;
  }
}
