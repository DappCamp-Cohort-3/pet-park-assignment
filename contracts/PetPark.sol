//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    enum Gender {Male, Female}
    enum AnimalType {None, Fish, Cat, Dog, Rabbit, Parrot}

    struct Person {
        uint Age;
        Gender gender;
    }

    mapping (uint => uint) CountByAnimalType;
    mapping (address => Person) PersonByAddress;
    mapping (Person => uint) BorrowedCountByPerson;

    constructor() {
        owner = msg.sender;
    }
    public ThisPerson = PersonByAddress(msg.sender);
    modifier onlyOwner() {
        require(msg.sender == owner, "No animals owned.");
        _;
    }

    function AnimalCount(uint _AnimalType) public view {
        return CountByAnimalType[_AnimalType]
    }

    
    function add (uint _AnimalType, uint _AnimalCount) public onlyOwner {
        ThisAnimalType = AnimalType(_AnimalType);
        require(ThisAnimalType != AnimalType.None,"Invalid animal.");
        CountByAnimalType[ThisAnimalType] += _AnimalCount;

        emit Added(_AnimalType, CountByAnimalType[_AnimalType]);
    }
    
    function borrow (_Age, _gender, _AnimalType) {
        require(BorrowedCountByPerson[ThisPerson]<1, "You can only borrow one animal at a time.");
        if (BorrowedCountByPerson[ThisPerson]>0) {giveBackAnimal();}
        if (_gender == "Male") {
            require(_AnimalType == "Dog" or AnimalType == "Fish", "Men can only borrow Dogs or Fish I guess")
        } else if (_gender == "Female" and _Age < 40) {
            require(_AnimalType != "Cat", "Women under 40 cannot borrow cats")
        }
        BorrowedCountByPerson[ThisPerson]+=1;
        ThisAnimalType = AnimalType(_AnimalType);
        emit Borrowed(ThisAnimalType);
    }
    
    function giveBackAnimal {
        require(BorrowedCountByPerson[ThisPerson]==1, "No animal to give back.");
        BorrowedCountByPerson[ThisPerson]=0;
        ThisAnimalType = AnimalType(_AnimalType);
        emit Returned(ThisAnimalType);
    }
}
