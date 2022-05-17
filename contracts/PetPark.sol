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
        uint       age;
        AnimalType animal;
        bool       isFemale;
    }

    // -- STACK  ------------------------------
    address private owner;

    mapping (AnimalType => uint)     private counts;    // stores number of "instances" of each animal
    mapping (address    => Borrower) private borrowers; // stores active borrowers

    // -- EVENTS ------------------------------
    event Added    (AnimalType _type, uint _count);
    event Borrowed (AnimalType _type);
    event Returned (AnimalType _type);

    // -- CONSTRUCTORS ------------------------
    constructor()
    {
        owner = msg.sender;
    }

    // -- METHODS  ----------------------------
    function animalCounts(AnimalType _type)
    public
    view
    returns (uint)
    {
        return counts[_type];
    }

    /*
    Takes AnimalType and Count
    Stores "instances" of animals in map
    Only contract owner can call
    Emits event Added with parameters AnimalType and Count
    */
    function add(AnimalType _type, uint _count)
    public
    {
        // sanity checks
        require (msg.sender == owner     , "Not an owner");
        require (_type != AnimalType.NONE, "Invalid animal");

        // populate pet park (just store count)
        counts[_type] += _count;

        // notify subscribers
        emit Added(_type, _count);
    }

    /*
    Takes AnimalType
    Restricts borrowing choices of males to Dogs and Fishes
    */
    function _revertIfMaleBorrowRestricted(AnimalType _type)
    internal
    pure
    {
        if (_type != AnimalType.DOG && _type != AnimalType.FISH) { revert("Invalid animal for men"); }
    }

    /*
    Takes AnimalType
    Restricts borrowing of Cats by females under 40
    */
    function _revertIfFemaleBorrowRestricted(AnimalType _type, uint _age)
    internal
    pure
    {
        if (_age < 40 && _type == AnimalType.CAT) { revert("Invalid animal for women under 40"); }
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
        uint       _age
    ,   bool       _isFemale
    ,   AnimalType _type
    )
    public
    {
        // sanity checks
        require (_age > 0                , "Invalid Age");
        require (_type != AnimalType.NONE, "Invalid animal type");
        require (animalCounts(_type) != 0, "Selected animal not available");

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

        // restrict WOMEN under 40 from borrowing CAT
        if (_isFemale) { _revertIfFemaleBorrowRestricted(_type, _age); }

        // restrict MEN to borrow only DOG and FISH
        else           { _revertIfMaleBorrowRestricted(_type); }

        // store borrower details, to check on next call
        borrowers[msg.sender] =
        Borrower
        ({
            age      : _age
        ,   isFemale : _isFemale
        ,   animal   : _type
        });

        // decrease pet count
        --counts[_type];

        // notify subscribers
        emit Borrowed(_type);
    }

    /*
    Throws an error if user is missing from borrowers
    Emits event Returned with parameter AnimalType
    */
    function giveBackAnimal()
    public
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
        ++counts[borrower.animal];

        // notify subscribers
        emit Returned(borrower.animal);

        // remove borrower from storage
        delete borrowers[msg.sender];
    }
}