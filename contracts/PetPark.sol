//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);
    
    enum AnimalType{ None, Fish, Cat, Dog, Rabbit, Parrot }
    enum Gender{ Male, Female }

    struct Borrower {
        uint age;
        Gender gender;
        AnimalType animal;
    }

    mapping(address => Borrower) private _borrowers;
    mapping(AnimalType => uint) private _shelter;

    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function add(AnimalType animalType, uint count) public onlyOwner {
        require(existingAnimal(animalType), 'Invalid animal');

        _shelter[animalType] += count;

        emit Added(animalType, count);
    }

    function borrow(uint age, Gender gender, AnimalType animalType) public {
        require(age > 0, 'Invalid Age');

        Borrower storage borrower = _borrowers[msg.sender];

        if (borrower.age > 0) {
            require(borrower.age == age, 'Invalid Age');
            require(borrower.gender == gender, 'Invalid Gender');
        }

        require(_borrowers[msg.sender].animal == AnimalType.None, 'Already adopted a pet');
        
        require(uint8(animalType) > 0 && uint8(animalType) < 6, 'Invalid animal type');
        require(_shelter[animalType] > 0, 'Selected animal not available');

        if (gender == Gender.Male && animalType != AnimalType.Dog && animalType != AnimalType.Fish) {
            revert('Invalid animal for men');
        }

        if (gender == Gender.Female && age < 40 && animalType == AnimalType.Cat) {
            revert('Invalid animal for women under 40');
        }

        borrower.age = age;
        borrower.gender = gender;
        borrower.animal = animalType;

        _shelter[animalType]--;

        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        Borrower storage borrower = _borrowers[msg.sender];

        require(borrower.animal != AnimalType.None, 'No borrowed pets');

        AnimalType animalType = borrower.animal;

        borrower.animal = AnimalType.None;
        _shelter[animalType]++;

        emit Returned(animalType);
    }

    function animalCounts(AnimalType animalType) public view returns(uint) {
        return _shelter[animalType];
    }

    function existingAnimal(AnimalType animalType) private pure returns(bool) {
        return uint8(animalType) > 0 && uint8(animalType) < 6;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, 'Not an owner');
        _;
    }
}