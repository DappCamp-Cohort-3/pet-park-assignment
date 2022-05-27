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
        uint256 age;
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
        public
        onlyOwner
    {
        require(uint256(_animalType) > 0, "Invalid animal");
        animalCounts[_animalType] = _animalcount;
        emit Added(_animalType, _animalcount);
    }

    function giveBackAnimal() public {
        require(
            borrowers[msg.sender].animalType != AnimalType.NONE,
            "No borrowed pets"
        );
        animalCounts[borrowers[msg.sender].animalType] += 1;
        emit Returned(borrowers[msg.sender].animalType);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        AnimalType _animalType
    ) public {
        require(
            _animalType > AnimalType.NONE && _animalType <= AnimalType.PARROT,
            "Invalid animal type"
        );
        require(_age > 0, "Invalid Age");
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        if (borrowers[msg.sender].age > 0) {
            require(borrowers[msg.sender].age == _age, "Invalid Age");
            require(borrowers[msg.sender].gender == _gender, "Invalid Gender");
        }

        require(
            borrowers[msg.sender].animalType == AnimalType.NONE,
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
