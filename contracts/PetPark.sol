//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    address owner;

    enum Gender {Male, Female}
    enum AnimalType {None, Fish, Cat, Dog, Rabbit, Parrot}

    struct Person {
        uint Age;
        Gender gender;
        }

    mapping (uint => uint) CountByAnimalType;
    mapping (address => Person) PersonByAddress;
    mapping (address => uint) BorrowedByAddress;

    event Added (uint indexed animalType, uint indexed count);
    event Borrowed (uint indexed animalType);
    event Returned  (uint indexed animalType);

    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "No animals owned.");
        _;
        }
    
    function add (uint _AnimalType, uint _AnimalCount) public onlyOwner {
        AnimalType ThisAnimalType = AnimalType(_AnimalType);
        require(ThisAnimalType != AnimalType.None,"Invalid animal.");
        CountByAnimalType[_AnimalType] = _AnimalCount;

        emit Added(_AnimalType, CountByAnimalType[_AnimalType]);
    }
    
    function borrow (uint _Age, uint _gender, uint _AnimalType) public {
        require(BorrowedByAddress[msg.sender]==0, "You can only borrow one animal at a time.");
        if (BorrowedByAddress[msg.sender]>0) {giveBackAnimal();}
        if (_gender == 0) {
            require(_AnimalType == 3 || _AnimalType == 1, "Men can only borrow Dogs or Fish I guess");
        } else if (_gender == 1 && _Age < 40) {
            require(_AnimalType != 2, "Women under 40 cannot borrow cats");
        }
        
        BorrowedByAddress[msg.sender]=_AnimalType;
        emit Borrowed(_AnimalType);
        }
    
    function giveBackAnimal() public {
        require(BorrowedByAddress[msg.sender]>0, "No animal to give back.");
        uint AnimalTypeReturned = BorrowedByAddress[msg.sender];
        BorrowedByAddress[msg.sender]=0;
        CountByAnimalType[AnimalTypeReturned]++;
        emit Returned(AnimalTypeReturned);
    }
}
