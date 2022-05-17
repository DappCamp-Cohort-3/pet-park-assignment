//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";


contract PetPark {
    /* variables */
    address owner;

    struct Person {
        uint age;
        uint gender;
        uint animal_type;
    }

    Person[] public persons;
    mapping (address => Person) public addressToPerson;
    mapping (uint => uint) public animals;

    /* modifiers */
    modifier onlyOwner {
        require(msg.sender == owner, "Not an owner" );
        _;
    }

    modifier isValidAnimal(uint _animal_type) {
        require(_animal_type > 0 && _animal_type < 6, "Invalid animal");
        _;
    }

    /* constructor */
    constructor() {
        owner = msg.sender;
    }

    /* events */
    event Added(uint _animal_type, uint _animal_count);
    event Borrowed(uint _animal_type);

    /* functions */

    function add(uint _animal_type, uint _animal_count) public onlyOwner isValidAnimal(_animal_type) {
        animals[_animal_type] += _animal_count;

        emit Added(_animal_type, _animal_count);
    }

    function borrow(uint _age, uint _gender, uint _animal_type) public isValidAnimal(_animal_type) {
        Person storage person = addressToPerson[msg.sender];

        require(_age > 0, "Invalid Age");

        // could use validPerson bool in Person struct instead of person.animal_type != 0
        if (person.animal_type != 0 && person.age != _age) {
            revert("Invalid Age");
        } else if (person.animal_type != 0 && person.gender != _gender) {
            revert("Invalid Gender");
        } else if (person.animal_type != 0) {
            revert("Already adopted a pet");
        }

        require(animals[_animal_type] > 0, "Selected animal not available");

        if (_gender == 0 && _animal_type != 1 && _animal_type != 3) {
            revert("Invalid animal for men");
        } else if (_gender == 1 && _age < 40 && _animal_type == 2) {
            revert("Invalid animal for women under 40");
        }

        // todo: figure out why we can't use Person(struct_var1, struct_var2...) method
        person.age = _age;
        person.gender = _gender;
        person.animal_type = _animal_type;
        animals[_animal_type]--;

        emit Borrowed(_animal_type);
    }


    function giveBackAnimal() public {
        Person storage person = addressToPerson[msg.sender];

        require(person.animal_type > 0, "No borrowed pets");

        animals[person.animal_type]++;
        person.animal_type = 0;
    }

    /* helper functions */

    function animalCounts(uint _animal_type) public view isValidAnimal(_animal_type) returns (uint) {
        return animals[_animal_type];
    }
}