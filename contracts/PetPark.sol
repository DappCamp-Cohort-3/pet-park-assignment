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

    struct Borrow {
        uint8 age;
        uint8 gender;
        uint8 animalType;
    }

    mapping(uint8 => uint256) private _animalCounts;
    mapping(address => Borrow) private _ownerBorrow;

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
        if (_ownerBorrow[msg.sender].animalType > 0) {
            require(_ownerBorrow[msg.sender].age == _age, "Invalid Age");

            require(
                _ownerBorrow[msg.sender].gender == _gender,
                "Invalid Gender"
            );
        }
        require(
            _animalCounts[_animalType] > 0,
            "Selected animal not available"
        );
        require(
            _ownerBorrow[msg.sender].animalType == 0,
            "Already adopted a pet"
        );

        // "Invalid animal for men"

        if (_gender == 1) {
            // Women can borrow every kind, but women aged under 40 are not allowed to borrow a `Cat`.
            require(
                _age >= 40 || _animalType != ANIMAL_TYPE_CAT,
                "Invalid animal for women under 40"
            );
        } else {
            // Men can borrow only `Dog` and `Fish`.
            require(
                _animalType == ANIMAL_TYPE_FISH ||
                    _animalType == ANIMAL_TYPE_DOG,
                "Invalid animal for men"
            );
        }
        // require(
        //     !(_gender == 0) && _animalType == ANIMAL_TYPE_CAT,
        //     "Invalid animal for women under 40"
        // );

        _animalCounts[_animalType] -= 1;
        _ownerBorrow[msg.sender] = Borrow(_age, _gender, _animalType);

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        uint8 animalType = _ownerBorrow[msg.sender].animalType;
        require(animalType != 0, "No borrowed pets");
        delete _ownerBorrow[msg.sender];
        _animalCounts[animalType] += 1;
    }
}
