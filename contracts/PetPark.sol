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

    struct Borrower {
        uint age;
        Gender gender;
    }

    mapping(address => AnimalType) borrowedAnimals;
    mapping(address => Borrower) borrowerList;
    mapping(AnimalType => uint) public animalCounts;

    event Added(AnimalType animal, uint animalCount);
    event Borrowed(AnimalType animal);
    event Returned(AnimalType animal);

    modifier validAnimalType(AnimalType animal) {
        require(
            animal > AnimalType.None && animal <= AnimalType.Parrot,
            "Invalid animal type"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // give shelter to animals in the park
    function add(AnimalType animal, uint count) external {
        require(msg.sender == owner, "Not an owner");
        require(
            animal > AnimalType.None && animal <= AnimalType.Parrot,
            "Invalid animal"
        );
        animalCounts[animal] += count;
        emit Added(animal, count);
    }

    function borrow(
        uint age,
        Gender gender,
        AnimalType animal
    ) public validAnimalType(animal) {
        require(age > 0, "Invalid Age");

        require(animalCounts[animal] > 0, "Selected animal not available");

        if (gender == Gender.Male) {
            require(
                animal == AnimalType.Dog || animal == AnimalType.Fish,
                "Invalid animal for men"
            );
        } else {
            if (age < 40) {
                require(
                    animal != AnimalType.Cat,
                    "Invalid animal for women under 40"
                );
            }
        }

        // require(
        //     borrowedAnimals[msg.sender] != AnimalType.None,
        //     "Already adopted a pet"
        // );

        Borrower storage borrower = borrowerList[msg.sender];
        if (borrower.age == 0) {
            borrower.age = age;
            borrower.gender = gender;
        } else {
            require(borrower.age == age, "Invalid Age");
            require(borrower.gender == gender, "Invalid Gender");
        }

        animalCounts[animal] -= 1;
        borrowedAnimals[msg.sender] = animal;
        emit Borrowed(animal);
    }

    function giveBackAnimal() public {
        require(
            borrowedAnimals[msg.sender] != AnimalType.None,
            "No borrowed pets"
        );
        AnimalType animal = borrowedAnimals[msg.sender];
        delete borrowedAnimals[msg.sender];
        animalCounts[animal] += 1;
        emit Returned(animal);
    }
}
