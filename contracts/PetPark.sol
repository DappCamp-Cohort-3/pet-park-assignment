//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address public owner;
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
    enum CanBorrow {
        Yes,
        No
    }
    struct UserInfo {
        AnimalType animal;
        Gender gender;
        uint256 age;
    }

    mapping(address => CanBorrow) public userCanBorrow;
    event Added(AnimalType animal, uint256 AnimalCount);
    event Borrowed(AnimalType animal);
    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => uint256) public userBorrowCount;
    mapping(address => UserInfo) public usersAllowedBorrow;
    mapping(address => bool) public userHasBorrowed;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animal, uint256 _count) public onlyOwner {
        require(_animal != AnimalType.None, "Invalid animal");
        animalCounts[_animal] += _count;
        emit Added(_animal, _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        AnimalType _animal
    ) public {
        require(_animal != AnimalType.None, "Invalid animal type");
        require(_age > 0, "Invalid Age");
        require(animalCounts[_animal] > 0, "Selected animal not available");
        if (userBorrowCount[msg.sender] == 0) {
            userCanBorrow[msg.sender] == CanBorrow.Yes;
        }

        if (_gender == Gender.Female && _age < 40) {
            require(
                _animal != AnimalType.Cat,
                "Invalid animal for women under 40"
            );
        }
        if (userHasBorrowed[msg.sender] == true) {
            require(
                usersAllowedBorrow[msg.sender].gender == _gender,
                "Invalid Gender"
            );
            require(usersAllowedBorrow[msg.sender].age == _age, "Invalid Age");
        }
        require(
            userCanBorrow[msg.sender] == CanBorrow.Yes,
            "Already adopted a pet"
        );
        if (_gender == Gender.Male) {
            require(
                _animal == AnimalType.Dog || _animal == AnimalType.Fish,
                "Invalid animal for men"
            );
        }
        animalCounts[_animal] -= 1;
        userBorrowCount[msg.sender] += 1;
        userCanBorrow[msg.sender] = CanBorrow.No;
        usersAllowedBorrow[msg.sender] = UserInfo(_animal, _gender, _age);
        userHasBorrowed[msg.sender] = true;

        emit Borrowed(_animal);
    }

    function giveBackAnimal() public {
        require(userBorrowCount[msg.sender] != 0, "No borrowed pets");
        animalCounts[usersAllowedBorrow[msg.sender].animal] += 1;
    }
}
