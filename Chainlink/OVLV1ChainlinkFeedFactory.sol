// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "../OverlayV1FeedFactory.sol";
import "./OverlayV1ChainlinkFeed.sol";

contract OVLV1ChainlinkFeedFactory is OverlayV1FeedFactory {

    function createChainlinkFeed() public {
        // require(msg.sender == governor, "not governor"); 
        OverlayV1ChainlinkFeed newFeed = new OverlayV1ChainlinkFeed;
    }

}