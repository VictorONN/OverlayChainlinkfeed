// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../../interfaces/feeds/AggregatorV3Interface.sol";
import "../../libraries/Oracle.sol";
import "../../libraries/FixedPoint.sol";
import "../OverlayV1Feed.sol";

contract OVLV1ChainlinkFeed is OverlayV1Feed {

    AggregatorV3Interface internal priceFeed;

    /**
     * How to integrate a price feed
     * Network: Kovan
     * Aggregator: OVL/ETH
     * Placeholder address of the OVL price feed: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor() OverlayV1Feed(_microWindow, _macroWindow) {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }

    /**
     * Returns the latest price from Chainlink price oracle
     */

     function _fetch() internal view override returns (Oracle.Data memory) {

        // cache micro and macro windows for gas savings
        uint256 _microWindow = microWindow;
        uint256 _macroWindow = macroWindow;
  
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        //TODO: how to convert int price into uint256 at once? instead of severally in the struct below

        uint256 price = uint256(price * 10 ** 10);
        //since price is in 8 decimal places, we multiply by 10^10 to convert to 18 decimal places
        
        // consult to market pool
        // secondsAgo.length = 4; 
        (
            uint32[] memory secondsAgos,
        ) = _inputsToConsultChainlinkOracles(_microWindow, _macroWindow);
       
        // calculate priceOverMicroWindow similar to how Uniswap V2 TWAP are calculated? 
        uint256 _priceOverMicroWindow;        
        
        uint256 previousTimestamp = timestamp - _microWindow;

        if (updatedAt < previousTimestamp) {

            //uniswapV2 TWAP calculation
            _priceOverMicroWindow = previousRoundPrice - price /  (timestamp - updatedAt);
        } else {
            
            uint80 _previousRoundId = getPreviousRoundId(base, quote, roundId);
            (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
            ) = getRoundData(base, quote, _previousRoundId);

            if (updatedAt < previousTimestamp) {

            } //uniswapV2 TWAP calculation
            _priceOverMicroWindow = previousRoundPrice - price /  (timestamp - updatedAt); 
            } else {
                ...
            }
        }
                    
        }       
        
        // calculate priceOverMicroWindow 
        uint256 _priceOverMacroWindow;
        // TODO: same calculation as priceOverMicroWindow     


        // calculate priceOneMacroWindowAgo
        uint256 _priceOneMacroWindowAgo = ___; 
        uint previousPeriod = timeStamp - secondsAgo[1];
        if (previousPeriod > updatedAt) {
               _priceOneMacroWindowAgo = price;
        }  else {
            uint80 _previousRoundId = getPreviousRoundId(base, quote, roundId);
            (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
            ) = getRoundData(base, quote, _previousRoundId); 
            if (secondsAgo[1] > updatedAt) {
                _priceOneMacroWindowAgo = answer;
            } else {
                ...
            }
        }

        
        // calculate current reserve over microWindow
        uint256 _reserveOverMicroWindow;

        
        Oracle.Data memory oracleData = Data({
                timestamp: block.timestamp,
                microWindow: microWindow,
                macroWindow: macroWindow,
                priceOverMicroWindow: _priceOverMicroWindow, 
                priceOverMacroWindow: _priceOverMacroWindow, 
                priceOneMacroWindowAgo: _priceOneMacroWindowAgo, 
                reserveOverMicroWindow: _reserveOverMicroWindow,
                // how to get the current reserve?  
                hasReserve: false 
        });

        return oracleData;
    
     }


      //similar to _inputsToConsultMarketPool in OverlayV1UniswapV3Feed
     function _inputsToConsultChainlinkOracles(uint256 _microWindow, uint256 _macroWindow)
        private
        pure
        returns ( uint32[] memory)
    {
        uint32[] memory secondsAgos = new uint32[](4);
      
        // number of seconds in past for which we want accumulator snapshot
        // for Oracle.Data, need:
        //  1. now (0 s ago)
        //  2. now - microWindow (microWindow seconds ago)
        //  3. now - macroWindow (macroWindow seconds ago)
        //  4. now - 2 * macroWindow (2 * macroWindow seconds ago)
        secondsAgos[0] = uint32(_macroWindow * 2);
        secondsAgos[1] = uint32(_macroWindow);
        secondsAgos[2] = uint32(_microWindow);
        secondsAgos[3] = 0;

        return (secondsAgos);
    }
}
     
    

