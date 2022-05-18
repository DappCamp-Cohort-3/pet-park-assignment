//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {

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

    address public owner;
    struct Adopter {
        uint age;
        Gender gender;
        AnimalType animalType;
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => Adopter) addressAdopters;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimal(AnimalType _animalType) {
        require(_animalType > AnimalType.None && _animalType <= AnimalType.Parrot, "Invalid animal");
        _;
    }

    event Added(AnimalType _animalType, uint _count);

    function add(AnimalType _animalType, uint _count) public onlyOwner validAnimal(_animalType) {
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    event Borrowed(AnimalType _animalType);

    function borrow(uint _age, Gender _gender, AnimalType _animalType) public {
        require(_age > 0, "Invalid Age");
        require(_animalType > AnimalType.None && _animalType <= AnimalType.Parrot, "Invalid animal type");

        Adopter storage existingAdopter = addressAdopters[msg.sender];
        if (existingAdopter.age != 0) {
            require (existingAdopter.age == _age, "Invalid Age");
            require (existingAdopter.gender == _gender, "Invalid Gender");
        }

        require(animalCounts[_animalType] > 0, "Selected animal not available");

        require(existingAdopter.animalType == AnimalType.None, "Already adopted a pet");

        if (_gender == Gender.Male) {
            require((_animalType == AnimalType.Fish || _animalType == AnimalType.Dog), "Invalid animal for men");
        }

        if (_gender == Gender.Female && _age < 40) {
            require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }

        addressAdopters[msg.sender] = Adopter(_age, _gender, _animalType);
        animalCounts[_animalType] -= 1;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(addressAdopters[msg.sender].animalType != AnimalType.None, "No borrowed pets");
        AnimalType animalType = addressAdopters[msg.sender].animalType;
        animalCounts[animalType] += 1;
        addressAdopters[msg.sender].animalType = AnimalType.None;
    }
}