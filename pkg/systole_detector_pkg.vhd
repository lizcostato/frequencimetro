--! @file      systole_detector.vhd
--!
--! @brief     subblock of the oximeter Systole detector
--! @details   Detects which of the wave systoles are systoles
--!
--! @author    Liz Costato
--! @author    
--! 
--! @version   1.0
--! @date      2020-06-07
--! 
--! @pre       
--! @pre       
--! @copyright DFchip
--! 
-------------------------------------------------------------------------------
-- Version History
--
-- Version  Date        Author       Changes
-- 1.0      2020-06-07 Liz Costato    Block Created


--------------------------------------------------------------------------------

-- Libraries ------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use work.global_constants_pkg.all;
-- Entity ---------------------------------------------------------------------

--! @brief Oximeter: systole Detector
--!
--! @image html spec_block_ms.png

package systole_detector_pkg is

    -- Types ------------------------------------------------------------------
    
    --! States of FSM_SPEC_MS_DEC at \ref spec_ms_dec.behaviour
    subtype ST_FSM_SYSTOLE is std_logic;    
        constant S0_INIT:   ST_FSM_SYSTOLE    := '0';
        constant S1_SAMP:   ST_FSM_SYSTOLE    := '1';

    -- Constants --------------------------------------------------------------
    constant DATA_ZERO: std_logic_vector(L_DATA downto 0);
    constant DATA_WIDTH: integer;
    -- Components -------------------------------------------------------------
    component systole_detector is

    port (
        -- Inputs ---------------------------------------------------

        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        peak   		:   in std_logic;
		data_in     :   in std_logic_vector(L_DATA - 1 downto 0);

        -- Outputs --------------------------------------------------

        systole   :   out std_logic
    );

    end component systole_detector;
end package systole_detector_pkg;

package body systole_detector_pkg is
    constant DATA_ZERO: std_logic_vector(L_DATA downto 0) := (others => '0');
    constant DATA_WIDTH: integer := L_DATA;
end package body systole_detector_pkg;