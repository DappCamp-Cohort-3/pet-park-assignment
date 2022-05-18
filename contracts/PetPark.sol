// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark
{
    // -- SCAFFOLDING -------------------------
    enum AnimalType
    {
        NONE
    ,   FISH
    ,   CAT
    ,   DOG
    ,   RABBIT
    ,   PARROT
    }

    struct Borrower
    {
        uint8      age;
        AnimalType animal;
        bool       isFemale;
    }

    // -- STACK  ------------------------------
    address private owner;

    uint8[] private counts = [0,0,0,0,0,0];          // stores number of "instances" of each animal

    mapping (address => Borrower) private borrowers; // stores active borrowers

    // -- EVENTS ------------------------------
    event Added    (AnimalType _type, uint8 _count);
    event Borrowed (AnimalType _type);
    event Returned (AnimalType _type);

    // -- CONSTRUCTORS ------------------------
    constructor()
    {
        owner = msg.sender;
    }

    // -- MODFIERS ----------------------------
    modifier validSender()
    {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAge(uint8 _age)
    {
        require (_age > 0, "Invalid Age");
        _;
    }

    modifier validAnimal(AnimalType _type)
    {
        require (_type != AnimalType.NONE, "Invalid animal");
        _;
    }

    // TODO: should update the test to require the same string as validAnimal modifier
    modifier validAnimal2(AnimalType _type)
    {
        require (_type != AnimalType.NONE, "Invalid animal type");
        _;
    }

    modifier animalAvailable(AnimalType _type)
    {
        require (animalCounts(_type) != 0, "Selected animal not available");
        _;
    }

    modifier validGender(AnimalType _type, uint8 _age, bool _isFemale)
    {
        // restrict WOMEN under 40 from borrowing CAT
        if (_isFemale) { if (_age < 40) { require (_type != AnimalType.CAT, "Invalid animal for women under 40"); } }

        // restrict MEN to borrow only DOG and FISH
        else           { require (_type == AnimalType.DOG || _type == AnimalType.FISH, "Invalid animal for men"); }
        _;
    }

    modifier validBorrower(uint8 _age, bool _isFemale)
    {
        Borrower memory borrower = borrowers[msg.sender];

        if
        (
            borrower.age != 0 ||
            borrower.isFemale != false
        )
        {
            // restrict borrower details
            require (borrower.age      == _age     , "Invalid Age");
            require (borrower.isFemale == _isFemale, "Invalid Gender");

            // restrict borrower to one animal
            revert ("Already adopted a pet");
        }
        _;
    }

    // -- METHODS  ----------------------------
    function animalCounts(AnimalType _type)
    public
    view
    returns (uint)
    {
        return counts[uint8(_type)];
    }

    /*
    Takes AnimalType and Count
    Stores "instances" of animals in map
    Only contract owner can call
    Emits event Added with parameters AnimalType and Count
    */
    function add(AnimalType _type, uint8 _count)
    external
    validSender()
    validAnimal(_type)
    {
        // populate pet park (just store count)
        counts[uint8(_type)] += _count;

        // notify subscribers
        emit Added(_type, _count);
    }

    /*
    Takes Age, Gender and AnimalType
    Borrow only one animal at a time -- call giveBackAnimal before borrowing a new animal
    Men can borrow only Dog and Fish
    Women under 40 are restricted from borrowing a Cat
    Throw an error if an address has called this function before using other values for Gender and Age
    Emits event Borrowed with parameter AnimalType
    */
    function borrow
    (
        uint8      _age
    ,   bool       _isFemale
    ,   AnimalType _type
    )
    validAge(_age)
    validAnimal2(_type)
    animalAvailable(_type)
    validBorrower(_age, _isFemale)
    validGender(_type, _age, _isFemale)
    external
    {
        // store borrower details, to check on next call
        borrowers[msg.sender] =
        Borrower
        ({
            age      : _age
        ,   isFemale : _isFemale
        ,   animal   : _type
        });

        // decrease pet count
        --counts[uint8(_type)];

        // notify subscribers
        emit Borrowed(_type);
    }

    /*
    Throws an error if user is missing from borrowers
    Emits event Returned with parameter AnimalType
    */
    function giveBackAnimal()
    external
    {
        Borrower memory borrower = borrowers[msg.sender];

        // check signer actually borrowed the animal
        require
        (
            borrower.age != 0 ||
            borrower.isFemale != false
        ,   "No borrowed pets"
        );

        // check borrowed animal is valid
        require
        (
            borrower.animal != AnimalType.NONE
        ,   "No borrowed pets"
        );

        // increase pet count
        ++counts[uint8(borrower.animal)];

        // notify subscribers
        emit Returned(borrower.animal);

        // remove borrower from storage
        delete borrowers[msg.sender];
    }
}