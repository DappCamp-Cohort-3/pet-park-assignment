//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {

    address public owner;
    struct Adopter {
        uint Age;
        uint Gender;
    }
    mapping(uint => uint) public animalCounts;
    mapping(address => Adopter) addressAdopters;
    mapping(address => uint) addressAnimalTypes;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimal(uint AnimalType) {
        require(AnimalType >= 1 && AnimalType <= 5, "Invalid animal");
        _;
    }

    event Added(uint AnimalType, uint Count);

    function add(uint AnimalType, uint Count) public onlyOwner validAnimal(AnimalType) {
        animalCounts[AnimalType] += Count;
        emit Added(AnimalType, Count);
    }

    event Borrowed(uint AnimalType);

    function borrow(uint Age, uint Gender, uint AnimalType) public {
        require(Age > 0, "Invalid Age");

        require(AnimalType >= 1 && AnimalType <= 5, "Invalid animal type");

        Adopter storage existingAdopter = addressAdopters[msg.sender];
        if (existingAdopter.Age != 0) {
            require (existingAdopter.Age == Age, "Invalid Age");
            require (existingAdopter.Gender == Gender, "Invalid Gender");
        } else {
            addressAdopters[msg.sender] = Adopter(Age, Gender);
        }

        require(animalCounts[AnimalType] > 0, "Selected animal not available");

        require(addressAnimalTypes[msg.sender] == 0, "Already adopted a pet");

        if (Gender == 0) {
            require((AnimalType == 1 || AnimalType == 3), "Invalid animal for men");
        }

        if (Gender == 1 && Age < 40) {
            require(AnimalType != 2, "Invalid animal for women under 40");
        }

        addressAnimalTypes[msg.sender] = AnimalType;
        animalCounts[AnimalType] -= 1;

        emit Borrowed(AnimalType);
    }

    function giveBackAnimal() public {
        require(addressAnimalTypes[msg.sender] != 0, "No borrowed pets");
        uint animalType = addressAnimalTypes[msg.sender];
        animalCounts[animalType] += 1;
        addressAnimalTypes[msg.sender] = 0;
    }
}