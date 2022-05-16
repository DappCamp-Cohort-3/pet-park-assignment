//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PetPark is Ownable {
    // TODO: Don't use storage?
    uint8 constant ANIMAL_TYPE_FISH = 1;
    uint8 constant ANIMAL_TYPE_CAT = 2;
    uint8 constant ANIMAL_TYPE_RABBIT = 4;
    uint8 constant ANIMAL_TYPE_DOG = 3;
    uint8 constant ANIMAL_TYPE_PARROT = 5;
    //enum AnimalType{ NONE, FISH, CAT, DOG, RABBIT, PARROT }

    modifier validRange(
        uint256 val,
        uint256 min,
        uint256 max
    ) {
        require(val >= min && val <= max, "Invalid animal type");
        _;
    }

    mapping(uint8 => uint256) private _animalCounts;
    mapping(address => uint8) private _ownerAnimal;

    event Added(uint8 animalType, uint256 count);
    event Borrowed(uint8 animalType);

    function animalCounts(uint8 _animalType)
        external
        view
        returns (uint256 animalCount)
    {
        return _animalCounts[_animalType];
    }

    function add(uint8 _animalType, uint256 _count)
        external
        onlyOwner
        validRange(_animalType, 1, 5)
    {
        //require(_animalType > 0 && _animalType <= 5, "Invalid animal type");
        _animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(
        uint8 _age,
        uint8 _gender,
        uint8 _animalType
    ) external validRange(_animalType, 1, 5) {
        require(_age > 0, "Invalid Age");
        require(
            _animalCounts[_animalType] > 0,
            "Selected animal not available"
        );
        // require(
        //     !(_gender == 1) && _animalType == ANIMAL_TYPE_CAT,
        //     "Invalid animal for women under 40"
        // );
        require(_ownerAnimal[msg.sender] == 0, "Already adopted a pet");
        // require(
        //     !(_gender == 0) && _animalType == ANIMAL_TYPE_CAT,
        //     "Invalid animal for women under 40"
        // );

        _animalCounts[_animalType] -= 1;
        _ownerAnimal[msg.sender] = _animalType;

        emit Borrowed(_animalType);
        // Men can borrow only `Dog` and `Fish`.
        // Women can borrow every kind, but women aged under 40 are not allowed to borrow a `Cat`.
    }

    function giveBackAnimal() external {
        uint8 animalType = _ownerAnimal[msg.sender];
        require(animalType != 0, "No borrowed pets");
        delete _ownerAnimal[msg.sender];
        _animalCounts[animalType] += 1;
    }
}
