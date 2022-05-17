//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {
    address public owner;

    mapping(string => uint) public AnimalType;

    mapping(uint => uint) public animalCounts;

    mapping(address => User) public Users;

	mapping(string => uint8) public Gender;

    struct User {
        bool hasEverBorrowed;
        bool hasAnimal;
        uint borrowedAnimalType;
        uint gender;
        uint age;
    }

    constructor() {
        owner = msg.sender;

        // AnimalType
        AnimalType["Fish"] = 1;
        AnimalType["Cat"] = 2;
        AnimalType["Dog"] = 3;
        AnimalType["Rabbit"] = 4;
        AnimalType["Parrot"] = 5;

        // Gender
        Gender["Male"] = 0;
        Gender["Female"] = 1;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not an owner");
        _;
   }

    event Added(uint indexed animalType, uint indexed animalCount);

    function add(uint _animalType, uint _count) public onlyOwner {
        require(_animalType != 0, "Invalid animal");
        animalCounts[_animalType] += _count;
        emit Added(_animalType, animalCounts[_animalType]);
    }

    event Borrowed(uint indexed _animalType);

    function borrow(uint _age, uint _gender, uint _animalType) public {
        require(_age != 0, "Invalid Age");
        require(_animalType != 0, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        if(Users[msg.sender].age == 0) {
            Users[msg.sender].age = _age;
            Users[msg.sender].gender = _gender;
        } 
        require(Users[msg.sender].age == _age, "Invalid Age");
        require(Users[msg.sender].gender == _gender, "Invalid Gender");
        require(Users[msg.sender].hasAnimal == false, "Already adopted a pet");
        if (_gender == 0) {
            require(_animalType == 3 || _animalType == 1, "Invalid animal for men");
        }
        if (_gender == 1 && _age < 40) {
            require(_animalType != 2, "Invalid animal for women under 40");
        }        
        
        if(Users[msg.sender].hasAnimal == true) {
            giveBackAnimal();
        }
        Users[msg.sender].hasAnimal = true;
        Users[msg.sender].hasEverBorrowed = true;
        Users[msg.sender].borrowedAnimalType = _animalType;
        animalCounts[_animalType] -= 1;
        emit Borrowed(_animalType);
    }

    event Returned(uint indexed _animalType);

    function giveBackAnimal() public {
        require(Users[msg.sender].hasEverBorrowed == true, "No borrowed pets");
        uint _animalType = Users[msg.sender].borrowedAnimalType;
        animalCounts[_animalType] += 1;
        Users[msg.sender].hasAnimal = false;
        Users[msg.sender].borrowedAnimalType = 0;
        emit Returned(_animalType);
    }
}