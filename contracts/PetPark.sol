//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address public owner;

    enum Pets {
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
    struct Person {
        Gender gender;
        uint256 age;
        Pets animal;
        bool isExists;
        bool isBorrowed;
    }

    mapping(Pets => uint256) public animalCounts;
    mapping(address => Person) public person;


    event Added(Pets _pet, uint256 _count);
    event Borrowed(Pets _pet);

    constructor() {
        owner = msg.sender;
    }

    function add(Pets _animal, uint256 _count) public {
        require(msg.sender == owner, "Not an owner");
        require(_animal != Pets.None, "Invalid animal");
        animalCounts[_animal] += _count;
        emit Added(_animal, _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        Pets _animal
    ) public {
        require(_age > 0, "Invalid Age");
        require(_animal != Pets.None, "Invalid animal type");
        require(animalCounts[_animal] != 0, "Selected animal not available");

        if(person[msg.sender].isExists) {
            require(person[msg.sender].age == _age, "Invalid Age");
            require(person[msg.sender].gender == _gender, "Invalid Gender");
            require(person[msg.sender].isBorrowed == false, "Already adopted a pet");
        }
        else {
            person[msg.sender] = Person(_gender, _age, Pets.None, true, false);
        }

        if (_gender == Gender.Male) {
            require(
                _animal == Pets.Dog || _animal == Pets.Fish,
                "Invalid animal for men"
            );
        }

        if (_gender == Gender.Female && _animal == Pets.Cat) {
            require(_age >= 40, "Invalid animal for women under 40");
        }

        animalCounts[_animal] -= 1;
        person[msg.sender].isBorrowed = true;
        person[msg.sender].animal = _animal;
        emit Borrowed(_animal);
    }
    
    function giveBackAnimal() public {
        require(person[msg.sender].isBorrowed == true, "No borrowed pets");
        animalCounts[person[msg.sender].animal] += 1;
        person[msg.sender].animal = Pets.None;
        person[msg.sender].isBorrowed = false;
    }
}