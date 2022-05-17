//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address public owner;

    struct Borrower{
        bool isBorrowed;
        uint petType;
        uint gender;
        uint age;
    }

    struct Pet{
        bool isAvailable;
        uint number;
    }

    mapping(uint => Pet) pets;
    mapping(address => Borrower ) listBorrower;

    constructor(){
        // Set the transaction sender as the owner of the contract
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    // Add a pet to the pet park
    event Added(uint petType, uint petCount);

    //Emit event when a pet is borrowed
    event Borrowed(uint petType);


    function add(uint _animalType, uint _count) onlyOwner public {
        require(_animalType > 0 && _animalType <= 5 , "Invalid animal");

        // Add the number of pets of the given type to the pets mapping
        pets[_animalType] = Pet({number : _count + pets[_animalType].number, isAvailable: true });

        emit Added(_animalType, pets[_animalType].number);
    }

    function borrow(uint _age, uint _gender, uint _animalType)  public{
        require(_age > 0, "Invalid Age");

        require(_animalType > 0 && _animalType <= 5 , "Invalid animal type");
        
        require(pets[_animalType].isAvailable, "Selected animal not available");

        if(listBorrower[msg.sender].isBorrowed){
            require(listBorrower[msg.sender].age == _age , "Invalid Age");
            require(listBorrower[msg.sender].gender == _gender , "Invalid Gender");
        }

        //Pet is already
        require(listBorrower[msg.sender].petType == 0, "Already adopted a pet");

        if(_gender == 0){
            require(_animalType == 1 || _animalType== 3,"Invalid animal for men");
        }
        else {
            //Women under 40 are not allowed to borrow a Cat
            if (_age < 40){
                require(_animalType != 2, "Invalid animal for women under 40");
            }
        }

        listBorrower[msg.sender] = Borrower(true, _animalType, _gender, _age);

        pets[_animalType].number = pets[_animalType].number - 1; 

        emit Borrowed(_animalType);

    }

    function giveBackAnimal() public {
        require(listBorrower[msg.sender].isBorrowed, "No borrowed pets");

        //Get the type of pet borrowed to increase number
        uint  petType = listBorrower[msg.sender].petType;    

        pets[petType].number = pets[petType].number + 1;

    }

    function animalCounts(uint _animalType) view public returns (uint){
        return pets[_animalType].number;
    }

}