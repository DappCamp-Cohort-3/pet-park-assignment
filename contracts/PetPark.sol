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

    // -- STACK  ------------------------------
    address      private owner;
    AnimalType[] private petPark;

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
}