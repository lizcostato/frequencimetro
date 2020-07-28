-------------------------------------------------------------------------------
--! 
--! @file      systole_detector.vhd
--!
--! @brief     subblock of the oximeter Systole detector
--! @details   Detects which of the wave peaks are systoles
--!
--! @author    Liz Costato
--! @author    Juliana Garçoni
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
-- 1.0      2016-08-18  Liz Costato     Block created


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
        peak           :   in std_logic;
        peak_value  :   in std_logic_vector(DATA_WIDTH - 1 downto 0);

        -- Outputs --------------------------------------------------

        systole   :   out std_logic
        --counter_start    :   out std_logic
    );

end systole_detector;

architecture systole_detector_op of systole_detector is

    --! Current State
    signal s_cstate:            ST_FSM_SYSTOLE;
    --! Next State
    signal s_nstate:            ST_FSM_SYSTOLE;
    --! Sinal de entrada
    signal s_data_0:          std_logic_vector(DATA_WIDTH - 1 downto 0);
    --! Um segundo sinal de entrada, para comparação
    --signal s_data_1:          std_logic_vector(DATA_WIDTH - 1 downto 0);
    --! @brief Vai calcular a diferença entre os dois sinais para saber
    -- quem é maior
    signal s_diff:          std_logic_vector(DATA_WIDTH downto 0);
    
    --! @brief Vai receber o shift do maior valor (n ta sendo usado)
    --signal fift_perc:        std_logic_vector(DATA_WIDTH - 2 downto 0);
    
    --! @brief Vai ser um shift pra direita (divisão por 2) do maior 
    --! sinal menos o menor sinal. É pra constatar se o menor sinal
    --! é mais ou menos que 50% do sinal maior. Se for menor, considero
    --! que temos uma diástole. Se for maior, considero que é uma 
    --! sístole, só de pico menor, e atualizo o valor da sístole pra esse.
    --! Talvez 50% seja um valor baixo....ainda estudar isso.
    signal s_perc_comp:        std_logic_vector(DATA_WIDTH downto 0);
    --! Valor atual que estou considerando como sístole
    signal s_c_syst_value:    std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- Sinais auxiliares (por ora teste)
    --! Previous s_data_1 value
    --signal s_p_data_1:        std_logic_vector(DATA_WIDTH - 1 downto 0);
    --! @brief Para que o s_c_syst_value seja sempre atualizado com o mesmo
    --! sinal e não haja problemas de sincronismo
    --signal s_key:                std_logic;


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
            if (start = '1' and peak = '1') then
                s_nstate <= S1_SAMP;
            else
                s_nstate <= S0_INIT;
            end if;
        when S1_SAMP    =>
            s_nstate <= S1_SAMP;
        when others     =>
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
            --s_data_1        <= (others => '0');
            s_c_syst_value  <= (others => '0');
            s_perc_comp     <= (others => '0');
            s_diff          <= (others => '0');
            systole         <= '0';

        elsif rising_edge(clk) then
            case s_cstate is
            when S0_INIT    =>
                s_data_0        <= peak_value;
                --s_data_1        <= s_data_1;
                s_c_syst_value  <= peak_value;
                s_diff          <= s_diff;
                s_perc_comp     <= s_perc_comp;
                systole         <= '0';
            when S1_SAMP    =>
                if (peak = '1') then
                    s_data_0        <= peak_value;
                    s_c_syst_value  <= peak_value;
                    
                    -- aqui nao precisa de calculo, pois:
                    -- se o dado anterior eh positivo e o atual negativo, o atual n eh sistole
                    --if (s_c_syst_value(DATA_WIDTH-1) = '0' and peak_value(DATA_WIDTH-1) = '1') then 
                    --    s_c_syst_value  <= peak_value;
                    --    systole         <= '0';

                    -- se o dado anterior eh negativo e o atual positivo, o atual eh sistole
                    --elsif (s_c_syst_value(DATA_WIDTH-1) = '1' and peak_value(DATA_WIDTH-1) = '0') then
                    --    s_c_syst_value  <= s_data_0;
                    --    systole         <= '1';
                    --else
                        -- calculamos aqui
						-- LIZ> mudei s_peak_value para s_c_syst_value pq a gente tem de comparar o mais
						-- LIZ> novo com o que a gente atualmente considera como sistole e n o mais novo
						-- LIZ> com o anterior
                        s_diff <= ((signed('0' & s_c_syst_value) - signed('0' & peak_value)));
                        -- fazendo isso, calculamos o percentual absoluto dos dados (nao sei usar o abs em vhdl)
                        s_perc_comp <= (signed('0' & '0' & s_c_syst_value(DATA_WIDTH-1 downto 1)) - signed('0' & peak_value(DATA_WIDTH-1 downto 0)));
                        --s_perc_comp <= signed((unsigned(s_data_0(DATA_WIDTH-1 downto 1)) - unsigned(peak_value)));

                        --s_data_1 <= s_data_0;

                        -- se o valor atual eh maior que o anterior, ele eh sistole
                        if (s_diff(DATA_WIDTH) = '1') then
                            --s_perc_comp     <= s_perc_comp;
                            s_c_syst_value  <= s_data_0;
                            systole         <= '1';
                        -- mesmo menor, se o dado atual for mais de 50% do dado anterior, ele eh sistole
                        elsif (s_perc_comp(DATA_WIDTH) = '1') then
                            s_c_syst_value  <= s_data_0; -- eh o valor atual veio pra ca
                            systole         <= '1'; 
                        else    
                            -- senao eh só mais uma diástole
                            s_c_syst_value <= s_c_syst_value; -- mantem o valor da sistole anterior
                            systole        <= '0';
                            --end if;
                        end if;
                    --end if;
                else
                    s_data_0        <= s_data_0;
                    --s_data_1        <= s_data_1;
                    s_diff          <= s_diff;
                    s_perc_comp     <= s_perc_comp;
                    s_c_syst_value  <= s_c_syst_value;
                    systole         <= '0';
                    
                end if;
            when others     =>
                s_data_0        <= (others => '0');
                --s_data_1        <= (others => '0');
                s_diff          <= (others => '0');
                s_perc_comp     <= (others => '0');
                s_c_syst_value  <= (others => '0');
                systole         <= '0';
            end case;
        end if;
    end process FSM_OUT_PROC;
   
end systole_detector_op;
