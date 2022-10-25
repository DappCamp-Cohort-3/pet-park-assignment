//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    enum AnimalType {
        NONE,
        FISH,
        CAT,
        DOG,
        RABBIT,
        PARROT
    }
    enum Gender {
        MALE,
        FEMALE
    }
    struct Borrower {
        Gender gender;
        uint8 age;
        AnimalType animalType;
    }

    mapping(address => Borrower) public borrowers;
    mapping(AnimalType => uint256) public animalCounts;

    event Added(AnimalType animalType, uint256 animalcount);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    function add(AnimalType _animalType, uint256 _animalcount)
        external
        onlyOwner
    {
        require(uint256(_animalType) > 0, "Invalid animal");
        animalCounts[_animalType] = _animalcount;
        emit Added(_animalType, _animalcount);
    }

    function giveBackAnimal() external {
        Borrower memory borrower = borrowers[msg.sender];
        require(
            borrowers[msg.sender].animalType != AnimalType.NONE,
            "No borrowed pets"
        );
        animalCounts[borrower.animalType] += 1;
        borrower.animalType = AnimalType.NONE;
        emit Returned(borrower.animalType);
    }

    function borrow(
        uint8 _age,
        Gender _gender,
        AnimalType _animalType
    ) external {
        Borrower memory borrower = borrowers[msg.sender];

        require(
            _animalType > AnimalType.NONE && _animalType <= AnimalType.PARROT,
            "Invalid animal type"
        );
        require(_age > 0, "Invalid Age");
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        if (borrower.age > 0) {
            require(borrower.age == _age, "Invalid Age");
            require(borrower.gender == _gender, "Invalid Gender");
        }

        require(
            borrower.animalType == AnimalType.NONE,
            "Already adopted a pet"
        );
        if (_gender == Gender.MALE)
            require(
                _animalType == AnimalType.DOG || _animalType == AnimalType.FISH,
                "Invalid animal for men"
            );
        if (_gender == Gender.FEMALE && _age < 40)
            require(
                _animalType != AnimalType.CAT,
                "Invalid animal for women under 40"
            );

        animalCounts[_animalType] -= 1;
        borrowers[msg.sender] = Borrower({
            gender: _gender,
            age: _age,
            animalType: _animalType
        });
        emit Borrowed(_animalType);
    }
}
