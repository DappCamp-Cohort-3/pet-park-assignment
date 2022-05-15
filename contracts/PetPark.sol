//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    mapping(uint => uint) public animalCounts;
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
        animalCounts[animalType] += count;
        emit Added(animalType, animalCounts[animalType]);
    }

    function borrow(uint age, uint gender, uint animalType) public {
        if (age <= 0) {
            revert("Invalid Age");
        }
        if (animalType > 5 || animalType <= 0) {
            revert("Invalid animal type");
        }
        if (ages[msg.sender] > 0) {
            require(ages[msg.sender] == age, "Invalid Age");
            require(genders[msg.sender] == gender, "Invalid Gender");
        } else {
            ages[msg.sender] = age;
            genders[msg.sender] = gender;
        }
        
        
        if (borrowed_animals[msg.sender] > 0) {
            revert("Already adopted a pet");
        }
        if (animalCounts[animalType] == 0){
            revert("Selected animal not available");
        }
        if ((gender == 0)) {

            if (animalType == 1 || animalType == 3) {
                borrowed_animals[msg.sender] += 1;
                animalCounts[animalType] -= 1;
                emit Borrowed(animalType);
                
            } else {
                revert("Invalid animal for men");
            }
            
        } 
       
        if ((gender == 1)) {
            if (animalType == 2) {
                if (age > 40) {
                    borrowed_animals[msg.sender] += 1;
                    animalCounts[animalType] -= 1;
                    emit Borrowed(animalType);
                } else {
                    revert("Invalid animal for women under 40");
                }
            } else {
                borrowed_animals[msg.sender] += 1;
                animalCounts[animalType] -= 1;
                emit Borrowed(animalType);
            }
            
        } 
        
    }

    function giveBackAnimal() public {
        require(borrowed_animals[msg.sender] > 0, "No borrowed pets");
        emit Returned(borrowed_animals[msg.sender]);
        animalCounts[borrowed_animals[msg.sender]] += 1;

        borrowed_animals[msg.sender] = 0;
        borrowed_animals_count[msg.sender] = 0;


    }

}