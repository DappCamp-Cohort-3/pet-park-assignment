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
    }

    // -- STACK  ------------------------------
    address private owner;

    // -- CONSTRUCTORS ------------------------
    constructor()
    {
        owner = msg.sender;
    }
}