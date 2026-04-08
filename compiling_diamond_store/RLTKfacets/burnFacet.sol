// SPDX-License-Identifier: MIT

/*
                                                                                                                 
    RRRRRRRRRRRRRRRRR                     lllllll                              tttt          kkkkkkkk                           
    R::::::::::::::::R                    l:::::l                           ttt:::t          k::::::k                           
    R::::::RRRRRR:::::R                   l:::::l                           t:::::t          k::::::k                           
    RR:::::R     R:::::R                  l:::::l                           t:::::t          k::::::k                           
    R::::R     R:::::Ruuuuuu    uuuuuu   l::::l     eeeeeeeeeeee    ttttttt:::::ttttttt     k:::::k    kkkkkkkaaaaaaaaaaaaa   
    R::::R     R:::::Ru::::u    u::::u   l::::l   ee::::::::::::ee  t:::::::::::::::::t     k:::::k   k:::::k a::::::::::::a  
    R::::RRRRRR:::::R u::::u    u::::u   l::::l  e::::::eeeee:::::eet:::::::::::::::::t     k:::::k  k:::::k  aaaaaaaaa:::::a 
    R:::::::::::::RR  u::::u    u::::u   l::::l e::::::e     e:::::etttttt:::::::tttttt     k:::::k k:::::k            a::::a 
    R::::RRRRRR:::::R u::::u    u::::u   l::::l e:::::::eeeee::::::e      t:::::t           k::::::k:::::k      aaaaaaa:::::a 
    R::::R     R:::::Ru::::u    u::::u   l::::l e:::::::::::::::::e       t:::::t           k:::::::::::k     aa::::::::::::a 
    R::::R     R:::::Ru::::u    u::::u   l::::l e::::::eeeeeeeeeee        t:::::t           k:::::::::::k    a::::aaaa::::::a 
    R::::R     R:::::Ru:::::uuuu:::::u   l::::l e:::::::e                 t:::::t    tttttt k::::::k:::::k  a::::a    a:::::a 
    RR:::::R     R:::::Ru:::::::::::::::uul::::::le::::::::e                t::::::tttt:::::tk::::::k k:::::k a::::a    a:::::a 
    R::::::R     R:::::R u:::::::::::::::ul::::::l e::::::::eeeeeeee        tt::::::::::::::tk::::::k  k:::::ka:::::aaaa::::::a 
    R::::::R     R:::::R  uu::::::::uu:::ul::::::l  ee:::::::::::::e          tt:::::::::::ttk::::::k   k:::::ka::::::::::aa:::a
    RRRRRRRR     RRRRRRR    uuuuuuuu  uuuullllllll    eeeeeeeeeeeeee            ttttttttttt  kkkkkkkk    kkkkkkkaaaaaaaaaa  aaaa
                                                                                                                                
                                    
    Ruletka (RTK) is a Russian Roulette ERC20 token, where on each transaction a number is chosen between 1 and 6. If 6 is chosen,
    the transaction will be sent to the 0x address and burned, thus lowering total supply.

    https://dappradar.com/dapp/ruletka-io
    https://t.me/RuletkaToken
 
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract burnFacet is ERC20, Ownable {
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
