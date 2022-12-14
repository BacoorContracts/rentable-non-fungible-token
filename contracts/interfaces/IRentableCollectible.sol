// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ICollectible.sol";

interface IRentableCollectible is ICollectible {
    error RentableCollectible__Rented();
    error RentableCollectible__Expired();
    error RentableCollectible__Unauthorized();

    function setUser(
        uint256 tokenId,
        uint64 expires_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
