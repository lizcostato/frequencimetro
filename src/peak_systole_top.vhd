-------------------------------------------------------------------------------
--! 
--! @file      systole_detector.vhd
--!
--! @brief     subblock of the oximeter Systole detector
--! @details   Detects which of the wave peaks are systoles
--!
--! @author    Liz Costato
--! @author    
--! 
--! @version   1.0
--! @date      2020-06-07
--! 
--! @pre       Started by slop_detector_start
--! @pre       
--! @copyright 
--! 
-------------------------------------------------------------------------------
-- Version History
--
-- Version  Date        Author       Changes
-- 1.0      2016-08-18  Liz Costato	 Block created


--------------------------------------------------------------------------------
-- Libraries -------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_arith.all;
    use work.systole_detector_pkg.all;
    use work.global_constants_pkg.all;
	
entity peak_systole_top is
    port(
        clk_in         	: in std_logic;
        reset_in       	: in std_logic;
		start_in		: in std_logic;
		data_in			: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		
		systole		: out std_logic
    );

end peak_systole_top;

architecture Rtl of peak_systole_top is

	signal s_peak	:	std_logic;
	
	component systole_detector is
    port (
		-- Inputs ---------------------------------------------------

        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        peak   		:   in std_logic;
		data_in     :   in std_logic_vector(DATA_WIDTH - 1 downto 0);

        -- Outputs --------------------------------------------------

        systole   :   out std_logic
	);
    end component;
	
	component peak_detector is
    port (
		-- Inputs ---------------------------------------------------

        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        data_in     :   in std_logic_vector(DATA_WIDTH - 1 downto 0);

        -- Outputs --------------------------------------------------

        peak  			:   out std_logic
	);
    end component;
	
	--ainda devo incluir o componente de medição de frequencia, 
	--dai a frequandia vai ser a saida do topo, n a sistole
	
begin
    U_SYSTOLE : systole_detector
    port map (
		clk         =>	clk_in,
        rst_n       =>	reset_in,
        start       =>	start_in,
        peak   		=>	s_peak,
		data_in     =>	data_in,
        systole   	=>	systole
	);
	
    U_PEAK : peak_detector
    port map (
		clk         =>	clk_in,
        rst_n       =>	reset_in,
        start       =>	start_in,
        data_in     =>	data_in,
        peak  		=>	s_peak
	);
	
end Rtl;