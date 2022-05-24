//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    address owner;

    enum AnimalType {None, Fish, Cat, Dog, Rabbit, Parrot}

    struct Person {
        uint age;
        uint gender;
        AnimalType AnimalBorrowed;
        bool hasBorrowed;
        }

    mapping (AnimalType => uint) CountByAnimalType;
    mapping (address => Person) PersonByAddress;
    mapping (address => uint) BorrowedByAddress;

    event Added (AnimalType indexed animalType, uint indexed count);
    event Borrowed (uint indexed animalType);
    event Returned  (uint indexed animalType);

    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner.");
        _;
        }
    
    function add (uint _AnimalType, uint _AnimalCount) public onlyOwner {
        AnimalType ThisAnimalType = AnimalType(_AnimalType);
        require(ThisAnimalType != AnimalType.None,"Invalid animal type");
        CountByAnimalType[ThisAnimalType] += _AnimalCount;

        emit Added(ThisAnimalType, CountByAnimalType[ThisAnimalType]);
    }
    
    function animalCounts(uint _AnimalType) public view returns (uint) {
        AnimalType ThisAnimalType = AnimalType(_AnimalType);
        return CountByAnimalType[ThisAnimalType];
    }

    function borrow (uint _Age, uint _gender, uint _AnimalType) public {
        require(_Age > 0,"Invalid Age");
        require(_AnimalType >0, "Invalid animal type");
        AnimalType ThisAnimalType = AnimalType(_AnimalType);
        require(CountByAnimalType[ThisAnimalType]>0,"Selected animal not available");
        if(PersonByAddress[msg.sender].hasBorrowed) {
            require(PersonByAddress[msg.sender].age == _Age, "Invalid Age");
            require(PersonByAddress[msg.sender].gender == _gender, "Invalid Gender");
        }
        require(BorrowedByAddress[msg.sender]==0, "Already adopted a pet");
        if (BorrowedByAddress[msg.sender]>0) {giveBackAnimal();}
        if (_gender == 0) {
            require(_AnimalType == 3 || _AnimalType == 1, "Invalid animal for men");
        } else if (_gender == 1 && _Age < 40) {
            require(_AnimalType != 2, "Invalid animal for women under 40");
        }
        
        BorrowedByAddress[msg.sender]=_AnimalType;
        PersonByAddress[msg.sender] = Person(_Age,_gender,AnimalType(_AnimalType),true);
        CountByAnimalType[ThisAnimalType]--;
        emit Borrowed(_AnimalType);
        }
    
    function giveBackAnimal() public {
        require(BorrowedByAddress[msg.sender]>0, "No borrowed pets");
        uint AnimalTypeReturned = BorrowedByAddress[msg.sender];
        BorrowedByAddress[msg.sender]=0;
        AnimalType ThisAnimalType = AnimalType(AnimalTypeReturned);
        CountByAnimalType[ThisAnimalType]++;
        emit Returned(AnimalTypeReturned);
    }
}
