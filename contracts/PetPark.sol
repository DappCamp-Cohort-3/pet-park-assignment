// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
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
    address owner;

    struct Borrower {
        uint age;
        Gender gender;
        AnimalType animal;
    }

    mapping(AnimalType => uint) animalsByType;
    mapping(address => Borrower) borrowers;


    event Added(AnimalType, uint);
    event Borrowed(AnimalType);
    event Returned(AnimalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimal(AnimalType _animalType) {
        require(_animalType != AnimalType.None, "Invalid animal type");
        _;
    }

    modifier validAge(uint _age) {
        require(_age > 0, "Invalid Age");
        _;
    }

    function animalCounts(AnimalType _animalType) public view returns (uint){
        return animalsByType[_animalType];
    }

    function add(AnimalType _animalType, uint _count) external onlyOwner validAnimal(_animalType) {
        animalsByType[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) external validAnimal(_animalType) validAge(_age) {
        require(animalsByType[_animalType] > 0, "Selected animal not available");

        Borrower memory borrower = borrowers[msg.sender];

        if (borrower.age != 0) { // Already registered
            require(borrower.age == _age, "Invalid Age");
            require(borrower.gender == _gender, "Invalid Gender");
            require(borrower.animal == AnimalType.None, "Already adopted a pet");
        }

        if (_gender == Gender.Male) {
            require(_animalType == AnimalType.Fish || _animalType == AnimalType.Dog, "Invalid animal for men");
        } 

        if (_gender == Gender.Female && _age < 40) {
            require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }

        if (borrower.age == 0) { // Not yet registered
            borrowers[msg.sender] = Borrower(_age,_gender, _animalType);
        } else {
            borrowers[msg.sender].animal = _animalType;
        }
        animalsByType[_animalType] -= 1;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        Borrower memory borrower = borrowers[msg.sender];
        require(borrower.animal != AnimalType.None, "No borrowed pets");
        animalsByType[borrower.animal] += 1;
        borrowers[msg.sender].animal = AnimalType.None;
        emit Returned(borrower.animal);
    }
}
