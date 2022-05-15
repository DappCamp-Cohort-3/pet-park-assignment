//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum AnimalType {None, Fish, Cat, Dog, Rabbit, Parrot}
    enum Gender {Male, Female}
    address owner;

    event Added(AnimalType, uint);
    event Borrowed(AnimalType);

    struct ClientProfile {
        uint age;
        Gender gender;
        address wallet;
    }

    mapping(AnimalType => uint) animalsInFarm;
    mapping(address => AnimalType) renters;
    mapping(address => ClientProfile) clients;

    constructor(){
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint _count) public {
        require(AnimalType.None != _animalType, "Invalid animal");
        require(owner == msg.sender, "Not an owner");
        animalsInFarm[_animalType] += 1;
        emit Added(_animalType, _count);
    }

    function _animalIsAvailable(AnimalType _animalType) internal view returns (bool){
        return animalsInFarm[_animalType] > 0;
    }

    function _isNotRestrictedForMen(AnimalType _animalType) internal pure returns (bool) {
        return (_animalType == AnimalType.Dog) || (_animalType == AnimalType.Fish);
    }

    function _isNotRestrictedForWomen(uint _age, AnimalType _animalType) internal pure returns (bool) {
        return (_animalType == AnimalType.Cat) ? (_age > 40) : true;
    }

    function animalCounts(AnimalType _animalType) public view returns (uint){
        return animalsInFarm[_animalType];
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) public {
        // Check basic restrictions
        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal type");

        ClientProfile memory addressProfile = clients[msg.sender];
        if (addressProfile.wallet == address(0)) {
            // Add new client profile
            clients[msg.sender] = ClientProfile(_age, _gender, msg.sender);
        } else {
            // Check client profile consistency
            require(addressProfile.age == _age, "Invalid Age");
            require(addressProfile.gender == _gender, "Invalid Gender");
        }

        // Check if user already have animal
        AnimalType currentAnimal = renters[msg.sender];
        require(currentAnimal == AnimalType.None, "Already adopted a pet");

        // Check gender restrictions
        if (_gender == Gender.Male) {
            require(_isNotRestrictedForMen(_animalType), "Invalid animal for men");
        }
        else {
            require(_isNotRestrictedForWomen(_age, _animalType), "Invalid animal for women under 40");
        }

        // Check if animal is available
        require(_animalIsAvailable(_animalType), "Selected animal not available");

        // Proceed with borrow
        animalsInFarm[_animalType] -= 1;
        renters[msg.sender] = _animalType;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(renters[msg.sender] != AnimalType.None, "No borrowed pets");
        animalsInFarm[renters[msg.sender]] += 1;
        renters[msg.sender] = AnimalType.None;
    }
}