//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    enum AnimalType {
        NotValid,
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

    struct RenterInfo {
        uint8 age;
        Gender gender;
    }
    mapping(AnimalType => uint) public petsInShelter;
    mapping(address => RenterInfo) public renters;
    mapping(address => AnimalType) public rentedPet;
    address public owner;

    event Added(uint8 animalType, uint8 animalCount);
    event Borrowed(uint8 animalType);
    event Returned(uint8 animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(uint8 animalType, uint8 count) external {
        require(msg.sender == owner, "Not an owner");
        require(
            animalType != uint(AnimalType.NotValid) &&
                animalType <= uint(AnimalType.Parrot),
            "Invalid animal"
        );

        petsInShelter[AnimalType(animalType)] += count;
        emit Added(animalType, count);
    }

    function borrow(
        uint8 age,
        uint8 gender,
        uint8 animalType
    ) external {
        require(age != 0, "Invalid Age");
        require(
            animalType != uint(AnimalType.NotValid) &&
                animalType <= uint(AnimalType.Parrot),
            "Invalid animal type"
        );
        require(petsInShelter[AnimalType(animalType)] > 0, "Selected animal not available");
        if (renters[msg.sender].age != 0) {
            require(renters[msg.sender].age == age, "Invalid Age");
            require(uint(renters[msg.sender].gender) == gender, "Invalid Gender");
        }
        require(
            rentedPet[msg.sender] == AnimalType.NotValid,
            "Already adopted a pet"
        );

        if (
            gender == uint(Gender.Female) &&
            age < 40 &&
            animalType == uint(AnimalType.Cat)
        ) {
            revert("Invalid animal for women under 40");
        }
        if (
            gender == uint(Gender.Male) &&
            animalType != uint(AnimalType.Dog) &&
            animalType != uint(AnimalType.Fish)
        ) {
            revert("Invalid animal for men");
        }
        if (renters[msg.sender].age == 0) {
            renters[msg.sender] = RenterInfo(age, Gender(gender));
        }
        petsInShelter[AnimalType(animalType)] -= 1;
        rentedPet[msg.sender] = AnimalType(animalType);
        emit Borrowed(animalType);
    }

    function giveBackAnimal() external {
        require(
            rentedPet[msg.sender] != AnimalType.NotValid,
            "No borrowed pets"
        );
        require(renters[msg.sender].age != 0, "No borrowed pets");
        AnimalType animalType = rentedPet[msg.sender];
        petsInShelter[animalType] += 1;
        rentedPet[msg.sender] = AnimalType.NotValid;
        emit Returned(uint8(animalType));
    }

    function animalCounts(uint8 animalType) external view returns(uint) {
        return petsInShelter[AnimalType(animalType)];
    }
}
