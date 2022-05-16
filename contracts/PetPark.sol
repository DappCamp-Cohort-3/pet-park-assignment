//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title Assignment-1 Smart Contract for Pet Park
/// @author Srigowri M V
/// @dev The functions implemented pass the tests provided in /test/PetPark.spec.js
contract PetPark {
    //Constants
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }
    enum GenderType {
        Male,
        Female
    }

    struct Borrower {
        uint age;
        GenderType genderType;
        AnimalType animalType;
    }
    //State Variable Declaration        
    address public owner;
    mapping(AnimalType => uint) public animalCounts; // Mapping for Animal Type: Count
    mapping(address => Borrower) public borrower;    

    //Events
    event Added(AnimalType _animalType, uint count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);


    //Constructor
    constructor() {
        owner = msg.sender;
    }

    //Modifiers
    modifier ownerOnly() {
        //Used while adding new pets to the park
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validPet(AnimalType _animalType) {
        //Used to ensure only valid animal types are being added or borrowed
        bool valid = (_animalType == AnimalType.Fish ||
            _animalType == AnimalType.Cat ||
            _animalType == AnimalType.Dog ||
            _animalType == AnimalType.Rabbit ||
            _animalType == AnimalType.Parrot);

        require(valid, "Invalid animal type");
        _;
    }

    //Functions
    function add(AnimalType _animalType, uint count)
        external
        ownerOnly
        validPet(_animalType)
    {
        //Increment count of the corresponding pet in the park
        animalCounts[_animalType] += count;
        emit Added(_animalType, count);
    }

    function giveBackAnimal() external {
        //Can give back pets only if borrowed
        Borrower storage person = borrower[msg.sender]; 
        require(person.animalType != AnimalType.None, "No borrowed pets");

        animalCounts[person.animalType] += 1; //Increment count of the corresponding pet in the park
        person.animalType = AnimalType.None; //reset the borrowerAnimal
    }

    function borrow(
        uint age,
        GenderType _genderType,
        AnimalType _animalType
    ) external validPet(_animalType) {
        require(age > 0, "Invalid Age"); //Age can not be below 1
        require(animalCounts[_animalType] > 0, "Selected animal not available"); // The selected animal must have count > 0

        Borrower storage person = borrower[msg.sender];
        bool borrowed = (person.animalType != AnimalType.None); //has the borrower (msg.sender) adopted a pet already
        if (borrowed) {
            require(person.age == age, "Invalid Age"); // Existing borrower with incorrect age
            require(person.genderType == _genderType, "Invalid Gender"); //Existing borrower with incorrect gender
            require(false, "Already adopted a pet"); //If the borrower has a pet already
        }

        if (_genderType == GenderType.Male) {
            //Male - valid pets are either dog or fish
            require(
                (_animalType == AnimalType.Dog ||
                    _animalType == AnimalType.Fish),
                "Invalid animal for men"
            );
        } else {
            if (age < 40) {
                //women under 40 can not have cats as pets
                require(
                    _animalType != AnimalType.Cat,
                    "Invalid animal for women under 40"
                );
            }
        }

        //enter valid details for the borrower
        person.age = age;
        person.animalType = _animalType;
        person.genderType = _genderType;
        animalCounts[_animalType] -= 1;
        emit Borrowed(_animalType);
    }
}
