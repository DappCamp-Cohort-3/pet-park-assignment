//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Uncomment while developing code for testing.
// import "hardhat/console.sol";

contract PetPark {
    address public owner;

    mapping(uint => uint) public animalCounts;

    mapping(address => user) public users;

    enum animalTypes {
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum genders {
        Male,
        Female
    }

    struct user {
        bool hasEverBorrowed;
        uint borrowedAnimalType;
        uint gender;
        uint age;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    event Added(uint indexed animalType, uint indexed animalCount);

    function add(uint _animalType, uint _count) external onlyOwner {
        require(_animalType != 0, "Invalid animal");
        animalCounts[_animalType] += _count;
        emit Added(_animalType, animalCounts[_animalType]);
    }

    event Borrowed(uint indexed _animalType);

    function borrow(
        uint _age,
        uint _gender,
        uint _animalType
    ) external {
        require(_age != 0, "Invalid Age");
        require(_animalType != 0, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        user memory sender = users[msg.sender];
        if (sender.age == 0) {
            sender.age = _age;
            sender.gender = _gender;
            users[msg.sender] = sender;
        }
        require(sender.age == _age, "Invalid Age");
        require(sender.gender == _gender, "Invalid Gender");
        require(sender.borrowedAnimalType == 0, "Already adopted a pet");
        if (_gender == 0) {
            require(
                _animalType == 3 || _animalType == 1,
                "Invalid animal for men"
            );
        }
        if (_gender == 1 && _age < 40) {
            require(_animalType != 2, "Invalid animal for women under 40");
        }

        if (sender.borrowedAnimalType != 0) {
            giveBackAnimal();
        }
        sender.hasEverBorrowed = true;
        sender.borrowedAnimalType = _animalType;
        users[msg.sender] = sender;
        animalCounts[_animalType] -= 1;
        emit Borrowed(_animalType);
    }

    event Returned(uint indexed _animalType);

    function giveBackAnimal() public {
        user memory sender = users[msg.sender];
        require(sender.hasEverBorrowed == true, "No borrowed pets");
        uint _animalType = sender.borrowedAnimalType;
        animalCounts[_animalType] += 1;
        users[msg.sender].borrowedAnimalType = 0;
        emit Returned(_animalType);
    }
}
