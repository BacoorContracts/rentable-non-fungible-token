import * as dotenv from "dotenv";
import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

async function main(): Promise<void> {
    const Authority: ContractFactory = await ethers.getContractFactory(
        "Authority",
    );
    const authority: Contract = await upgrades.deployProxy(Authority, [], {
        kind: "uups",
        initializer: "initialize",
    });
    await authority.deployed();
    console.log("Authority deployed to : ", authority.address);

    const Treasury: ContractFactory = await ethers.getContractFactory(
        "Treasury",
    );
    const treasury: Contract = await upgrades.deployProxy(
        Treasury,
        [authority.address],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await treasury.deployed();
    console.log("Treasury deployed to : ", treasury.address);

    const ERC20Test: ContractFactory = await ethers.getContractFactory(
        "ERC20Test",
    );
    const erc20Test: Contract = await ERC20Test.deploy();
    await erc20Test.deployed();
    console.log("ERC20Test deployed to : ", erc20Test.address);

    const RentableNFC: ContractFactory = await ethers.getContractFactory(
        "RentableCollectible721Upgradeable",
    );
    const rentableNFC: Contract = await upgrades.deployProxy(
        RentableNFC,
        [
            "RentableNFC",
            "RNFC",
            "https://nft-card.w3w.app/api/nft-cards/metadata/97/0xb05954811d64fe3e76e1e3a46f9e42047d2b36ae/",
            ethers.utils.parseEther("1"),
            erc20Test.address,
            authority.address,
            treasury.address,
        ],
        { kind: "uups", initializer: "initialize" },
    );
    await rentableNFC.deployed();
    console.log("RentableNFC deployed to : ", rentableNFC.address);
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });
