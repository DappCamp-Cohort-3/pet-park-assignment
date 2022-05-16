//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum AnimalType{None,Fish,Cat,Dog,Rabbit,Parrot}
    struct PetOwnerDetails{
        AnimalType pet;
        uint age;
        Gender sex;
    }
    mapping(address => PetOwnerDetails)petOwner;
    mapping(AnimalType => uint)public animalCounts;

    enum Gender{Male,Female}
    address owner;
    event Added(AnimalType addedAnimal,uint count);
    event Borrowed(AnimalType borrowedAnimal);
    constructor(){
        owner = msg.sender;
    }
    function add(AnimalType _animal, uint _count)public {
        require(owner == msg.sender,"Not an owner");
        require(_animal != AnimalType.None,"Invalid animal");
        animalCounts[_animal]+=_count;
        emit Added(_animal, _count);
    }

    function borrow(uint age,Gender _gender, AnimalType _animal) public{
        require(age !=0,"Invalid Age");
        require(_animal != AnimalType.None,"Invalid animal type");
        require(animalCounts[_animal] !=0,"Selected animal not available");
        if(petOwner[msg.sender].age !=0){
        require(petOwner[msg.sender].age == age,"Invalid Age");
        require(petOwner[msg.sender].sex == _gender,"Invalid Gender");
    
        }
        require(petOwner[msg.sender].pet== AnimalType.None,"Already adopted a pet");
        if(_gender == Gender.Male){
         require(_animal == AnimalType.Fish || _animal == AnimalType.Dog,"Invalid animal for men");  
        }
        else{
        require(age <40 && _animal != AnimalType.Cat,"Invalid animal for women under 40");
        }
        PetOwnerDetails memory user=PetOwnerDetails({pet:_animal,age:age,sex:_gender});
        petOwner[msg.sender] =user;
        
        emit Borrowed(_animal);
        animalCounts[_animal]-=1;



    }
    function giveBackAnimal()public{
        require(petOwner[msg.sender].pet != AnimalType.None,"No borrowed pets");
        animalCounts[petOwner[msg.sender].pet]+=1;

    }

}