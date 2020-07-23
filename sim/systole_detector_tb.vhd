library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.std_logic_arith.all;
    use std.textio.all;

use work.systole_detector_pkg.all;
use work.global_constants_pkg.all;

entity systole_detector_tb is
end entity systole_detector_tb;

architecture Behavioral of systole_detector_tb is

    -- Testbench files ---------------------------------------------------------
    --! Input data generated in Matlab
    file data_in        :  text open read_mode is "frequencimetro/golden/data_bin.txt";
    --! Output data with systoles
    --file data_out       :  text open write_mode is "frequencimetro/golden/data_out.txt";

    -- Testbench signals -------------------------------------------------------
    signal s_clk_cnt      : integer   := 0;
    signal s_rst_done     : boolean   := FALSE;
    -- Input signals -------------------------------------------------------    
    signal s_clk          :  std_logic := '0';
    signal s_clk_stop     :  boolean   := FALSE;
    signal s_rst_n        :  std_logic := '1';
    signal s_start        :  std_logic := '0';
    signal s_peak         :  std_logic := '0';
    signal s_peak_value   :  std_logic_vector (DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_diff:     	 	std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_data_0:   		std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_data_1:   		std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    -- Output signals -------------------------------------------------------
    signal s_systole      :  std_logic;

    begin
        --s_clk <= not s_clk after CLK_HALF_PERIOD;

        DUT: systole_detector
            port map(
                clk        => s_clk,
                rst_n      => s_rst_n,
                start      => s_start,
                peak       => s_peak,
                peak_value => s_peak_value,
                systole    => s_systole
            );

        --! Process to generate clock signal while there is still stimulus in file
        CLOCKING: process (s_clk_stop, s_clk)
        begin
            if (not s_clk_stop) then
                s_clk <= not s_clk after CLK_HALF_PERIOD;
            else
                s_clk <= s_clk;
            end if;
        end process CLOCKING;

        --! This process keeps track of elapsed time
        TIMING: process (s_clk)
        begin
            if (rising_edge(s_clk)) then
                s_clk_cnt <= s_clk_cnt + 1;
            else
                s_clk_cnt <= s_clk_cnt;
            end if;
        end process TIMING;

        ENABLE_PROC: process(s_clk)
        variable data_in_line   : line;
        --variable data_out_line  : line;
        variable data_input     : std_logic_vector (7 downto 0);

        begin
            if (rising_edge(s_clk)) then
                if ((s_rst_n = '1') and (s_clk_cnt < RST_CLK_CNT)) then
                    s_rst_n    <= '0';
                    s_start    <= '0';
                    s_peak     <= '0';
                    s_diff     <= (others => '0');
                    s_rst_done <= FALSE;
                elsif (s_clk_cnt < RST_CLK_CNT) then
                    s_rst_n    <= '0';
                    s_start    <= '0';
                    s_peak     <= '0';
                    s_diff     <= (others => '0');
                    s_rst_done <= FALSE;
                else
                    s_rst_n    <= '1';
                    s_start    <= '1';
                    s_peak     <= s_peak;
                    s_diff     <= s_diff;
                    s_rst_done <= TRUE;
                end if;

                if (not endfile(data_in)) then
                    for i in data_input'range loop
                        readline(data_in, data_in_line);
                        read(data_in_line, data_input);
                         
                        s_data_0 <= data_input;
                        s_data_1 <= s_data_0;

                        s_diff <= (signed(s_data_0) - signed(s_data_1));
                        s_peak <= s_diff(7);
                    end loop;

                    s_peak_value <= std_logic_vector(data_input(7 downto 0));
                else
                    file_close(data_in);

                    assert false report
                    LF & "#######################################" &
                    LF & "########## END OF SIMULATION ##########" &
                    LF & "#######################################"
                    severity failure;
                    s_clk_stop <= TRUE;
                    
                end if;
            end if;                
        end process ENABLE_PROC;
end architecture Behavioral;


-- 1: se rst = 0 (ativado), start = 0 (desativado), depois disso é constante em 1
-- 2: fiz uma gambiarra temporaria, se pa vamos precisar dele no arquivo de entrada
-- (a partir da linha 101). To representando o pico da mesma forma que ele tá no
-- codigo do peak_detector se pa tem que mudar depois
-- 3: precisa fazer alguns ajustes, mas no geral tá quase funcionando!!!
-- 4: no clk 23 tem um calculo sendo feito errado, precisa checar isso melhor
-- 5: s_clk_stop nao vai pra TRUE no final da simulação, mas isso nao trouxe
-- nenhuma complicacao pro funcionamento do sistema
-- 6: s_rst_done é só uma flag pra dizer que o teste do sistema no reset foi feito
-- 7: tem que arrumar alguns sinais no rst também, mas nao é nada mt critico
-- 8: ainda nao botei pra gerar arquivo de saida, mas assim que tiver tudo pronto
-- eu coloco
-- 9: nao esquecer de mudar os numeros hard coded pras constantes que tem nos pkg
-- se pa precisa arrumar o pkg, pq ta dando conflito de dependencia por conta de
-- uma constante (DATA_WIDTH)
-- sugestao: seria bom ver se o sistema em matlab consegue falar onde ta o pico
-- e a sistole, pq ai em vhdl a gente so ia conferir isso
