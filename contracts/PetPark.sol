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
        if (borrowersInfo[msg.sender].borrowCount == 1) {
            require(borrowersInfo[msg.sender].age == age, "Invalid Age");
            require(
                borrowersInfo[msg.sender].gender == gender,
                "Invalid Gender"
            );
        }
        _;
    }

    modifier validLogicOnGender(
        uint8 age,
        Gender gender,
        AnimalType animalType
    ) {
        if (borrowersInfo[msg.sender].borrowCount > 0) {
            revert("Already adopted a pet");
        }

        if (gender == Gender.Male) {
            require(
                animalType == AnimalType.Fish || animalType == AnimalType.Dog,
                "Invalid animal for men"
            );
        }

        if (gender == Gender.Female) {
            require(
                age < 40 && animalType != AnimalType.Cat,
                "Invalid animal for women under 40"
            );
        }
        _;
    }

    event Added(AnimalType animalType, uint animalCounts);

    function add(AnimalType _animalType, uint _animalCounts)
        public
        onlyOwner
        validAnimalType(_animalType)
    {
        animalCounts[_animalType] = _animalCounts;
        emit Added(_animalType, animalCounts[_animalType]);
    }

    event Borrowed(AnimalType animalType);

    function borrow(
        uint8 age,
        Gender gender,
        AnimalType animalType
    )
        public
        validBorrowInfo(age, gender)
        validAnimalType(animalType)
        validLogicOnGender(age, gender, animalType)
    {
        require(animalCounts[animalType] > 0, "Selected animal not available");

        borrowersInfo[msg.sender].age = age;
        borrowersInfo[msg.sender].gender = gender;
        borrowersInfo[msg.sender].animalType = animalType;
        borrowersInfo[msg.sender].borrowCount = 1;
        animalCounts[animalType]--;
        emit Borrowed(animalType);
    }

    event Returned(AnimalType animalType);

    function giveBackAnimal() public {
        require(borrowersInfo[msg.sender].borrowCount > 0, " No borrowed pets");
        borrowersInfo[msg.sender].borrowCount == 0;
        animalCounts[borrowersInfo[msg.sender].animalType]++;
        borrowersInfo[msg.sender].animalType = AnimalType.NoExist;
        emit Returned(borrowersInfo[msg.sender].animalType);
    }
}
