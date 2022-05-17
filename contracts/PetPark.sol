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
    public
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
    public
    view
    returns (uint)
    {
        uint count = 0;
        for (uint i = 0; i < petPark.length; ++i) { if (petPark[i] == _type) { ++count; } }

        return count;
    }

    function giveBackAnimal()
    public
    {
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

        require (contains_value, "No borrowed pets");
        require (animal != AnimalType.NONE, "No borrowed pets");

        // reset the type of the first "borrowed" pet
        for (uint i = 0; i < petPark.length; ++i) { if (petPark[i] == AnimalType.BORROWED) { petPark[i] = animal; } }
    }
}