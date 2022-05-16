//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";


contract PetPark {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Borrower {
        uint age;
        uint gender;
        AnimalType borrowedAnimalType;
    }

    //mappings
    mapping(AnimalType => uint) public animalCounts; 
    mapping(address => Borrower) public borrowed;

    //modifiers
    modifier isAValidAnimalType(uint animalTypeParam) {
        require(animalTypeParam > 0 && animalTypeParam <= 5, "Invalid animal type");
        _;
    }
    
    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier isAgeValid(uint age) {
        require(age != 0, "Invalid Age");
        _;
    }
    

    //Declare an Event
    event Added(uint animalTypeParam, uint count);
    event Borrowed(uint animalTypeParam);
    event Returned(uint animalTypeParam);
    
    function add(uint animalTypeParam, uint count) public isOwner isAValidAnimalType(animalTypeParam) {
        AnimalType animalType = AnimalType(animalTypeParam);
        animalCounts[animalType] += count;
        emit Added(animalTypeParam, count);
    }

    /**
    borrow
    Takes Age, Gender and Animal Type.
    Can borrow only one animal at a time. Use function giveBackAnimal to borrow another animal.
    Men can borrow only Dog and Fish.
    Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat.
    Throw an error if an address has called this function before using other values for Gender and Age.
    Emit event Borrowed with parameter Animal Type.
    **/
    function borrow(uint age, uint gender, uint animalTypeParam) public isAgeValid(age) isAValidAnimalType(animalTypeParam) 
    {

        AnimalType animalType = AnimalType(animalTypeParam);
        require(animalCounts[animalType] > 0, "Selected animal not available");
        
        console.log("age", age, gender, animalTypeParam);

        //current user -> age, gender, animalType borrowed, have a mapping maybe?! 
        Borrower storage currentBorrower = borrowed[msg.sender];
        if (currentBorrower.age != 0) {
            require(currentBorrower.age == age, "Invalid Age");
            require(currentBorrower.gender == gender, "Invalid Gender");
            require(currentBorrower.borrowedAnimalType == AnimalType.None, "Already adopted a pet");
        }

       if (gender == 0) { // men
            require((animalTypeParam == 1 || animalTypeParam == 3), "Invalid animal for men"); 
        } else if (gender == 1) { //women
            if (age < 40) {
                    require((animalTypeParam != 2), "Invalid animal for women under 40");
            }
        }

        if (currentBorrower.age == 0) {
            currentBorrower.age = age;
            currentBorrower.gender = gender;
        }

        currentBorrower.borrowedAnimalType = animalType;
        animalCounts[animalType] -= 1;
        borrowed[msg.sender] = currentBorrower;

        emit Borrowed(animalTypeParam);
    }

    /**
        giveBackAnimal
        Throw an error if user hasn't borrowed before.
        Emit event Returned with parameter Animal Type.
    **/
    function giveBackAnimal() public {
        require((borrowed[msg.sender].borrowedAnimalType != AnimalType.None), "No borrowed pets");
        AnimalType animalType = AnimalType(borrowed[msg.sender].borrowedAnimalType);
        animalCounts[animalType] += 1;
    }
}
