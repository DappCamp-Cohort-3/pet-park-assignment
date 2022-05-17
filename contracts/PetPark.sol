//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    address owner;

    enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
    enum Gender { Male, Female }

    mapping(AnimalType => int) animalCount;
    mapping(address => AnimalType) isBorrowing;

    event Added(AnimalType animal, int count);
    event Borrowed(AnimalType animal);
    event Returned(AnimalType animal);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    modifier isOldEnough(uint age) {
        require(age != 0, "Invalid Age");
        _;
    }

    modifier isValidAnimal(AnimalType animal) {
        require(animal != AnimalType.None, "Invalid animal");
        _;
    }

    modifier isValidAnimal2(AnimalType animal) {
        require(animal != AnimalType.None, "Invalid animal type");
        _;
    }

    modifier isAvailableAnimal(AnimalType animal, int count) {
        require(animalCount[animal] - count >= 0, "Selected animal not available");
        _;
    }

    modifier noBoysAllowed(Gender gender, AnimalType animal) {
        require(
            (animal == AnimalType.Fish || animal == AnimalType.Dog) && gender == Gender.Male, 
            "Invalid animal for men"
        );
        _;
    }

    modifier noYoungCatLady(uint age, Gender gender, AnimalType animal) {
        require(
            (animal == AnimalType.Cat && age >= 40 && gender == Gender.Female), 
            "Invalid animal for women under 40"
        );
        _;
    }

    modifier notBorrowing() {
        require(isBorrowing[msg.sender] == AnimalType.None, "Already adopted a pet");
        _;
    }

    modifier alreadyBorrowing() {
        require(isBorrowing[msg.sender] != AnimalType.None, "No borrowed pets");
        _;
    }

    function add(AnimalType _animal, int _count) 
        public 
        onlyOwner
        isValidAnimal(_animal)
    {
        animalCount[_animal] = animalCount[_animal] + _count;
        emit Added(_animal, animalCount[_animal]);
    }

    function borrow(uint age, Gender _gender, AnimalType _animal) 
        public
        isOldEnough(age)
        isValidAnimal2(_animal)
        isAvailableAnimal(_animal, 1)
        noBoysAllowed(_gender, _animal)
        notBorrowing
    {
        require(
            (_animal == AnimalType.Cat && age >= 40 && _gender == Gender.Female), 
            "Invalid animal for women under 40"
        );
        animalCount[_animal] = animalCount[_animal] - 1;
        isBorrowing[msg.sender] = _animal;
        emit Borrowed(_animal);
    }

    function giveBackAnimal() 
        public
        alreadyBorrowing
    {
        animalCount[isBorrowing[msg.sender]] = animalCount[isBorrowing[msg.sender]] + 1;
        emit Returned(isBorrowing[msg.sender]);
        isBorrowing[msg.sender] = AnimalType.None;
    }

    function animalCounts(AnimalType animal) 
        public
        view
    {
        animalCount[animal];
    }
}