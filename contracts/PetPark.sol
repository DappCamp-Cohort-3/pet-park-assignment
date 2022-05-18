//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum AnimalType {None, Fish, Cat, Dog, Rabbit, Parrot}
    enum Gender {Male, Female}
    struct PetOwner {
        address owner;
        uint age;
        Gender gender;
        AnimalType animalType;
    }

    address public owner;
    mapping (AnimalType=>uint) public animalCounts;
    mapping (address=>PetOwner) public borrowed;

    // Events
    event Added(AnimalType indexed animalType, uint count);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimal(AnimalType _type) {
        require(_type!=AnimalType.None, "Invalid animal");
        _;
    }

    function add(AnimalType _type, uint _count) public onlyOwner() validAnimal(_type) {
        animalCounts[_type] += _count;
        emit Added(_type, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _type) public {
        PetOwner memory petOwner = borrowed[msg.sender];
        require(_age>0 && (petOwner.owner==address(0) || petOwner.age==_age), "Invalid Age");
        require(petOwner.owner==address(0) || petOwner.gender==_gender, "Invalid Gender");
        require(_type!=AnimalType.None, "Invalid animal type");
        require(borrowed[msg.sender].owner==address(0) || borrowed[msg.sender].animalType==AnimalType.None, "Already adopted a pet");
        if (_gender == Gender.Male) {
            require(_type==AnimalType.Dog || _type== AnimalType.Fish, "Invalid animal for men");
        } else if (_gender==Gender.Female && _age<40) {
            require(_type!=AnimalType.Cat, "Invalid animal for women under 40");
        }
        require(animalCounts[_type]>0, "Selected animal not available");
        animalCounts[_type] -= 1;
        borrowed[msg.sender] = PetOwner(msg.sender, _age, _gender, _type);
        emit Borrowed(_type);
    }

    function giveBackAnimal() public {
        PetOwner memory petOwner =  borrowed[msg.sender];
        require(petOwner.owner!=address(0) && petOwner.animalType!=AnimalType.None, "No borrowed pets");
        animalCounts[petOwner.animalType] += 1;
        petOwner.animalType = AnimalType.None;
        borrowed[msg.sender] = petOwner;
        emit Returned(petOwner.animalType);
    }
}