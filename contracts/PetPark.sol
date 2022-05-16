//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Borrower {
        uint age;
        uint gender;
        uint animalTypeIdx;
    }

    mapping(uint => uint) animalCountMap;
    mapping(address => Borrower) borrowers;

    address private owner;

    event Added(uint, uint);
    event Borrowed(uint);

    constructor() {
        owner = msg.sender;
    }

    function add(uint animalTypeIdx, uint count) external {
        require(msg.sender == owner, "Not an owner");
        require(animalTypeIdx > 0 && animalTypeIdx < 6, "Invalid animal");
        animalCountMap[animalTypeIdx] += count;
        emit Added(animalTypeIdx, count);
    }

    function borrow(
        uint age,
        uint gender,
        uint animalTypeIdx
    ) external {
        require(age > 0, "Invalid Age");
        require(animalTypeIdx != 0, "Invalid animal type");
        require(
            animalCountMap[animalTypeIdx] > 0,
            "Selected animal not available"
        );

        Borrower storage borrower = borrowers[msg.sender];
        if (borrower.age > 0) {
            if (borrower.age != age) {
                revert("Invalid Age");
            }
            if (borrower.gender != gender) {
                revert("Invalid Gender");
            }
            revert("Already adopted a pet");
        }

        if (gender == 0) {
            require(
                animalTypeIdx == 3 || animalTypeIdx == 1,
                "Invalid animal for men"
            );
        } else if (gender == 1) {
            require(
                !(age < 40 && animalTypeIdx == 2),
                "Invalid animal for women under 40"
            );
        }

        animalCountMap[animalTypeIdx] -= 1;

        borrowers[msg.sender] = Borrower({
            age: age,
            gender: gender,
            animalTypeIdx: animalTypeIdx
        });
        emit Borrowed(animalTypeIdx);
    }

    function giveBackAnimal() public {
        Borrower storage borrower_ = borrowers[msg.sender];
        require(borrower_.age > 0, "No borrowed pets");

        Borrower storage borrower = borrowers[msg.sender];
        animalCountMap[borrower.animalTypeIdx] += 1;
    }

    function animalCounts(uint8 animalTypeIdx) external view returns (uint256) {
        return animalCountMap[animalTypeIdx];
    }
}
