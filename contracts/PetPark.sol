//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;
    enum AnimalTypes { None, Fish, Cat, Dog, Rabbit, Parrot}
    enum Gender { Male, Female }

    struct CallerInfo {
        uint age;
        Gender gender;
        bool returningCaller;
    }

    mapping(uint => uint) public animalCounts;
    mapping(address => uint) borrowedAnimalCount;
    mapping(address => uint) borrowedAnimalType;
    mapping(address => CallerInfo) callerNameAndAge;

    event Added(uint indexed animalType, uint indexed count);
    event Borrowed(uint indexed animalType);
    event Returned(uint indexed animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(uint _animalType, uint _count) external {
        require(owner == msg.sender, "Not an owner");
        AnimalTypes currentType = AnimalTypes(_animalType);
        require(AnimalTypes.None != currentType, "Invalid animal");

        animalCounts[_animalType] += _count;

        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType) external {
        require(_age != 0, "Invalid Age");

        if (callerNameAndAge[msg.sender].returningCaller) {
            require(callerNameAndAge[msg.sender].age == _age, "Invalid Age");
            require(callerNameAndAge[msg.sender].gender == Gender(_gender), "Invalid Gender");
        }

        AnimalTypes currentType = AnimalTypes(_animalType);
        require(AnimalTypes.None != currentType, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        require(borrowedAnimalCount[msg.sender] == 0, "Already adopted a pet");
        
        if (Gender(_gender) == Gender.Male) {
            require(currentType == AnimalTypes.Fish || currentType == AnimalTypes.Fish, "Invalid animal for men");
        }

        if (Gender(_gender) == Gender.Female && _age < 40) {
            require(currentType != AnimalTypes.Cat, "Invalid animal for women under 40");
        }

        callerNameAndAge[msg.sender] = CallerInfo(_age, Gender(_gender), true);
        borrowedAnimalCount[msg.sender]++;
        borrowedAnimalType[msg.sender] = _animalType;
        animalCounts[_animalType]--;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        require(callerNameAndAge[msg.sender].returningCaller, "No borrowed pets");
 
        animalCounts[borrowedAnimalType[msg.sender]]++;

        emit Returned(borrowedAnimalType[msg.sender]);

        borrowedAnimalType[msg.sender] = uint(AnimalTypes.None);
        borrowedAnimalCount[msg.sender]--;
    }
}