//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
  
  struct Person {
    uint gender;
    uint age;
    uint borrowedAnimal;
  }
  
  address owner;

  mapping (uint => uint) animalToCount;
  mapping (address => Person) addressToPerson;

  event Added(uint animalType, uint animalCount);
  event Borrowed(uint animalType);
  event Returned(uint animalType);
  
  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner, "Not an owner");
    _;
  }

  function animalCounts(uint _animalType) view public returns (uint) {
    return animalToCount[_animalType];
  }

  function add(uint _animalType, uint _count) public onlyOwner {
    require(_animalType >= 1 && _animalType <= 5, "Invalid animal");
    animalToCount[_animalType] = animalToCount[_animalType] + _count;
    emit Added(_animalType, _count);
  }

  function borrow(uint _age, uint _gender, uint _animalType) public {
    require(_age != 0, "Invalid Age");
    
    require(_animalType >= 1 && _animalType <= 5, "Invalid animal type");
    
    require(animalToCount[_animalType] > 0, "Selected animal not available");
    
    Person memory person = addressToPerson[msg.sender];
    
    // only do this if person exists already
    if (person.age != 0) {
      require(_age == person.age, "Invalid Age");
      require(_gender == person.gender, "Invalid Gender");
    }

    require(person.borrowedAnimal == 0, "Already adopted a pet");
    
    if (_gender == 0) {
      require(_animalType == 1 || _animalType == 3, "Invalid animal for men");
    }
    
    if (_gender == 1 && _age < 40) {
      require(_animalType != 2, "Invalid animal for women under 40");
    }

    addressToPerson[msg.sender] = Person(_gender, _age, _animalType);
    animalToCount[_animalType]--;

    emit Borrowed(_animalType);
  }

  function giveBackAnimal() public {
    require(addressToPerson[msg.sender].borrowedAnimal != 0, "No borrowed pets");
    
    animalToCount[addressToPerson[msg.sender].borrowedAnimal]++;
    
    emit Returned(addressToPerson[msg.sender].borrowedAnimal);
    
    // remove animal from user
    addressToPerson[msg.sender].borrowedAnimal = 0;
  }
}
