//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

    // define struct of animal type, age, and gender
    struct animalAndDemo {
        uint animalType;
        uint age;
        uint gender;
    }

    // animals in zoo: animalType and count of that animal in the zoo
    mapping (uint => uint) public animalsInZoo;
    // borrwed animals: address -> animal type and demo of owner
    mapping (address => animalAndDemo) public borrowedAnimal;

    constructor() {
        owner = msg.sender;
    }

    modifier animalRange(uint animalType) {
        // revert when animal type is invalid
        require(animalType > 0 && animalType < 6, "Invalid animal type");
        _;
    }

    // define events
    event Added(uint animalType, uint animalCount);
    event Borrowed(uint animalType);
    event Returned(uint animalType);
    
    function add(uint animalType, uint count) public animalRange(animalType) {
        // check that only owner has access
        require(owner == msg.sender, "Not an owner");
        
        // increase the animals in the zoo of that type by the count
        animalsInZoo[animalType] += count;

        // emit added event
        emit Added(animalType, count);
    }

    function borrow(uint age, uint gender, uint animalType) public animalRange(animalType) {
        
        animalAndDemo memory currentBorrow = borrowedAnimal[msg.sender];

        // revert when age is zero
        require(age > 0, "Invalid Age");
        
        // revert when animal not available in park
        require(animalsInZoo[animalType] > 0, "Selected animal not available");

        // revert when address details do not match from previous calls
        if (currentBorrow.age > 0) {
            // check age
            require(currentBorrow.age == age, "Invalid Age");
            // check gender
            require(currentBorrow.gender == gender, "Invalid Gender");
        }

        // revert when pet is already borrowed
        require(currentBorrow.animalType == 0, "Already adopted a pet");
        
        // revert when men attempt to borrow animals other than fish and dog
        if (gender == 0) {
            require(animalType == 1 || animalType == 3, "Invalid animal for men");
        }

        // revert when women under 40 attempt to borrow cat
        if (gender == 1) {
            if (age < 40) {
                require(animalType != 2, "Invalid animal for women under 40");
            }
        }

        // set up the animal and demo of the item to be added
        animalAndDemo memory animalAndDemoToAdd = animalAndDemo(animalType, age, gender);

        // store info into borrowedAnimal mapping
        borrowedAnimal[msg.sender] = animalAndDemoToAdd;

        // remove from zoo
        animalsInZoo[animalType]--;

        // emit borrowed event
        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        // set current amimal variable
        uint currentAnimal = borrowedAnimal[msg.sender].animalType;

        // ensure that there are no borrowed pets
        require(currentAnimal > 0, "No borrowed pets");

        // set animal type back to zero in borrow mapping
        uint currentAge = borrowedAnimal[msg.sender].age;
        uint currentGender = borrowedAnimal[msg.sender].gender;
        animalAndDemo memory inputAnimalAndDemo = animalAndDemo(0, currentAge, currentGender);
        borrowedAnimal[msg.sender] = inputAnimalAndDemo;

        // increment animal count in zoo
        animalsInZoo[currentAnimal]++;

        // emit returned event
        emit Returned(currentAnimal);
    }

    function animalCounts(uint animalType) public view returns(uint) {
        return animalsInZoo[animalType];
    }
}