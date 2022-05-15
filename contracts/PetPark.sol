//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Animal {
    uint8 public animalType;

    constructor(uint8 _animalType){
        animalType = _animalType;
    }
}

contract Fish is Animal(1) {
}

contract PetPark {
    address owner_;

    struct Borrower{
        uint8 age;
        uint8 gender;
        uint8 animalType;
        uint256 count;
    }

    mapping(uint8 => uint256) animalsInPark;
    mapping(address => Borrower) borrowers;    

    event Added(uint8 animalType, uint256 count);
    event Borrowed(uint8 animalType);
    event Returned(uint8 animalType);

    constructor(){
        owner_ = msg.sender;
    }

    error InvalidAnimal();
    error OwnerRequired();
    error AnimalNotAvailable();

    modifier checkAnimalType(uint8 animalType) {
        require(animalType >= 1 && animalType <= 5, "Invalid animal type");
        _; 
    }

    modifier checkOwner(){
        require(msg.sender == owner_, "Not an owner");
        _;
    }

    modifier checkValidAge(uint8 age){
        require(age > 0, "Invalid Age");
        _;
    }
    
    modifier checkAnimalInPark(uint8 animalType) {
        require(animalsInPark[animalType] != 0, "Selected animal not available");
        _;
    }

    modifier checkWhatMenCanBorrow(uint8 gender, uint8 animalType){
        if(gender == 0 && (animalType != 1 && animalType != 3)){
            revert("Invalid animal for men");
        }
        _;
    }

    modifier checkWhatWomanCanBorrow(uint8 gender, uint8 animalType){
        _;
    }

    modifier alreadyBorrowed() {
        require(borrowers[msg.sender].age > 0, "Already adopted a pet");
        _;
    }

    function add(uint8 animalType, uint256 count) external checkOwner{
        require(animalType >= 1 && animalType <= 5, "Invalid animal");

        animalsInPark[animalType] += count;
        emit Added(animalType, count);
    }

    function borrow(uint8 age, uint8 gender, uint8 animalType) external checkValidAge(age) checkAnimalType(animalType) checkAnimalInPark(animalType)  {        
        if(gender == 1 && age < 40 && animalType == 2){
            revert("Invalid animal for women under 40");
        }        
        
        Borrower storage borrower_ = borrowers[msg.sender];
        if(borrower_.age > 0){
            if(borrower_.age != age){
                revert("Invalid Age");
            }
            if(borrower_.gender != gender){
                revert("Invalid Gender");
            }            
            revert("Already adopted a pet");
        }
        
        if(gender == 0 && (animalType != 1 && animalType != 3)){
            revert("Invalid animal for men");
        }        
        
        animalsInPark[animalType] -= 1;
        borrowers[msg.sender] = Borrower({age: age, gender: gender, animalType: animalType, count: animalsInPark[animalType]});

        emit Borrowed(animalType);
    }

    function giveBackAnimal() external {
        Borrower storage borrower_ = borrowers[msg.sender];
        require(borrower_.age > 0, "No borrowed pets");
                        
        animalsInPark[borrower_.animalType] += 1;
        delete borrowers[msg.sender];

        emit Returned(borrower_.animalType);
    }

    function animalCounts(uint8 animalType) external checkAnimalType(animalType) view returns (uint256) {
        return animalsInPark[animalType];
    }
}