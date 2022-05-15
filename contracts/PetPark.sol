//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {

    address public owner;
    mapping(uint => uint) public animalCounts;

    uint private stable_age;
    uint private stable_gender;
    uint private stable_animal;

    bool private hasBorrowed;
    
    constructor(){
        owner = msg.sender;
    }

    event Added (uint animalType, uint count);
    event Borrowed (uint animalType);

    modifier onlyOwner(){
        require(msg.sender ==  owner, "Not an owner");
        _;
    }

    function add(uint _animalType, uint _count) external onlyOwner(){
        require(_animalType < 6 && _animalType > 0, "Invalid animal");
        animalCounts[_animalType] = _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType) external {
        require(_age > 0, "Invalid Age");
        require(_animalType != 0, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        if(stable_age == 0){
            stable_age = _age;
            stable_gender = _gender;
        } else{
            require(_age == stable_age, "Invalid Age");
            require(_gender == stable_gender, "Invalid Gender");
            require(!hasBorrowed, "Already adopted a pet");
        }

        if ( _gender == 0){
            require(_animalType == 3 || _animalType ==  1, "Invalid animal for men");
            animalCounts[_animalType] -= 1;
        } else if (_gender == 1){
            require(_age > 39, "Invalid animal for women under 40");
            animalCounts[_animalType] -= 1;
        }

        hasBorrowed = true;
        stable_animal = _animalType;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(hasBorrowed, "No borrowed pets");
        animalCounts[stable_animal] += 1;
        hasBorrowed = false;
    }
}