// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ChainBattles
 * @dev An NFT game where users mint and train "Warrior" NFTs with levels.
 */
contract ChainBattles is ERC721, ERC721URIStorage {
    using Strings for uint256;

    /// @notice Counter for token IDs
    uint256 private _tokenId;

    /// @notice Mapping to track levels of tokens
    mapping(uint256 => uint256) public tokenIdToLevels;
    mapping(uint256 => bool) private tokenExists;

    /// @dev Initializes the ERC721 token with name and symbol.
    constructor() ERC721("ChainBattles", "CBS") {}

    /**
     * @notice Generates the SVG image for the NFT based on its tokenId and level.
     * @param tokenId The ID of the token for which to generate the image.
     * @return The Base64-encoded SVG image as a string.
     */
    function generateCharacter(uint256 tokenId) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getLevels(tokenId),
            "</text>",
            "</svg>"
        );
        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svg)));
    }

    /**
     * @notice Mints a new token for the caller.
     * @dev Assigns an initial level of 0 and sets the token's metadata.
     */
    function mint() public {
        _tokenId++;
        uint256 newItemId = _tokenId;
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId] = 0;
        tokenExists[newItemId] = true; // Mark token as existing
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    /**
     * @notice Retrieves the level of a token.
     * @param tokenId The ID of the token to query.
     * @return The level of the token as a string.
     */
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToLevels[tokenId];
        return levels.toString();
    }

    /**
     * @notice Constructs the metadata URI for a token.
     * @param tokenId The ID of the token to generate metadata for.
     * @return The Base64-encoded JSON metadata as a string.
     */
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    /**
     * @notice Trains a token, increasing its level.
     * @param tokenId The ID of the token to train.
     * @dev Only the owner of the token can train it.
     */
    function train(uint256 tokenId) public {
        require(tokenExists[tokenId], "Token does not exist"); // Check existence using the mapping
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        tokenIdToLevels[tokenId]++;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    /**
     * @notice Retrieves the token URI for a token.
     * @param tokenId The ID of the token to retrieve metadata for.
     * @return The metadata URI for the token.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @notice Checks if the contract supports a specific interface.
     * @param interfaceId The interface ID to check.
     * @return True if the interface is supported, otherwise false.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
