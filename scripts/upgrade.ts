import * as dotenv from "dotenv";
import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

dotenv.config();

async function main(): Promise<void> {
    const RentableCollectible721: ContractFactory =
        await ethers.getContractFactory("RentableCollectible721");
    const rentableCollectible: Contract = await upgrades.upgradeProxy(
        process.env.RNFT || "",
        RentableCollectible721,
    );
    await rentableCollectible.deployed();
    console.log(
        "RentableCollectible721 upgraded to : ",
        await upgrades.erc1967.getImplementationAddress(
            rentableCollectible.address,
        ),
    );
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });
