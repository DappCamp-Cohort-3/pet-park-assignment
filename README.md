# Pet Park

## Goal

The goal of this exercise is to develop a pet park smart contract. The basic structure of this contract has been laid out for you in `contracts/PetPark.sol`. We can have 5 kinds of animals in our pet park

-   Fish (AnimalType: 1)
-   Cat (AnimalType: 2)
-   Dog (AnimalType: 3)
-   Rabbit (AnimalType: 4)
-   Parrot (AnimalType: 5)

Complete this contract with following specifications for each function

-   add

    -   Takes `Animal Type` and `Count`. Gives shelter to animals in our park.
    -   Only contract owner (address deploying the contract) should have access to this functionality.
    -   Emit event `Added` with parameters `Animal Type` and `Animal Count`.

-   borrow

    -   Takes `Age`, `Gender` and `Animal Type`.
    -   Can borrow only one animal at a time. Use function `giveBackAnimal` to borrow another animal.
    -   Men can borrow only `Dog` and `Fish`.
    -   Women can borrow every kind, but women aged under 40 are not allowed to borrow a `Cat`.
    -   Throw an error if an address has called this function before using other values for `Gender` and `Age`.
    -   Emit event `Borrowed` with parameter `Animal Type`.

-   giveBackAnimal
    -   Throw an error if user hasn't borrowed before.
    -   Emit event `Returned` with parameter `Animal Type`.

## Evaluation

-   Create a fork of this repo
-   Create a new branch with your name. You can use the following command

    ```
    git checkout -b my-name
    ```

-   Install all dependencies
    ```
    npm install
    ```
-   Make changes to the `contract/PetPark.sol` file. The tests in `test/PetPark.spec.js` should run successfully.

-   Run Tests
    ```
    npm test
    ```
-   Create a pull request from your forked repo to main branch of original repo to run the github workflow.

## Note

-   The error strings (mentioned in revert statement) must be same as the ones mentioned in tests.
-   Use modifier where appropriate.
