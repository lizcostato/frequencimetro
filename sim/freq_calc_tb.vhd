library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;


use work.freq_calc_pkg.all;
use work.global_constants_pkg.all;

entity freq_calc_tb is
end entity freq_calc_tb;

architecture Behavioral of freq_calc_tb is
	component freq_calc is
		port(
			-- Inputs ---------------------------------------------------
			clk			:   in std_logic;
			rst_n       :   in std_logic;
			start       :   in std_logic;
			peak   		:   in std_logic;
			data_in     :   in std_logic_vector(DATA_WIDTH - 1 downto 0);
			-- Outputs --------------------------------------------------
			systole   :   out std_logic
		);
	end component freq_calc;
		
	
    file data_in:        text open read_mode is "C:\Users\Administrador\Documents\UNB\quinto_semestre\Topicos_em_Engenharia\Frequencimetro\Freq_Calc\data_in.out";
    file data_out:       text open write_mode is "C:\Users\Administrador\Documents\UNB\quinto_semestre\Topicos_em_Engenharia\Frequencimetro\Freq_Calc\data_out.out";
    
    signal s_clk:     		std_logic := '0';
	signal s_rst_n:			std_logic := '0';
    signal s_start:         std_logic := '0';
    signal s_systole:       std_logic := '0';
    signal s_ack_out:       std_logic := '0';
    signal s_freq:      	integer range MIN_FREQ to MAX_FREQ := 0;
	
	--constant CLK_HALF_PERIOD:  time := 0.05 ns;
    
begin
    s_clk <= not s_clk after CLK_HALF_PERIOD;
    DUT: freq_calc
        port map(
			clk => s_clk,
			rst_n => s_rst_n,
			start => s_start,
			systole => s_systole,
			ack_out => s_ack_out,
			freq => s_freq
        );
    
    enable_proc: process(s_clk)
    variable data_in_line: line;
    variable data_out_line: line;
    variable data_input: std_logic_vector (10 downto 0);
    begin
        if (not endfile(data_in)) then
            if (rising_edge(s_clk)) then
                readline(data_in, data_in_line);
                read(data_in_line, data_input);
                s_start <= std_logic(data_input(0));
                s_systole <= data_input(1);
				s_rst_n <= data_input(2);
                write(data_out_line, s_freq, right, 1);
                writeline(data_out, data_out_line);
            end if;
        else
            file_close(data_in);
            file_close(data_out);
            assert false report
            LF & "###########################################" &
            LF & "########## END OF SIMULATION ##############" &
            LF & "###########################################"
            severity failure;           
        end if;
    end process enable_proc;
    
end architecture Behavioral;