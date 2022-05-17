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
        bool isBorrowing;
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

    mapping(AnimalType => uint) animalCount;
    mapping(address => Borrower) public borrowers;

    constructor(){
        owner = msg.sender;

    }

    function add(AnimalType _animalType, uint count) public onlyOwner {
        require(uint(_animalType) > 0, "Invalid animal");
        animalCount[_animalType] = animalCount[_animalType] + count;
        emit Added(_animalType, count);
    }

    function animalCounts(AnimalType _animalType) public view returns (uint) {
        return animalCount[_animalType];
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) public {
        require(_age > 0, "Invalid Age");
        require(uint(_animalType) > 0, "Invalid animal type");
        require(animalCount[_animalType] > 0, "Selected animal not available");
        if (borrowers[msg.sender].isBorrowing == true && _age != borrowers[msg.sender].age) {
            revert("Invalid Age");
        }
        if (borrowers[msg.sender].isBorrowing == true && _gender != borrowers[msg.sender].gender) {
            revert("Invalid Gender");
        }
        require(borrowers[msg.sender].isBorrowing == false, "Already adopted a pet");
        if (_gender == Gender.Male && (_animalType != AnimalType.Fish && _animalType != AnimalType.Dog)){
            revert("Invalid animal for men");
        }
        if(_gender == Gender.Female && _animalType == AnimalType.Cat && _age < 40){
            revert("Invalid animal for women under 40");
        }
        Borrower memory currentBorrower = Borrower(_animalType, true, _gender, _age);
        borrowers[msg.sender] = currentBorrower;
        animalCount[_animalType] = animalCount[_animalType] - 1;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        Borrower memory currentBorrower = borrowers[msg.sender];
        // require(borrowers[msg.sender].hasBorrowed == true, "No borrowed pets");
        require(currentBorrower.isBorrowing == true, "No borrowed pets");
        require(currentBorrower.animal != AnimalType.NONE, "No borrowed pets");
        animalCount[currentBorrower.animal] = animalCount[currentBorrower.animal] + 1;
        borrowers[msg.sender].isBorrowing = false;
        emit Returned(borrowers[msg.sender].animal);

    }
}
