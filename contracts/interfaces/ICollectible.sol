// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ITreasury.sol";

interface ICollectible {
    error Collectible721__Unauthorized();
    error Collectible721__AlreadyLocked();
    error Collectible__TokenNotSupported();

    event Unlocked(uint256 indexed tokenId);
    event Locked(uint256 indexed tokenId);

    function mint(address to_, uint256 typeId_) external;

    function safeMint(address to_, uint256 typeId_) external;

    function mintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external;

    function safeMintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external;
}
