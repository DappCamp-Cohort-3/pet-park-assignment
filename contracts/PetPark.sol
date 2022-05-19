//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark{

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

    struct AnimalBorrower {
        uint8 age;
        Gender gender;
        AnimalType animalType;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => AnimalBorrower) public animalBorrowers;

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimal(AnimalType _animalType) {
        require(_animalType > AnimalType.None && _animalType <= AnimalType.Parrot, "Invalid animal");
        _;
    }

    function add(AnimalType _animalType, uint _count) external onlyOwner validAnimal(_animalType){
        animalCounts[_animalType] += _count;

        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) public {
        require(_age > 0, "Invalid Age");
        require(_animalType > AnimalType.None && _animalType <= AnimalType.Parrot, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        AnimalBorrower memory existingAdopter = animalBorrowers[msg.sender];
        if (existingAdopter.age != 0) {
            require (existingAdopter.age == _age, "Invalid Age");
            require (existingAdopter.gender == _gender, "Invalid Gender");
        }

        require(existingAdopter.animalType == AnimalType.None, "Already adopted a pet");

        if (_gender == Gender.Male){
            require((_animalType == AnimalType.Fish || _animalType == AnimalType.Dog), "Invalid animal for men");
        }

        if (_gender == Gender.Female && _animalType == AnimalType.Cat) {
            require(_age >= 40, "Invalid animal for women under 40");
        }

        animalBorrowers[msg.sender] = AnimalBorrower(_age, _gender, _animalType);
        animalCounts[_animalType] -= 1;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(animalBorrowers[msg.sender].animalType != AnimalType.None, "No borrowed pets");
        AnimalType animalType = animalBorrowers[msg.sender].animalType;
        animalCounts[animalType] = animalCounts[animalType] + 1;
        animalBorrowers[msg.sender].animalType = AnimalType.None;

        emit Returned(animalType);
    }
}