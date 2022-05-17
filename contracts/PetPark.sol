//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

enum animalType {None, Fish, Cat, Dog, Rabbit, Parrot}
enum gender {Male, Female}
address immutable owner;

struct member{
    gender _gender;
    uint age;
    address memberAddress;
}
mapping (animalType => uint) numberOfAnimals;
mapping (address => animalType) borrowed;
mapping (address => member) members;

event Added (animalType, uint);
event Borrowed (animalType);
event Returned (animalType);

constructor (){
  owner = msg.sender;
}

function add (animalType _animalType, uint _count) public{
    require (owner == msg.sender, "Not an owner");
    require ( _animalType != animalType.None, "Invalid animal");
    numberOfAnimals[_animalType] += _count;
    emit Added(_animalType, numberOfAnimals[_animalType]);
}

function animalCounts(animalType _animalType) public view returns (uint) {
  return numberOfAnimals[_animalType];
}


function borrow (uint _age, gender _gender, animalType _animalType) public{
    //basic checks
    require ( _age> 0, "Invalid Age");
    require (_animalType != animalType.None, "Invalid animal type");
    require (numberOfAnimals[_animalType] > 0, "Selected animal not available");


    // borrower age and gender consistency check
    member memory newMemberAdress = members [msg.sender];
    if (newMemberAdress.memberAddress == address(0)){
        // add a member
        members[msg.sender] = member(_gender, _age, msg.sender);
    }
    else{
        // check client information
        require (newMemberAdress.age == _age, "Invalid Age");
        require (newMemberAdress._gender == _gender, "Invalid Gender");
    }

    // check if the address already has a animal
    animalType  _currentpet = borrowed[msg.sender];
    require (_currentpet == animalType.None, "Already adopted a pet");

    // borrow logic with conditions defined in Problem statement
    if(_gender == gender.Male){
        if (_animalType == animalType.Dog || _animalType == animalType.Fish){
            borrowed[msg.sender] = _animalType;
            numberOfAnimals [_animalType] -= 1;
            emit Borrowed(_animalType);
        }
        else{
          revert("Invalid animal for men");
        }
    }

    else if (_gender == gender.Female){
        if (_animalType == animalType.Cat){
            if (_age >= 40){
                borrowed[msg.sender] = _animalType;
                numberOfAnimals [_animalType] -= 1;
                emit Borrowed(_animalType);
            }
            else {
                revert("Invalid animal for women under 40");
            }
        }
        else{
                borrowed[msg.sender] = _animalType;
                numberOfAnimals [_animalType] -= 1;
                emit Borrowed(_animalType);
        }
    }
}



function giveBackAnimal () public{
    animalType  _currentpet = borrowed[msg.sender];
    require (_currentpet != animalType.None, "No borrowed pets");
    numberOfAnimals [_currentpet] += 1;
    emit Returned(_currentpet);
    borrowed[msg.sender] = animalType.None;
}

}
