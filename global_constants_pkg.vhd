-------------------------------------------------------------------------------
--! 
--! @file      global_constants_pkg.vhd
--! 
--! @brief     Constants used throughout the MS and ICS blocks
--! @details   Subblock of the block \ref spec_block_ms
--!
--! @author    Guilherme Shimabuko Silva Rocha
--! 
--! @version   1.0
--! @date      2016-03-11
--! 
--! @copyright DFchip
--! 
--------------------------------------------------------------------------------
--
-- Version History
--
-- Version  Date        Author       Changes
-- 1.0      2016-03-04  GSHIMABUKO   Created package with global constants for
--                                   MS Block
--
--------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

package global_constants_pkg is

    constant L_DATA: integer;
    constant L_DATA_2: integer;
    constant CLK_HALF_PERIOD: time;

end package global_constants_pkg;

package body global_constants_pkg is

    --! The block below initialises the constants with the proper values.
    constant L_DATA: integer := 8;
    constant L_DATA_2: integer := 16;
    constant CLK_HALF_PERIOD: time := 0.5 ps;
    
end package body global_constants_pkg;