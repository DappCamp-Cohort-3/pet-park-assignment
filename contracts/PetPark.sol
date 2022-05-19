//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }
    enum Gender {
        None,
        Male,
        Female
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => AnimalType) public isBorrowing;
    mapping(address => uint) public userAge;
    mapping(address => Gender) public userGender;

    event Added(AnimalType animal, uint count);
    event Borrowed(AnimalType animal);
    event Returned(AnimalType animal);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    modifier isOldEnough(uint age) {
        require(age != 0, "Invalid Age");
        _;
    }

    modifier isValidAnimal(AnimalType animal) {
        require(animal != AnimalType.None, "Invalid animal");
        _;
    }

    modifier isValidAnimal2(AnimalType animal) {
        require(animal != AnimalType.None, "Invalid animal type");
        _;
    }

    modifier isAvailableAnimal(AnimalType animal) {
        require(animalCounts[animal] > 0, "Selected animal not available");
        _;
    }

    modifier alreadyBorrowing() {
        require(isBorrowing[msg.sender] != AnimalType.None, "No borrowed pets");
        _;
    }

    modifier sameAge(uint age) {
        require(userAge[msg.sender] == age, "Invalid Age");
        _;
    }

    modifier sameGender(Gender gender) {
        require(userGender[msg.sender] == gender, "Invalid Gender");
        _;
    }

    function add(AnimalType _animal, uint _count)
        external
        onlyOwner
        isValidAnimal(_animal)
    {
        animalCounts[_animal] = animalCounts[_animal] + _count;
        emit Added(_animal, animalCounts[_animal]);
    }

    function borrow(
        uint age,
        Gender _gender,
        AnimalType _animal
    )
        external
        isOldEnough(age)
        isValidAnimal2(_animal)
        isAvailableAnimal(_animal)
    {
        if (_gender == Gender.Male) {
            if (_animal != AnimalType.Fish || _animal != AnimalType.Dog) {
                revert("Invalid animal for men");
            }
        }

        if (_gender == Gender.Female) {
            if (_animal == AnimalType.Cat && age < 40) {
                revert("Invalid animal for women under 40");
            }
        }

        if (isBorrowing[msg.sender] != AnimalType.None) {
            revert("Already adopted a pet");
        }

        if (userAge[msg.sender] == 0) userAge[msg.sender] = age;
        if (userGender[msg.sender] == Gender.None)
            userGender[msg.sender] = _gender;

        if (userAge[msg.sender] != age) {
            revert("Invalid Age");
        }

        if (userGender[msg.sender] != _gender) {
            revert("Invalid Gender");
        }

        isBorrowing[msg.sender] = _animal;
        uint count = animalCounts[_animal];
        animalCounts[_animal] = count - 1;
        emit Borrowed(_animal);
    }

    function giveBackAnimal() external alreadyBorrowing {
        AnimalType borrowedAnimal = isBorrowing[msg.sender];
        uint count = animalCounts[borrowedAnimal];
        animalCounts[borrowedAnimal] = count + 1;
        emit Returned(borrowedAnimal);
        isBorrowing[msg.sender] = AnimalType.None;
    }
}
