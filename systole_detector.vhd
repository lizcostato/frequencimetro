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
    
    
-- Entity ---------------------------------------------------------------------

--! @brief Oximeter: systole Detector
--!
--! @image html spec_block_ms.png

entity systole_detector is

    port (
        -- Inputs ---------------------------------------------------

        clk         :   in std_logic;
        rst_n       :   in std_logic;
        start       :   in std_logic;
        peak   		:   in std_logic;
		peak_value  :   in std_logic_vector(DATA_WIDTH - 1 downto 0);

        -- Outputs --------------------------------------------------

        systole   :   out std_logic
        --counter_start    :   out std_logic
    );

end systole_detector;

architecture systole_detector_op of systole_detector is

	--! Current State
    signal s_cstate:   	 	ST_FSM_SYSTOLE;
	--! Next State
    signal s_nstate:   	 	ST_FSM_SYSTOLE;
	--! Sinal de entrada
    signal s_data_0:  		std_logic_vector(DATA_WIDTH - 1 downto 0);
	--! Um segundo sinal de entrada, para comparação
    signal s_data_1:  		std_logic_vector(DATA_WIDTH - 1 downto 0);
	--! @brief Vai calcular a diferença entre os dois sinais para saber
	-- quem é maior
	signal s_diff:      	std_logic_vector(DATA_WIDTH - 1 downto 0);
	--! @brief Vai receber o shift do maior valor
	signal fift_perc:		std_logic_vector(DATA_WIDTH - 2 downto 0);
	--! @brief Vai ser um shift pra direita (divisão por 2) do maior 
	--! sinal menos o menor sinal. É pra constatar se o menor sinal
	--! é mais ou menos que 50% do sinal maior. Se for menor, considero
	--! que temos uma diástole. Se for maior, considero que é uma 
	--! sístole, só de pico menor, e atualizo o valor da sístole pra esse.
	--! Talvez 50% seja um valor baixo....ainda estudar isso.
	signal s_perc_comp:    	std_logic_vector(DATA_WIDTH - 1 downto 0);
	--! Valor atual que estou considerando como sístole
	signal s_c_syst_value:	std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	-- Sinais auxiliares (por ora teste)
	--! Previous s_data_1 value
	signal s_p_data_1:		std_logic_vector(DATA_WIDTH - 1 downto 0);
	--! @brief Para que o s_c_syst_value seja sempre atualizado com o mesmo
	--! sinal e não haja problemas de sincronismo
	signal key:				std_logic;

    begin

	--============================================================================
    -- PROCESS FSM_CS_PROC
    --! It updates the current state of FSM and verifies the reset_in input signal
    --! to reset the system.
    --! @param[in] clk: Clock signal. Process triggered by rising edge.
    --! @param[in] rst_n. Asynchronous reset, asserted in '0'.
    --! Read:
    --! s_next_state: Next state of the FSM.
    --! Update:
    --! s_cstate: Current state of the FSM.
   --============================================================================
    FSM_CS_PROC: process(clk, rst_n)
    begin
        if rst_n ='0' then
            s_cstate <= S0_INIT;
        elsif (rising_edge(clk)) then
            s_cstate <= s_nstate;
        end if;
    end process FSM_CS_PROC;
    
	--============================================================================
	-- PROCESS FSM_NS_PROC
	--! It makes the combinational transition between the states of the FSM that 
	--! controls the AGC algorithm.
	--! @param[in] s_cstate: Signal that storages the current state of the FSM.
	--! @param[in] 
	--! @param[in] 
	--! @param[in] 
	--!
	--! Read:
	--! current_state: Current state of the FSM.
	--! Update:
	--! next_state: Next state of the FSM.
	--============================================================================
    FSM_NS_PROC: process(s_cstate, start, peak)
    begin
        case s_cstate is
        when S0_INIT    =>
			-- se pá n precisa pq peak so vai ser 1 qnd o outro
			-- bloco estiver funcionando, logo, já vai ter tido
			-- start.
			-- coloquei o start pra ser uma chave (fica em 1 enquanto
			-- o sistema estiver funcionando) - uma opcao e criar um 
			-- sinal pra alterar entre 0 e 1 quando tiver um risign 
			-- edge do start.
			
			-- só significa que peguei o primeiro pico quando o sistema
			-- tava ativo (start = '1')
			if (start = '1' AND peak = '1') then
				s_nstate <= S1_SAMP;
			else
				s_nstate <= S0_INIT;
			end if;
        when S1_SAMP    =>
            s_nstate <= S1_SAMP;
		when others		=>
			s_nstate <= S0_INIT;
        end case;            
    end process FSM_NS_PROC;

	--============================================================================
    -- PROCESS FSM_OUT_PROC
    --! @brief It describes the operations realized in the states of the FSM.
    --! @param[in] clk: Clock signal. Process triggered by rising edge.
    --! @param[in] : 
    --!
	--! Read:
	--! current_state: Current state of the FSM.
	--! Update:
	--! 
   --============================================================================
    FSM_OUT_PROC: process(clk, rst_n)
    begin
		-- ainda estudar quais valores por no reset
        if rst_n = '0' then
            s_data_0        <= (others => '0');
            s_data_1        <= (others => '0');
			s_p_data_1		<= (others => '0');
            systole         <= '0';
			s_c_syst_value	<= (others => '0');
			key <= '0';
        elsif rising_edge(clk) then
            case s_cstate is
            when S0_INIT    =>
                s_data_0    	<= peak_value;
				s_c_syst_value	<= peak_value;
				-- testando pra ver se assim ele pega o primeiro dado,
				-- antes era recebendo ele mesmo. 
				-- Uuuuuhhh, funfou!!
                s_data_1    <= s_data_1;
				s_p_data_1		<= s_p_data_1;
                systole       <= '0';
				key <= '0';
            when S1_SAMP    =>
				--s_data_0 é o dado mais novo
				if (peak = '1') then
					s_data_0    <= peak_value;
					s_data_1    <= s_data_0;
					s_p_data_1	<= s_data_1;
					-- como ele demora um ciclo de clock, pegar o anterior pra fazer 
					-- a conta 
					s_diff      <= (signed(s_c_syst_value) - signed(s_data_0));
					-- se 1, s_data_0 > s_c_syst_value, logo, o novo é maior
					if (s_diff(DATA_WIDTH-1) = '1') then
						if (key = '0') then
							key <= '1';
						else				
							systole       <= '1'; 
							-- uma opção nao legivel (mas que tmb daria certo), é usar
							-- o s_data_1, pq ele tmb ta sempre recebendo o s_data_0,
							-- logo, te sempre o mesmo valor do s_p_data_0.
							-- Na real, faz sentido sim...é isso que significa o s_data_1
							-- Se der certo, mudar isso
							-- Depois reescrever esses trem aqui em 
							-- Puts, o diff ainda demora um ciclo pra ser calculado, entao
							-- acho que deve pegar o s_p_data_1
							s_c_syst_value  <= s_p_data_1;
							key <= '0';
						end if;
					else
						-- vendo se o pico menor é mais ou menos de 50% do maior
						-- se pá, bom aumentar um pouco essa porcentagem
							-- teria um fift_perc <= s_c_syst_value(DATA_WIDTH-1 downto 1)
							-- mas isso ta dando um atraso que n quero
						-- quero o valor de s_data_0 que foi usado no cálculo do s_diff
						-- logo, quando s_diff foi calculado, esse valor foi pro s_data_1
						s_perc_comp <= signed(s_c_syst_value(DATA_WIDTH-1 downto 1))-signed(s_data_1);
						key <= '0';
						-- considerando que + de 50% seria outra sístole
						if (s_perc_comp(DATA_WIDTH-1) = '1') then
							systole       <= '1'; 
							-- ruim que vai dar choque entre esse e o outro, pois esse demora
							-- um ciclo de clock a mais...
							s_c_syst_value  <= s_p_data_1;
						else 
							-- só mais uma diástole
							systole       <= '0';
							s_c_syst_value <= s_c_syst_value;
						end if;
					end if;
				else
					--n teve pico, mentem tudo
				end if;
            when others     =>
                s_data_0        <= (others => '0');
				s_data_1        <= (others => '0');
				s_p_data_1		<= (others => '0');
				systole         <= '0';
				s_c_syst_value	<= (others => '0');
				key <= '0';
            end case;
        end if;
    end process FSM_OUT_PROC;
   
end systole_detector_op;