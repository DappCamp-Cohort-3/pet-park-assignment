//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {
    address _owner;

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

    event Added(AnimalType _animal, uint256 _count);
    event Borrowed(AnimalType _animal);
    mapping(AnimalType => uint256) private pets;
    mapping(address => Borrower) private borrowers;

    struct Borrower {
        Gender _gender;
        uint256 _age;
        AnimalType _animal;
    }

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not an owner");
        _;
    }

    function _validate(uint256 _age, AnimalType _animal) internal view {
        require(_age > 0, "Invalid Age");
        require(
            _animal > AnimalType.None && _animal <= AnimalType.Parrot,
            "Invalid animal type"
        );
        require(pets[_animal] > 0, "Selected animal not available");
    }

    function _borrowable(
        AnimalType _animal,
        Gender _gender,
        uint256 _age
    ) internal pure {
        if (_gender != Gender.Male && _gender != Gender.Female) {
            revert("Invalid gender");
        }

        if (
            _gender == Gender.Male &&
            _animal != AnimalType.Dog &&
            _animal != AnimalType.Fish
        ) {
            revert("Invalid animal for men");
        } else if (
            _gender == Gender.Female && _age < 40 && _animal == AnimalType.Cat
        ) {
            revert("Invalid animal for women under 40");
        }
    }

    function _validateBorrower(
        Borrower memory _borrower,
        Gender _gender,
        uint256 _age
    ) internal pure {
        if (_borrower._age != _age) {
            revert("Invalid Age");
        }
        if (
            (_borrower._gender == Gender.Male ||
                _borrower._gender == Gender.Female) &&
            _borrower._gender != _gender
        ) {
            revert("Invalid Gender");
        }

        if (_hasBorrowed(_borrower)) {
            revert("Already adopted a pet");
        }
    }

    function _hasBorrowed(Borrower memory _borrower)
        internal
        pure
        returns (bool)
    {
        if (
            _borrower._age > 0 &&
            (_borrower._gender == Gender.Female ||
                _borrower._gender == Gender.Male)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function add(AnimalType _animal, uint256 _count) external onlyOwner {
        require(
            _animal > AnimalType.None && _animal <= AnimalType.Parrot,
            "Invalid animal"
        );
        pets[_animal] += _count;
        emit Added(_animal, _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        AnimalType _animal
    ) external {
        _validate(_age, _animal);

        Borrower memory borrower = borrowers[msg.sender];
        if (borrower._age > 0) _validateBorrower(borrower, _gender, _age);
        _borrowable(_animal, _gender, _age);

        borrower = Borrower(_gender, _age, _animal);
        borrowers[msg.sender] = borrower;
        pets[_animal] -= 1;

        emit Borrowed(_animal);
    }

    function animalCounts(AnimalType _animal) external view returns (uint256) {
        return pets[_animal];
    }

    function giveBackAnimal() external {
        Borrower memory borrower = borrowers[msg.sender];
        require(_hasBorrowed(borrower) == true, "No borrowed pets");
        pets[borrower._animal] += 1;
    }
}
