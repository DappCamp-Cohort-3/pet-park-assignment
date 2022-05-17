//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

    mapping(AnimalType => uint256) private shelter;
    mapping(address => Person) private borrowers;

    struct Person {
        uint256 age;
        Gender gender;
        AnimalType animal;
        bool initialized;
    }

    event Added(uint256 AnimalType, uint256 Count);
    event Borrowed(uint256 AnimalType);
    event Returned(uint256 AnimalType);

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

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animal, uint256 _count) public onlyOwner {
        require(_animal != AnimalType.None, "Invalid animal");
        shelter[_animal] = _count;
        emit Added(uint256(_animal), _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        AnimalType _animal
    ) public hasValidAnimal(_animal) hasValidAge(_age) {


        Person storage person = borrowers[msg.sender];

        if (person.initialized) {
            require(person.age == _age, "Invalid Age");
            require(person.gender == _gender, "Invalid Gender");
        } else {
            person.age = _age;
            person.gender = _gender;
            person.initialized = true;
        }

        require(person.animal == AnimalType.None, "Already adopted a pet");
        
        if (_gender == Gender.Male) 
                require( _animal == AnimalType.Dog || _animal == AnimalType.Fish,
                "Invalid animal for men");

        if (_gender == Gender.Female && _animal == AnimalType.Cat) 
                require(_age > 40, "Invalid animal for women under 40");
        

        require(shelter[_animal] > 0, "Selected animal not available");
        shelter[_animal] -= 1;
        person.animal = _animal;        
        emit Borrowed(uint256(_animal));
    }

    function animalCounts(AnimalType _animal) external view returns (uint256) {
        return shelter[_animal];
    }

    function giveBackAnimal() external {
        Person storage person = borrowers[msg.sender];
        require(person.animal != AnimalType.None, "No borrowed pets");

        AnimalType _animal = person.animal;
        shelter[_animal] += 1;
        person.animal = AnimalType.None;
        emit Returned(uint256(_animal));
    }

    modifier hasValidAnimal(AnimalType _animal) {
        require(_animal != AnimalType.None, "Invalid animal type");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier hasValidAge(uint256 _age) {
        require(_age > 0, "Invalid Age");
        _;
    }

}
