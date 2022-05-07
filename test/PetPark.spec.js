const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PetPark", function () {
	let petPark;
	let owner;
	let account1;

	const AnimalType = {
		None: 0,
		Fish: 1,
		Cat: 2,
		Dog: 3,
		Rabbit: 4,
		Parrot: 5,
	};

	const Gender = {
		Male: 0,
		Female: 1,
	};

	beforeEach("deploy contract", async () => {
		const accounts = await ethers.getSigners();

		owner = accounts[0];
		account1 = accounts[1];

		const PetPark = await ethers.getContractFactory("PetPark");
		petPark = await PetPark.deploy();
		await petPark.deployed();
	});

	describe("add", function () {
		it("should revert when not called by an owner", async function () {
			await expect(
				petPark.connect(account1).add(AnimalType.Fish, 5)
			).to.be.revertedWith("Not an owner");
		});

		it("should revert when invalid animal is provided", async function () {
			await expect(
				petPark.connect(owner).add(AnimalType.None, 5)
			).to.be.revertedWith("Invalid animal");
		});

		it("should emit added event when pet is added", async function () {
			await expect(petPark.connect(owner).add(AnimalType.Fish, 5))
				.to.emit(petPark, "Added")
				.withArgs(AnimalType.Fish, 5);
		});
	});

	describe("borrow", function () {
		it("should revert when age is 0", async function () {
			await expect(
				petPark.borrow(0, Gender.Male, AnimalType.Fish)
			).to.be.revertedWith("Invalid Age");
		});

		it("should revert when animal is not available in park", async function () {
			await expect(
				petPark.borrow(24, Gender.Male, AnimalType.Fish)
			).to.be.revertedWith("Selected animal not available");
		});

		it("should revert when animal type is invalid", async function () {
			await expect(
				petPark.borrow(24, Gender.Male, AnimalType.None)
			).to.be.revertedWith("Invalid animal type");
		});

		it("should revert when men attempt to borrow animals other than fish and dog", async function () {
			await petPark.add(AnimalType.Cat, 5);
			await petPark.add(AnimalType.Rabbit, 5);
			await petPark.add(AnimalType.Parrot, 5);

			await expect(
				petPark.borrow(24, Gender.Male, AnimalType.Cat)
			).to.be.revertedWith("Invalid animal for men");

			await expect(
				petPark.borrow(24, Gender.Male, AnimalType.Rabbit)
			).to.be.revertedWith("Invalid animal for men");

			await expect(
				petPark.borrow(24, Gender.Male, AnimalType.Parrot)
			).to.be.revertedWith("Invalid animal for men");
		});

		it("should revert when women under 40 attempt to borrow cat", async function () {
			await petPark.add(AnimalType.Cat, 5);

			await expect(
				petPark.borrow(24, Gender.Female, AnimalType.Cat)
			).to.be.revertedWith("Invalid animal for women under 40");
		});

		it("should revert when pet is already borrowed", async function () {
			await petPark.add(AnimalType.Fish, 5);
			await petPark.add(AnimalType.Cat, 5);

			await petPark
				.connect(account1)
				.borrow(24, Gender.Male, AnimalType.Fish);

			await expect(
				petPark
					.connect(account1)
					.borrow(24, Gender.Male, AnimalType.Fish)
			).to.be.revertedWith("Already adopted a pet");

			await expect(
				petPark
					.connect(account1)
					.borrow(24, Gender.Male, AnimalType.Cat)
			).to.be.revertedWith("Already adopted a pet");
		});

		it("should revert when address details do not match from previous calls", async function () {
			await petPark.add(AnimalType.Fish, 5);

			await petPark
				.connect(account1)
				.borrow(24, Gender.Male, AnimalType.Fish);

			await expect(
				petPark
					.connect(account1)
					.borrow(23, Gender.Male, AnimalType.Fish)
			).to.be.revertedWith("Invalid Age");

			await expect(
				petPark
					.connect(account1)
					.borrow(24, Gender.Female, AnimalType.Fish)
			).to.be.revertedWith("Invalid Gender");
		});

		it("should emit borrowed event when valid details are provided", async function () {
			await petPark.add(AnimalType.Fish, 5);

			await expect(
				petPark
					.connect(account1)
					.borrow(24, Gender.Male, AnimalType.Fish)
			)
				.to.emit(petPark, "Borrowed")
				.withArgs(AnimalType.Fish);
		});

		it("should decrease pet count when valid details are provided", async function () {
			await petPark.add(AnimalType.Fish, 5);

			let originalPetCount = await petPark.animalCounts(AnimalType.Fish);
			originalPetCount = originalPetCount.toNumber();
			await petPark
				.connect(account1)
				.borrow(24, Gender.Male, AnimalType.Fish);

			let reducedPetCount = await petPark.animalCounts(AnimalType.Fish);
			reducedPetCount = reducedPetCount.toNumber();

			expect(originalPetCount).to.equal(reducedPetCount + 1);
		});
	});

	describe("giveBackAnimal", function () {
		it("should revert when caller has never borrowed a pet", async function () {
			await expect(
				petPark.connect(account1).giveBackAnimal()
			).to.be.revertedWith("No borrowed pets");
		});

		it("should increment the pet count of that animal by 1", async function () {
			await petPark.add(AnimalType.Fish, 5);

			await petPark
				.connect(account1)
				.borrow(24, Gender.Male, AnimalType.Fish);
			let reducedPetCount = await petPark.animalCounts(AnimalType.Fish);
			reducedPetCount = reducedPetCount.toNumber();

			await petPark.connect(account1).giveBackAnimal();
			let currentPetCount = await petPark.animalCounts(AnimalType.Fish);
			currentPetCount = currentPetCount.toNumber();

			expect(reducedPetCount).to.equal(currentPetCount - 1);
		});
	});
});
