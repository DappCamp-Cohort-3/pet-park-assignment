//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
/// @title Assignment-1 Smart Contract for Pet Park
/// @author Srigowri M V
/// @dev The functions implemented pass the tests provided in /test/PetPark.spec.js
contract PetPark {
    //Constants
    enum AnimalType{ None, Fish, Cat, Dog, Rabbit,Parrot}
    enum GenderType {Male, Female}

    //Events
    event Added(AnimalType _animalType, uint count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);

    //State Variable Declaration
    address public owner;
    mapping(AnimalType => uint) public animalCounts;  // Mapping for Animal Type: Count
    mapping(address => AnimalType) public borrowerAnimal; // Mapping for Borrower Address : Animal Type
    mapping(address => uint) public borrowerAge;      // Mapping for BorrowerAddress : Age    
    mapping(address => GenderType) public borrowerGender; // Mapping for BorrowerAddress : Gender

    //Constructor
    constructor(){
        owner = msg.sender;
    }
    //Modifiers
    modifier ownerOnly(){
        //Used while adding new pets to the park
        require(msg.sender == owner, "Not an owner");
        _;
    }
    
    modifier validPet(AnimalType _animalType){
            //Used to ensure only valid animal types are being added or borrowed
            bool valid = (_animalType == AnimalType.Fish || 
                              _animalType == AnimalType.Cat ||
                              _animalType == AnimalType.Dog || 
                              _animalType == AnimalType.Rabbit ||
                              _animalType == AnimalType.Parrot);

            require(valid, "Invalid animal type");
            _;
    }

    //Functions
    function add(AnimalType _animalType, uint count) external ownerOnly() validPet(_animalType){        
        //Increment count of the corresponding pet in the park
        animalCounts[_animalType] += count;
        emit Added(_animalType, count);
    }

    function giveBackAnimal() external {
        //Can give back pets only if borrowed
        require(borrowerAnimal[msg.sender] != AnimalType.None,  "No borrowed pets");        
        AnimalType pet = borrowerAnimal[msg.sender];  //the borrowed pet
        animalCounts[pet] +=1;        //Increment count of the corresponding pet in the park
        borrowerAnimal[msg.sender] = AnimalType.None; //reset the borrowerAnimal
    }

    function borrow(uint age, GenderType _genderType, AnimalType _animalType ) external validPet(_animalType) {

        require (age>0, "Invalid Age");        //Age can not be below 1
        require (animalCounts[_animalType]>0,  "Selected animal not available"); // The selected animal must have count > 0
        
        bool borrowed = (borrowerAnimal[msg.sender] != AnimalType.None);  //has the borrower (msg.sender) adopted a pet already                
        if(borrowed){
            require(borrowerAge[msg.sender] == age,"Invalid Age");  // Existing borrower with incorrect age
            require(borrowerGender[msg.sender] ==_genderType,"Invalid Gender"); //Existing borrower with incorrect gender
            require(false, "Already adopted a pet");  //If the borrower has a pet already
        }   

        if(_genderType == GenderType.Male){
            //Male - valid pets are either dog or fish
            require((_animalType == AnimalType.Dog || _animalType == AnimalType.Fish),"Invalid animal for men");
        }else{
            if (age <40){
                //women under 40 can not have cats as pets
                require (_animalType != AnimalType.Cat, "Invalid animal for women under 40");                
            }                
        }
             
        //enter valid details for the borrower
        borrowerAge[msg.sender] = age;
        borrowerAnimal[msg.sender] = _animalType;        
        borrowerGender[msg.sender] = _genderType;
        animalCounts[_animalType]-=1 ;
        emit Borrowed(_animalType);

    }

}
