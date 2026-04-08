/*
   * SPDX-License-Identifier: MIT
   * Website: https://www.abra.com/?utm_source=icodrops
   * Facebook: https://www.facebook.com/AbraGlobal
   * Twitter: https://twitter.com/AbraGlobal
   * Reddit: https://www.reddit.com/user/AbraGlobal/
   * Linkedin: https://www.linkedin.com/company/abra/
   * Medium: https://www.abra.com/blog/
   * Youtube: https://www.youtube.com/channel/UCMb7-snlNp7ctSVlpqMbXFw?view_as=subscriber
*/
pragma solidity ^0.8.24;

contract NestedTypeTest {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint public result;
    function openTrading(address bots) external {
            result = 1 + 1;
        }
}