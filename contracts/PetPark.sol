//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;



contract PetPark {

    event Added(uint animalType, uint count);
    event Borrowed(uint animalType);
    event Returned(uint animalType);

    address public owner;
    mapping(uint => uint) shelter;
    mapping(address=>uint) borrowedAnimals;
    mapping(address=>mapping(string=>uint)) borrowers;

    // need to make sure that the borrower from the contract always send the same age and gender

    constructor() {
        owner = msg.sender;
    }

    function add(uint animalType, uint count) public {
        require(msg.sender == owner, "Not an owner");
        require(animalType>=1 && animalType <= 5,"Invalid animal");
        shelter[animalType] += count;
        emit Added(animalType, count);
    }

    function animalCounts(uint animalType) public view returns (uint){
        return shelter[animalType];
    }

    function borrow(uint age, uint gender, uint animalType) public {
        if (borrowers[msg.sender]["age"] == 0 && borrowers[msg.sender]["gender"] == 0) {
            borrowers[msg.sender]["age"] = age;
            borrowers[msg.sender]["gender"] = gender;
        } else {
            require(borrowers[msg.sender]["age"]==age, "Invalid Age");
            require(borrowers[msg.sender]["gender"]==gender, "Invalid Gender");
        }

        require(borrowedAnimals[msg.sender] == 0, "Already adopted a pet");
        require(animalType > 0 && animalType < 6, "Invalid animal type");
        require(age > 0, "Invalid Age");
        require(shelter[animalType] > 0, "Selected animal not available");
        // Check for male
        if (gender == 0) {
            if (animalType != 1 && animalType != 3) {
                revert("Invalid animal for men");
            }
        }

        // Check for female
        if (gender == 1) {
            if (age < 40 && animalType == 2) {
                revert("Invalid animal for women under 40");
            }
        }
        // need to make sure that the borrower from the contract always send the same age and gender
        shelter[animalType] -= 1;
        borrowedAnimals[msg.sender] = animalType;
        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        // Gives back the animal from the account to the shelter
        require(borrowedAnimals[msg.sender] != 0, "No borrowed pets");
        uint borrowedAnimal = borrowedAnimals[msg.sender];
        shelter[borrowedAnimal] += 1;
        borrowedAnimals[msg.sender] = 0;
    }
}