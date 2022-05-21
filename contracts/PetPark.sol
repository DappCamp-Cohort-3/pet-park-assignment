// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    address owner; 

    enum AnimalType {
        NONE,
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
        Gender gender;
        uint age;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner");
        _;
    }
   
    event Added(AnimalType _animalType, uint count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => Borrower) public borrowers;

    constructor(){
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint count) public onlyOwner {
        require(uint(_animalType) > 0, "Invalid animal");
        animalCounts[_animalType] = animalCounts[_animalType] + count;
        emit Added(_animalType, count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) external {
        Borrower memory currentUser = borrowers[msg.sender];
        require(_age > 0, "Invalid Age");
        require(uint(_animalType) > 0, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        if (currentUser.animal != AnimalType.NONE && _age != currentUser.age) {
            revert("Invalid Age");
        }
        if (currentUser.animal != AnimalType.NONE && _gender != currentUser.gender) {
            revert("Invalid Gender");
        }
        require(currentUser.animal == AnimalType.NONE, "Already adopted a pet");
        if (_gender == Gender.Male && (_animalType != AnimalType.Fish && _animalType != AnimalType.Dog)){
            revert("Invalid animal for men");
        }
        if(_gender == Gender.Female && _animalType == AnimalType.Cat && _age < 40){
            revert("Invalid animal for women under 40");
        }
        Borrower memory currentBorrower = Borrower(_animalType, _gender, _age);
        borrowers[msg.sender] = currentBorrower;
        animalCounts[_animalType] = animalCounts[_animalType] - 1;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        Borrower memory currentBorrower = borrowers[msg.sender];
        require(currentBorrower.animal != AnimalType.NONE, "No borrowed pets");
        // require(currentBorrower.animal != AnimalType.NONE, "No borrowed pets");
        animalCounts[currentBorrower.animal] = animalCounts[currentBorrower.animal] + 1;
        emit Returned(currentBorrower.animal);
        currentBorrower.animal = AnimalType.NONE;

    }
}
