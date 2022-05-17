//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum Animal {None, Fish, Cat, Dog, Rabbit, Parrot}
    enum Gender {Male, Female}

    struct borrowerInfo {
        int256 age;
        Gender gender;
    }

    event Added(Animal _animal, int256 _count);
    event Borrowed(Animal _animal);
    event Returned(Animal _animal);

    address public _owner;
    mapping(address => bool) public _borrowed;
    mapping(Animal => int256) public _pet_count;
    mapping(address => Animal) public _address_to_animal;
    mapping(address => borrowerInfo) public _user_profile;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Not an owner");
        _;
    }

    function add(Animal _animal, int256 _count) public onlyOwner {
        /// @notice Adds the animal to the park and emits that the animal is added, if given a valid input
        /// @param _animal animal
        /// @param _count count of the animal that needs to be added to the park
        require(_animal != Animal.None, "Invalid animal");
        _pet_count[_animal] += _count;
        emit Added(_animal, _count);
    }

    function borrow(int256 _age, Gender _gender, Animal _animal) public {

        // Check to make sure the caller information remains consistent
        if (_borrowed[msg.sender] == false) {
            _user_profile[msg.sender] = borrowerInfo({age: _age, gender: _gender});
        }
        else if (_borrowed[msg.sender] == true) {
            require(_user_profile[msg.sender].age == _age, "Invalid Age");
            require(_user_profile[msg.sender].gender == _gender, "Invalid Gender");
        }

        require(_age > 0, "Invalid Age");
        require(_animal != Animal.None, "Invalid animal type");
        require(_borrowed[msg.sender] == false, "Already adopted a pet");
        require(_pet_count[_animal] > 0, "Selected animal not available");

        if (_gender == Gender.Male && (_animal == Animal.Cat || _animal == Animal.Rabbit || _animal == Animal.Parrot)) {
            revert("Invalid animal for men");
        }
        else if (_gender == Gender.Female && _age < 40 && _animal == Animal.Cat) {
            revert("Invalid animal for women under 40");
        }

        _borrowed[msg.sender] = true;
        _address_to_animal[msg.sender] = _animal;
        _pet_count[_animal] -= 1 ;
        emit Borrowed(_animal);
    }

    function animalCounts(Animal _animal) public view returns (int256) {
        /// @notice Returns the number of a given _animal in the park
        return _pet_count[_animal];
    }

    function giveBackAnimal() public {
        require(_borrowed[msg.sender] == true, "No borrowed pets");
        Animal animal = _address_to_animal[msg.sender];
        _pet_count[animal] += 1;
        _borrowed[msg.sender] == false;
        emit Returned(animal);
        delete _address_to_animal[msg.sender];
    }


}