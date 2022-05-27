//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    modifier isValidAnimal(AnimalType _atype) {
        require(_atype > AnimalType.INVALID && _atype <= AnimalType.PARROT, "Invalid animal type");
        _;
    }

    enum AnimalType {
        INVALID,
        FISH,
        CAT,
        DOG,
        RABBIT,
        PARROT
    }

    enum Gender {
        MALE,
        FEMALE
    }

    struct Borrower {
        uint8 age;
        Gender gender;
        AnimalType animalType;
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => Borrower) addressToBorrower;

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    function add(AnimalType _atype, uint _count) external onlyOwner isValidAnimal(_atype) {
        animalCounts[_atype] += _count;
        emit Added(_atype, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _atype) external isValidAnimal(_atype) {
        require(_age > 0, "Invalid Age");
        require(animalCounts[_atype] > 0, "Selected animal not available");

        Borrower memory borrower = addressToBorrower[msg.sender];

        if(borrower.age > 0) {
            require(borrower.age == _age, "Invalid Age");
            require(borrower.gender == _gender, "Invalid Gender");
        }

        require(borrower.animalType == AnimalType.INVALID, "Already adopted a pet");

        if (_gender == Gender.MALE) {
            require(_atype == AnimalType.FISH || _atype == AnimalType.DOG, "Invalid animal for men");
        }

        if(_gender == Gender.FEMALE && _atype == AnimalType.CAT) {
            require(_age >= 40, "Invalid animal for women under 40");
        }

        addressToBorrower[msg.sender] = Borrower(_age, _gender, _atype);
        animalCounts[_atype] -= 1;
        emit Borrowed(_atype);
    }

    function giveBackAnimal() external {
        require(addressToBorrower[msg.sender].animalType != AnimalType.INVALID, "No borrowed pets");

        Borrower memory borrower = addressToBorrower[msg.sender];
        animalCounts[borrower.animalType] += 1;
        borrower.animalType = AnimalType.INVALID; 
        emit Returned(borrower.animalType);
    }
}