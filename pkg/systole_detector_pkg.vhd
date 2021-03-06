--------------------------------------------------------------------------------
--!
--! @file      systole_detector_pkg.vhd
--!
--! @brief     pakage for subblock of the oximeter Systole detector
--! @details   Detects which of the wave peaks are systoles
--!
--! @author    Liz Costato
--! @author    Juliana Garçoni
--! 
--! @version   1.0
--! @date      2020-06-07
--! 
--! @pre       
--! @pre       
--! @copyright 
--! 
--------------------------------------------------------------------------------
-- Version History
--
-- Version  Date         Author         Changes
-- 1.0      2020-06-07   Liz Costato    Block Created

--------------------------------------------------------------------------------

-- Libraries -------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use work.global_constants_pkg.all;

-- Package initialization ------------------------------------------------------
package systole_detector_pkg is

    -- Types -------------------------------------------------------------------
    --! States of FSM_SPEC_MS_DEC at \ref spec_ms_dec.behaviour
    subtype ST_FSM_SYSTOLE is std_logic;    
        constant S0_INIT  :   ST_FSM_SYSTOLE    := '0';
        constant S1_SAMP  :   ST_FSM_SYSTOLE    := '1';

    -- Constants ---------------------------------------------------------------
    constant DATA_ZERO    : std_logic_vector(L_DATA downto 0);
    constant DATA_WIDTH   : integer;

    -- Components --------------------------------------------------------------
    component systole_detector is
    port (
        -- Inputs -----------------------------------------------
        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        peak        :   in std_logic;
        --peak_value  :   in std_logic_vector(DATA_WIDTH - 1 downto 0);
        peak_value  :   in std_logic_vector(7 downto 0);
        --data_in     :   in std_logic_vector(L_DATA - 1 downto 0);
        -- Outputs ----------------------------------------------
        systole     :   out std_logic
    );

    end component systole_detector;
end package systole_detector_pkg;

package body systole_detector_pkg is

    --! The block below initialises the constants with the proper values.
    constant DATA_ZERO  : std_logic_vector(L_DATA downto 0) := (others => '0');
    constant DATA_WIDTH : integer := L_DATA;

end package body systole_detector_pkg;
