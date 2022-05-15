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
        AnimalType animal;
        uint256 age;
        Gender gender;
    }

    /** Map of borrowers and animal park animals */
    mapping(AnimalType => uint256) public animalPark;
    mapping(address => Borrower) public borrowers;

    event Added(AnimalType animal, uint256 count);
    event Borrowed(AnimalType animal);
    event Returned(AnimalType animal);

    constructor() {
        owner = msg.sender;
    }

    modifier validAnimal(AnimalType animal) {
        /** Only valid animals are accepted */
        require(
            animal >= AnimalType.Fish && animal <= AnimalType.Parrot,
            "Invalid animal type"
        );
        _;
    }

    /**
    Takes Animal Type and Count. Gives shelter to animals in our park.
    Only contract owner (address deploying the contract) should have access to this functionality.
    Emit event Added with parameters Animal Type and Animal Count.
     */

    function add(AnimalType animal, uint256 count) public validAnimal(animal) {
        /** Only owners of contract can set animal park */
        require(msg.sender == owner, "Not an owner");
        animalPark[animal] = count;
        emit Added(animal, count);
    }

    function animalCounts(AnimalType animal) public view returns (uint256) {
        return animalPark[animal];
    }

    /**
    Takes Age, Gender and Animal Type.
    Can borrow only one animal at a time. Use function giveBackAnimal to borrow another animal.
    Men can borrow only Dog and Fish.
    Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat.
    Throw an error if an address has called this function before using other values for Gender and Age.
    Emit event Borrowed with parameter Animal Type.
     */

    function borrow(
        uint256 age,
        Gender gender,
        AnimalType animal
    ) public validAnimal(animal) {
        /** Age must be greater then zero */
        require(age > 0, "Invalid Age");

        /** Animal must be in park */
        require(animalPark[animal] > 0, "Selected animal not available");

        Borrower memory myBorrow = borrowers[msg.sender];

        /** If borrower has already adopted a pet */
        if (myBorrow.age != 0) {
            /** Check if function has been called before with other values for 
             Gender and Age */
            require(age == myBorrow.age, "Invalid Age");
            require(gender == myBorrow.gender, "Invalid Gender");
        }

        /**  Check if user has already adopted a pet and throw error */
        require(myBorrow.animal == AnimalType.None, "Already adopted a pet.");

        if (gender == Gender.Male) {
            /** If gender is male, only allow Dogs, and Fish  */
            require(
                gender == Gender.Male &&
                    (animal == AnimalType.Dog || animal == AnimalType.Fish),
                "Invalid animal for men"
            );
        }

        if (gender == Gender.Female && age < 40) {
            /** if Female and under 40 don't allow cats */
            require(
                animal != AnimalType.Cat,
                "Invalid animal for women under 40"
            );
        }

        Borrower memory borrower = Borrower(animal, age, gender);
        borrowers[msg.sender] = borrower;
        animalPark[animal] = animalPark[animal] - 1;
        emit Borrowed(animal);
    }

    /**
    Throw an error if user hasn't borrowed before.
    Emit event Returned with parameter Animal Type.
     */
    function giveBackAnimal() public {
        Borrower memory myBorrow = borrowers[msg.sender];
        /** If they haven't borrowed a pet throw error */
        require(myBorrow.age != 0, "No borrowed pets");
        animalPark[myBorrow.animal] = animalPark[myBorrow.animal] + 1;
        borrowers[msg.sender] = Borrower(AnimalType.None, 0, Gender.Male);
        emit Returned(myBorrow.animal);
    }
}
