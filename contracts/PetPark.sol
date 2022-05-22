//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    address  contractOwner;
    enum AnimalType {
        NONE, FISH, CAT, DOG, RABBIT, PARROT
    }
    enum Gender{
        MALE, FEMALE
    }
    struct Animal {
        AnimalType animalType;
        uint count;
    }

    struct Borrower {
        Gender gender;
        uint age;
        uint petCount;
        bool exists;
        AnimalType animalType;
    }

    event Added(AnimalType animalType, uint animalCount);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    mapping(AnimalType => Animal) animals;
    mapping(address => Borrower)borrowers;

    constructor(){
        contractOwner = msg.sender;
    }

    /*
    * @dev method to add animals to the contract.@author Satish
    */
    function add(AnimalType _animalType, uint _count) external onlyOwner {
        require(_animalType != AnimalType.NONE, "Invalid animal");
        animals[_animalType].animalType = _animalType;
        animals[_animalType].count += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) external {
        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.NONE, "Invalid animal type");
        require(animals[_animalType].count > 0, "Selected animal not available");
        if (borrowers[msg.sender].exists) {
            require(borrowers[msg.sender].age == _age, "Invalid Age");
            require(borrowers[msg.sender].gender == _gender, "Invalid Gender");
            require(borrowers[msg.sender].petCount == 0, "Already adopted a pet");
        }
        if (_gender == Gender.MALE) {
            require(_animalType == AnimalType.FISH || _animalType == AnimalType.DOG, "Invalid animal for men");
        }
        if (_gender == Gender.FEMALE) {
            if (_age < 40) {
                require(_animalType != AnimalType.CAT, "Invalid animal for women under 40");
            }

        }
        animals[_animalType].count -= 1;
        borrowers[msg.sender].age = _age;
        borrowers[msg.sender].gender = _gender;
        borrowers[msg.sender].exists = true;
        borrowers[msg.sender].petCount = 1;
        borrowers[msg.sender].animalType = _animalType;
        emit Borrowed(_animalType);
    }

    function animalCounts(AnimalType _animalType) view external returns (uint){
        return animals[_animalType].count;
    }

    function giveBackAnimal() external {
        require(borrowers[msg.sender].exists, "No borrowed pets");
        AnimalType returnedAnimalType = borrowers[msg.sender].animalType;
        animals[returnedAnimalType].count += 1;
        borrowers[msg.sender].animalType = AnimalType.NONE;
        borrowers[msg.sender].petCount = 0;
        emit Returned(returnedAnimalType);
    }



    modifier onlyOwner(){
        require(msg.sender == contractOwner, "Not an owner");
        _;
    }


}