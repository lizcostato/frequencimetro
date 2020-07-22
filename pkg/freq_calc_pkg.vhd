--------------------------------------------------------------------------------
--!
--! @file      freq_calc_pkg.vhd
--!
--! @brief     pakage for subblock of the oximeter Systole detector
--! @details   It counts the number of clock cicles between two consecutive 
--!            systoles and calculate the correspondent frequency
--!
--! @author    Liz Costato
--! @author    Juliana Garçoni
--! 
--! @version   1.0
--! @date      2020-07-22
--! 
--! @pre       
--! @pre       
--! @copyright 
--! 
-------------------------------------------------------------------------------
-- Version History
--
-- Version  Date        Author         Changes
-- 1.0      2020-07-22  Liz Costato    Block Created


--------------------------------------------------------------------------------

-- Libraries -------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use work.global_constants_pkg.all;

-- Package initialization ------------------------------------------------------    
package systole_detector_pkg is

    -- Types -------------------------------------------------------------------
    --! States of FSM_SPEC_MS_DEC at \ref spec_ms_dec.behaviour
    subtype ST_FSM_FREQ is std_logic;    
        constant S0_IDLE     :    ST_FSM_FREQ    := '0';
        constant S1_WORKING  :    ST_FSM_FREQ    := '1';

    -- Constants ---------------------------------------------------------------
    constant MAX_FREQ        : integer;
    constant MIN_FREQ        : integer;
    constant MAX_CLK_COUNT   : integer;
    constant MIN_CLK_COUNT   : integer;
    constant TO_BPM          : integer;
    
    -- Components --------------------------------------------------------------
    component freq_calc is
    port (
        -- Inputs ---------------------------------------------
        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        systole     :   in std_logic;
        -- Outputs --------------------------------------------
        ack_out     :    out std_logic;
        freq        :   out integer range MIN_FREQ to MAX_FREQ;
        --counter_start    :   out std_logic
    );
    end component freq_calc;
    
end package systole_detector_pkg;

package body systole_detector_pkg is

    --! The block below initialises the constants with the proper values.
    -- ver se eh uma boa opcao de valor
    constant MAX_FREQ       : integer := 350;
    constant MIN_FREQ       : integer := 0;
    -- ver se eh uma boa opcao de valor
    constant MAX_CLK_COUNT  : integer := 8192;
    constant MIN_CLK_COUNT  : integer := 0;
    -- se o clock estiver em picosegundos, precisa multiplica por 10^12
    -- pra ter a freq em Hz, depois multiplicar por 60 pra ter em bpm
    constant TO_BPM         : integer := 60000000000000;
end package body systole_detector_pkg;
