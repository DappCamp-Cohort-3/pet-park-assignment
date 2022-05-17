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

    // -- CONSTRUCTORS ------------------------
    constructor()
    {
        owner = msg.sender;
    }

    // -- METHODS  ----------------------------
    function add(AnimalType _type, uint _count)
    public
    {
        // sanity checks
        require (msg.sender == owner, "Not an owner");
        require (uint(_type) > 0    , "Invalid animal");

        // populate pet park (just store count)
        counts[_type] += _count;

        // notify subscribers
        emit Added(_type, _count);
    }

    function animalCounts(AnimalType _type)
    public
    view
    returns (uint)
    {
        return counts[_type];
    }

    function borrow
    (
        uint       _age
    ,   bool       _isFemale
    ,   AnimalType _type
    )
    public
    {
        // sanity checks
        require (_age > 0          , "Invalid Age");
        require (uint(_type) > 0   , "Invalid animal type");
        require (counts[_type] != 0, "Selected animal not available");

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

        // allow MEN to borrow only DOG and FISH
        if (!_isFemale && _type != AnimalType.DOG && _type != AnimalType.FISH) { revert("Invalid animal for men"); }

        // restrict WOMEN under 40 from borrowing CAT
        if (_isFemale && _age < 40 && _type == AnimalType.CAT) { revert("Invalid animal for women under 40"); }

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
    }
}