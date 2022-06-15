//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;
    enum AnimalType {
        NoExist,
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
    struct Borrower {
        uint8 age;
        Gender gender;
        AnimalType animalType;
        uint borrowCount;
    }

    mapping(address => Borrower) borrowersInfo;

    mapping(AnimalType => uint) public animalCounts;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimalType(AnimalType animalType) {
        require(
            animalType <= AnimalType.Parrot && animalType >= AnimalType.Fish,
            "Invalid animal type"
        );
        _;
    }

    modifier validBorrowInfo(uint8 age, Gender gender) {
        require(age > 0, "Invalid Age");
        Borrower memory senderBorrow = borrowersInfo[msg.sender];
        if (senderBorrow.borrowCount == 1) {
            require(senderBorrow.age == age, "Invalid Age");
            require(senderBorrow.gender == gender, "Invalid Gender");
        }
        _;
    }

    modifier validLogicOnGender(
        uint8 _age,
        Gender _gender,
        AnimalType _animalType
    ) {
        if (borrowersInfo[msg.sender].borrowCount > 0) {
            revert("Already adopted a pet");
        }

        if (_gender == Gender.Male) {
            require(
                _animalType == AnimalType.Fish || _animalType == AnimalType.Dog,
                "Invalid animal for men"
            );
        }

        if (_gender == Gender.Female) {
            require(
                _age < 40 && _animalType != AnimalType.Cat,
                "Invalid animal for women under 40"
            );
        }
        _;
    }

    event Added(AnimalType animalType, uint animalCounts);

    function add(AnimalType _animalType, uint _animalCounts)
        external
        onlyOwner
        validAnimalType(_animalType)
    {
        animalCounts[_animalType] = _animalCounts;
        emit Added(_animalType, animalCounts[_animalType]);
    }

    event Borrowed(AnimalType animalType);

    function borrow(
        uint8 _age,
        Gender _gender,
        AnimalType _animalType
    )
        external
        validBorrowInfo(_age, _gender)
        validAnimalType(_animalType)
        validLogicOnGender(_age, _gender, _animalType)
    {
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        Borrower memory senderBorrow = Borrower(_age, _gender, _animalType, 1);
        borrowersInfo[msg.sender] = senderBorrow;
        animalCounts[_animalType]--;
        emit Borrowed(_animalType);
    }

    event Returned(AnimalType animalType);

    function giveBackAnimal() external {
        Borrower memory senderBorrow = borrowersInfo[msg.sender];

        require(senderBorrow.borrowCount > 0, " No borrowed pets");
        senderBorrow.borrowCount == 0;
        animalCounts[senderBorrow.animalType]++;
        senderBorrow.animalType = AnimalType.NoExist;
        emit Returned(senderBorrow.animalType);
    }
}
