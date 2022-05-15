//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    mapping(uint => uint) public park;
    mapping(address => uint) public ages;
    mapping(address => uint) public genders;
    mapping(address => uint) public borrowed_animals;
    mapping(address => uint) public borrowed_animals_count;

    event Added(uint animalType, uint animalCount);
    event Borrowed(uint animalType);
    event Returned(uint animalType);

    function add(uint animalType, uint count) public {
        // require(msg.sender);
        if (animalType > 5 || animalType <= 0) {
            revert("Invalid animal type");
        }
        park[animalType] += count;
        emit Added(animalType, park[animalType]);
    }

    function borrow(uint age, uint gender, uint animalType) public {
        if (age <= 0) {
            revert("Invalid Age");
        }
        if (animalType > 5 || animalType <= 0) {
            revert("Invalid animal type");
        }
        if (ages[msg.sender] > 0) {
            require(ages[msg.sender] == age, "Error: age does not match previously sent age for this address");
            require(genders[msg.sender] == gender, "Error: gender does not match previously sent gender for this address");
        } else {
            ages[msg.sender] = age;
            genders[msg.sender] = gender;
        }
        
        
        if (borrowed_animals[msg.sender] > 0) {
            revert("Already adopted a pet");
        }
        if ((gender == 0) && (animalType == 1 || animalType == 3)) {
            emit Borrowed(animalType);
        } 
        if (gender == 0) {
            revert("Invalid animal for men");
        }
        if ((gender == 1) && (animalType == 2)) {
            if (age > 40) {
                emit Borrowed(animalType);
            } else {
                revert("Invalid animal for women under 40");
            }
        } 
        if (gender == 1) {
            emit Borrowed(animalType);
        }
        
    }

    function giveBackAnimal(address user) public {
        require(borrowed_animals[user] > 0, "No borrowed pets");
        emit Returned(borrowed_animals[user]);
        park[borrowed_animals[user]] += 1;

        borrowed_animals[user] = 0;
        borrowed_animals_count[user] = 0;


    }

}