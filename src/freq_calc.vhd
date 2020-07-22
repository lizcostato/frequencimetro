--! @file      freq_calc.vhd
--!
--! @brief     subblock of the oximeter Systole detector
--! @details   It counts the number of clock cicles between two consecutive 
--!				systoles and calculate the correspondent frequency
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
-- Version  Date        Author       Changes
-- 1.0      2020-07-22  Liz Costato    Block Created


--------------------------------------------------------------------------------

-- Libraries ------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use work.global_constants_pkg.all;
	
-- Entity ---------------------------------------------------------------------
entity freq_calc is

    port (
        -- Inputs ---------------------------------------------------

        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        systole		:   in std_logic;

        -- Outputs --------------------------------------------------
		
		ack_out		:	out std_logic;
        freq   		:   out integer range MIN_FREQ to MAX_FREQ
    );

end freq_calc;

architecture freq_calc_op of freq_calc is

	--! Current State
    signal s_cstate:   	 	ST_FSM_FREQ;
	--! Next State
    signal s_nstate:   	 	ST_FSM_FREQ;
	--! Contador de ciclos de clock
	signal s_clk_count:		integer range MIN_CLK_COUNT to MAX_CLK_COUNT;
	--! Total que foi contado entre duas sistoles consecutivas
	signal s_tot_count:		integer range MIN_CLK_COUNT to MAX_CLK_COUNT;
	--! @brief Indica que duas sistoles consecutivas foram identificadas
	--! e que ja eh possivel calcular a frequencia
	signal s_start_calc:	std_logic;
	--! Sinal para saber que ja temos duas sistoles
	signal key: 			std_logic;
	--! Sinal pra saida da frequencia
	signal s_freq			integer range MIN_FREQ to MAX_FREQ;
	
	--! This process is used to determine current Test FSM state
    FSM_CS_PROC: process(clk, rst_n)
    begin
        if rst_n ='0' then
            s_cstate <= S0_IDLE;
        elsif (rising_edge(clk)) then
            s_cstate <= s_nstate;
        end if;
    end process FSM_CS_PROC;
	
	--! This process is used to determine next Test FSM state
    FSM_NS_PROC: process(s_cstate, systole)
    begin
        case s_cstate is
        when S0_IDLE   =>
			if (start = '1' AND systole = '1') then
				s_nstate <= S1_WORKING;
			else
				s_nstate <= S0_IDLE;
			end if;
        when S1_SAMP    =>
            s_nstate <= S1_WORKING;
		when others		=>
			s_nstate <= S0_IDLE;
        end case;            
    end process FSM_NS_PROC;
	
	FSM_OUT_PROC: process(clk, rst_n)
    begin
		-- ainda estudar quais valores por no reset
        if rst_n = '0' then
			s_start_calc <= '0';
			s_tot_count <= 0;
			s_clk_count <= '0';
			key <= '0';
			s_freq <= 0;
			freq <= 0;
		elsif rising_edge(clk) then
            case s_cstate is
            when S0_IDLE    =>
				s_start_calc <= '0';
				s_tot_count <= 0;
				s_clk_count <= '0';
				key <= '0';
				s_freq <= 0;
				freq <= 0;
			when S1_WORKING	=>
				if(s_start_calc = '1') then
					-- como dividir eh um processo caro, ver como
					-- otimizar isso aqui
					s_freq <= (1/s_tot_count)*TO_BPM;
					freq <= (1/s_tot_count)*TO_BPM;
				elsif(systole = '1' and key = '1') then
					s_start_calc <= '0';
					s_tot_count <= s_clk_count;
					s_clk_count <= '0';
					key <= key;
					s_freq <= s_freq;
					freq <= s_freq;
				elsif(systole = '1')
					s_start_calc <= '1';
					s_tot_count <= s_clk_count;
					s_clk_count <= '0';
					key <= '1';
					s_freq <= s_freq;
					freq <= s_freq;
				else
					if (rising_edge(s_clk_in)) then
						s_start_calc <= '0';
						s_tot_count <= s_tot_count;
						s_clk_count <= s_clk_count + 1;
						key <= key;
						s_freq <= s_freq;
						freq <= s_freq;
					else
						s_start_calc <= '0';
						s_tot_count <= s_tot_count;
						s_clk_count <= s_clk_count;
						key <= key;
						s_freq <= s_freq;
						freq <= s_freq;
					end if;
				end if;
			when others     =>
				s_start_calc <= '0';
				s_tot_count <= 0;
				s_clk_count <= '0';
				key <= '0';
				s_freq <= 0;
				s_freq <= 0;
			end case;
        end if;
    end process FSM_OUT_PROC;
	
	--! This process keeps track of elapsed time
--    timing: process (clk)
--    begin
--		if(systole = '1' and key = '1') then
--			s_start_calc <= '0';
--			s_tot_count <= s_clk_count;
--			s_clk_count <= '0';
--			key <= key;
--		elsif(systole = '1')
--			s_start_calc <= '1';
--			s_tot_count <= s_clk_count;
--			s_clk_count <= '0';
--			key <= '1';
--		else
--			if (rising_edge(s_clk_in)) then
--				s_start_calc <= '0';
--				s_tot_count <= s_tot_count;
--				s_clk_count <= s_clk_count + 1;
--				key <= key;
--			else
--				s_start_calc <= '0';
--				s_tot_count <= s_tot_count;
--				s_clk_count <= s_clk_count;
--				key <= key;
--			end if;
--		end if;
--    end process timing;
	
	--!
--	calculating: process (clk)
--	begin
--		
--	end
end freq_calc_op;