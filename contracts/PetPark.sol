//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address public owner;

    struct Borrower {
        bool isBorrowed;
        uint idPetType;
        uint gender;
        uint age;
    }
    struct Pet {
        bool isAvailable;
        uint number;
    }
    mapping(uint => Pet) pets;
    mapping(address => Borrower) borrowerAnimal;
    Borrower person;

    constructor() {
        // Set the transaction sender as the owner of the contract
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        person = person;
        _;
    }

    // Add a pet to the pet park
    event Added(uint petType, uint petCount);

    //Emit event when a pet is borrowed
    event Borrowed(uint petType);

    function add(uint _animalType, uint _count) public onlyOwner {
        require(_animalType > 0 && _animalType <= 5, "Invalid animal");

        // Add the number of pet of the given type to the animalCounts mapping
        pets[_animalType] = Pet({
            number: _count + pets[_animalType].number,
            isAvailable: true
        });

        emit Added(_animalType, pets[_animalType].number);
    }

    function borrow(
        uint _age,
        uint _gender,
        uint _animalType
    ) external {
        require(_age > 0, "Invalid Age");

        require(_animalType > 0 && _animalType <= 5, "Invalid animal type");

        require(pets[_animalType].isAvailable, "Selected animal not available");

        if (person.isBorrowed) {
            require(person.age == _age, "Invalid Age");
            require(person.gender == _gender, "Invalid Gender");
        }

        //Pet is already
        require(person.isBorrowed != true, "Already adopted a pet");

        if (_gender == 0) {
            require(
                _animalType == 1 || _animalType == 3,
                "Invalid animal for men"
            );
        } else {
            //Women under 40 are not allowed to borrow a Cat
            if (_age < 40) {
                require(_animalType != 2, "Invalid animal for women under 40");
            }
        }

        person = Borrower(true, _animalType, _gender, _age);

        pets[_animalType].number = pets[_animalType].number - 1;

        // isAvailabe is at false when the number of type pet is zero
        if (pets[_animalType].number == 0) {
            pets[_animalType].isAvailable = false;
        }

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(person.isBorrowed, "No borrowed pets");

        //Get the id type of pet borrowed to increase number
        uint idPetType = person.idPetType;

        //resets the account of the person returning the animal to zero
        person.idPetType = 0;
        person.isBorrowed = false;

        //Increase the number of animal according the id of type pet
        pets[idPetType].number = pets[idPetType].number + 1;
        pets[idPetType].isAvailable = true;
    }

    function animalCounts(uint _animalType) public view returns (uint) {
        return pets[_animalType].number;
    }
}
