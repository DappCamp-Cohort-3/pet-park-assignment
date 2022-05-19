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
        Male,
        Female
    }

    struct User {
        AnimalType animal;
        Gender gender;
        uint age;
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => User) public userInfo;

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

    modifier isValidAnimalType(AnimalType animal) {
        require(animal != AnimalType.None, "Invalid animal type");
        _;
    }

    modifier isAvailableAnimal(AnimalType animal) {
        require(animalCounts[animal] > 0, "Selected animal not available");
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
        uint _age,
        Gender _gender,
        AnimalType _animal
    )
        external
        isOldEnough(_age)
        isValidAnimalType(_animal)
        isAvailableAnimal(_animal)
    {
        User storage u = userInfo[msg.sender];

        if (u.age != _age && u.age != 0) {
            revert("Invalid Age");
        }

        if (u.gender != _gender && _gender == Gender.Female) {
            revert("Invalid Gender");
        }

        u.age = _age;
        u.gender = _gender;

        if (u.animal != AnimalType.None) {
            revert("Already adopted a pet");
        }

        if (
            u.gender == Gender.Female && _animal == AnimalType.Cat && u.age < 40
        ) {
            revert("Invalid animal for women under 40");
        }

        if (u.gender == Gender.Male) {
            if (_animal != AnimalType.Fish && _animal != AnimalType.Dog) {
                revert("Invalid animal for men");
            }
        }

        u.animal = _animal;
        uint count = animalCounts[_animal];
        animalCounts[_animal] = count - 1;
        emit Borrowed(_animal);
    }

    function giveBackAnimal() external {
        User storage u = userInfo[msg.sender];
        if (u.animal == AnimalType.None) {
            revert("No borrowed pets");
        }
        uint count = animalCounts[u.animal];
        animalCounts[u.animal] = count + 1;
        emit Returned(u.animal);
        u.animal = AnimalType.None;
    }
}
