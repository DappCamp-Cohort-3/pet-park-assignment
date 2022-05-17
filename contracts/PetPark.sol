// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark
{
    // -- SCAFFOLDING -------------------------
    enum AnimalType
    {
        NONE

    ,   Fish
    ,   Cat
    ,   Dog
    ,   Rabbit
    ,   Parrot

    ,   BORROWED
    }

    struct Borrower
    {
        address    id;
        uint       age;
        AnimalType animal;
        bool       isFemale;
    }

    // -- STACK  ------------------------------
    address      private owner;
    AnimalType[] private petPark;
    Borrower[]   private borrowers;

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
    external
    {
        // sanity checks
        require (msg.sender == owner, "Not an owner");
        require (uint(_type) > 0, "Invalid animal");

        // populate pet park
        for (uint i = 0; i != _count; ++i) { petPark.push(_type); }

        // notify subscribers
        emit Added(_type, _count);
    }

    function animalCounts(AnimalType _type)
    external
    view
    returns (uint)
    {
        uint count = 0;
        for (uint i = 0; i < petPark.length; ++i) { if (petPark[i] == _type) { ++count; } }

        return count;
    }

    function borrow
    (
        uint       _age
    ,   bool       _isFemale
    ,   AnimalType _type
    )
    external
    {
        // sanity checks
        require (_age > 0, "Invalid Age");
        require (uint(_type) > 0, "Invalid animal type");

        // check pet park contains animal type requested
        bool contains_value = false;

        for (uint i = 0; i < petPark.length; ++i)
        {
            if (petPark[i] == _type)
            {
                contains_value = true;

                break;
            }
        }

        // allow borrowing of existing animals only
        require (contains_value, "Selected animal not available");

        // check if signer already borrowed an animal
        contains_value = false; // reuse previously declared variable

        for (uint i = 0; i < borrowers.length; ++i)
        {
            if (borrowers[i].id == msg.sender)
            {
                // restrict borrower details
                require (borrowers[i].age      == _age     , "Invalid Age");
                require (borrowers[i].isFemale == _isFemale, "Invalid Gender");

                contains_value = true;

                break;
            }
        }

        // restrict borrower to one animal
        require (!contains_value, "Already adopted a pet");

        // allow MEN to borrow only Dog and Fish
        if (!_isFemale)
        {
            require (_type == AnimalType.Dog || _type == AnimalType.Fish, "Invalid animal for men");
        }

        // restrict WOMEN under 40 from borrowing Cat
        if (_isFemale)
        {
            if (_age < 40) { require (_type != AnimalType.Cat, "Invalid animal for women under 40"); }
        }

        // store borrower details, to check on next call
        borrowers.push
        (
            Borrower
            ({
                id       : msg.sender
            ,   age      : _age
            ,   isFemale : _isFemale
            ,   animal   : _type
            })
        );

        // decrease pet count by setting type to "borrowed"
        for (uint i = 0; /* .. */; ++i)
        {
            if (petPark[i] == _type) { petPark[i] = AnimalType.BORROWED; break; }
        }

        // notify subscribers
        emit Borrowed(_type);
    }

    function giveBackAnimal()
    external
    {
        // check signer borrowed the animal and store animal type
        AnimalType animal = AnimalType.NONE;

        bool contains_value = false;
        for (uint i = 0; i < borrowers.length; ++i)
        {
            if (borrowers[i].id == msg.sender)
            {
                contains_value = true;
                animal = borrowers[i].animal;

                break;
            }
        }

        // sanity checks
        require (contains_value, "No borrowed pets");
        require (animal != AnimalType.NONE, "No borrowed pets");

        // reset the type of the first "borrowed" pet to the type borrowed by the signer
        for (uint i = 0; i < petPark.length; ++i) { if (petPark[i] == AnimalType.BORROWED) { petPark[i] = animal; } }
    }
}