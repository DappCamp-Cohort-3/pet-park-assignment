//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address owner;
    enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
    enum Gender { Male, Female }

    struct Person {
        Gender gender;
        uint age;
        bool isRegistered;
    }

    mapping (uint => uint) animalCountByType;
    mapping (address => Person) peopleByAddress;
    mapping (address => uint) borrowedByAddress;

    event Added (uint indexed animalType, uint indexed count);
    event Borrowed (uint indexed animalType);
    event Returned  (uint indexed animalType);


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    function animalCounts(uint _animalType) public view returns (uint) {
        return animalCountByType[_animalType];
    }

    function add(uint _animalType, uint _count) public onlyOwner {
        AnimalType currentType = AnimalType(_animalType);
        require(AnimalType.None != currentType, 'Invalid animal');

        uint currentTypeInt = uint(currentType);
        animalCountByType[currentTypeInt] += _count;

        emit Added(currentTypeInt, animalCountByType[currentTypeInt]);
    }

    function giveBackAnimal() public {
        require(borrowedByAddress[msg.sender] > 0, "No borrowed pets");
        uint animalTypeReturned = borrowedByAddress[msg.sender];
        borrowedByAddress[msg.sender] = 0;
        animalCountByType[animalTypeReturned]++;
        emit Returned(animalTypeReturned);
    }

    function registerAndVerifyPerson(uint _age, uint _gender) private returns (Person memory) {
        require(_age > 0, "Invalid Age");
        Person memory currentPerson = peopleByAddress[msg.sender];
        Gender genderFromParam = Gender(_gender);

        if (currentPerson.isRegistered) {
            require(currentPerson.age == _age, "Invalid Age");
            require(currentPerson.gender == genderFromParam, "Invalid Gender");

            return currentPerson;
        }
        Person memory newPerson = Person({
            gender: genderFromParam,
            age: _age,
            isRegistered: true
        });

        peopleByAddress[msg.sender] = newPerson;

        return newPerson;
    }

    function performBorrowChecks(Person memory _caller, uint _animalType) private view returns (bool) {
        AnimalType animalType = AnimalType(_animalType);
        require(borrowedByAddress[msg.sender] == 0, "Already adopted a pet");
        require(AnimalType.None != animalType, "Invalid animal type");
        require(animalCountByType[_animalType] > 0, "Selected animal not available");
        
        if (_caller.gender == Gender.Male) {
            require(
                animalType == AnimalType.Dog || animalType == AnimalType.Fish,
                "Invalid animal for men");
        }
        if (_caller.gender == Gender.Female && _caller.age < 40) {
            require(animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }


        return true;
    }

    function borrow(uint _age, uint _gender, uint _animalType) public {
        Person memory caller = registerAndVerifyPerson(_age, _gender);
    
        bool canBorrow = performBorrowChecks(caller, _animalType);

        if (canBorrow) {
            animalCountByType[_animalType]--;
            borrowedByAddress[msg.sender] = _animalType;
            emit Borrowed(_animalType);
        }
    }
}