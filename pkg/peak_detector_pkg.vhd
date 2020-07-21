--! @file      peak_detector_pkg.vhd
--!
--! @brief     subblock of the oximeter Peak detector
--! @details   Detects the wave peaks (falling edges) in oximeter signal
--!
--! @author    Guilherme Shimabuko
--! @author    
--! 
--! @version   1.0
--! @date      2016-08-18
--! 
--! @pre       Started by slop_detector_start
--! @pre       
--! @copyright DFchip
--! 
-------------------------------------------------------------------------------
-- Version History
--
-- Version  Date        Author       Changes
-- 1.0      2016-08-18 GSHIMABUKO    Block Created


--------------------------------------------------------------------------------

-- Libraries ------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use work.global_constants_pkg.all;
-- Entity ---------------------------------------------------------------------

--! @brief Oximeter: peak Detector
--!
--! @image html spec_block_ms.png

package peak_detector_pkg is

    -- Types ------------------------------------------------------------------
    
    --! States of FSM_SPEC_MS_DEC at \ref spec_ms_dec.behaviour
    subtype ST_FSM_peak is std_logic_vector(1 downto 0);    
        constant S0_INIT:   ST_FSM_PEAK    := "00";
        constant S1_SAMP:   ST_FSM_PEAK    := "01";
        constant S2_RIS:    ST_FSM_PEAK    := "11";
        constant S3_FAL:    ST_FSM_PEAK    := "10";

    -- Constants --------------------------------------------------------------
    constant DATA_ZERO: std_logic_vector(L_DATA downto 0);
    constant DATA_WIDTH: integer;
    -- Components -------------------------------------------------------------
    component peak_detector is

    port (
        -- Inputs ---------------------------------------------------

        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        data_in     :   in std_logic_vector(L_DATA-1 downto 0);

        -- Outputs --------------------------------------------------

        peak   :   out std_logic;
        counter_start    :   out std_logic
    );

    end component peak_detector;
end package peak_detector_pkg;

package body peak_detector_pkg is
    constant DATA_ZERO: std_logic_vector(L_DATA downto 0) := (others => '0');
    constant DATA_WIDTH: integer := L_DATA;
end package body peak_detector_pkg;