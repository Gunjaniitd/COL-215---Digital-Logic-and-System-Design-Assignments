LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY main IS
    PORT (
        clk             :   IN  std_logic;                                            --clock of 100 Mhz
        input1				:	IN	std_logic_vector(3 DOWNTO 0);
        input2				:	IN	std_logic_vector(3 DOWNTO 0);    
        input3				:	IN	std_logic_vector(3 DOWNTO 0);       
        input4				:	IN	std_logic_vector(3 DOWNTO 0);                                                  --button inputs (of 1, 2, 3, 4 respectively)
        btnC                :   IN  std_logic;
        btnU                :   IN  std_logic;
        display_cathode :   OUT std_logic_vector(6 DOWNTO 0) := "1111111";            -- cathode outputof the 7 segments(1 means the segment is off and 0 means segment is on)
        display_anode   :   OUT std_logic_vector(3 DOWNTO 0) := "1111"              -- anode output for the 4 digits
    );
END main;

ARCHITECTURE logic OF main is

    COMPONENT time_clk_mux IS
        PORT (
            clk         :       IN std_logic;
            clk_mux     :       OUT std_logic_vector(30 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT bcd_to_7seg_display is                            -- component for converting bcd to cathode output of 7 segment display
        PORT(
		    bcd				:	IN	std_logic_vector(3 DOWNTO 0);   --number to display in BCD
            display_7seg	:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0)	--outputs to seven segment display
        );
    END COMPONENT;
    
    SIGNAL enable                                                  : std_logic := '0';
    
    SIGNAL number1, number2, number3, number4                      : std_logic_vector(3 DOWNTO 0) := "0000";
   
    SIGNAL clk_mux                                                 : integer;
    SIGNAL clk_cycle                                               : std_logic_vector(1 DOWNTO 0);
    SIGNAL clk_mux1                                                : std_logic_vector(30 DOWNTO 0);
    SIGNAL bt1, bt2, bt3, bt4                                      : std_logic_vector(1 DOWNTO 0) := "00";
    SIGNAL btt1, btt2, btt3, btt4                                  : integer := 0;
   
    SIGNAL digit, digit1, digit2, digit3, digit4                   : std_logic_vector(6 DOWNTO 0);  -- signals which represent the cathode output version of the above signals(left1 left0 right1 right0)
    SIGNAL dig1, dig2, dig3, dig4                                  : std_logic_vector(6 DOWNTO 0);

BEGIN
    create_mux_clock: time_clk_mux port map (clk => clk, clk_mux => clk_mux1);
    
    clk_mux <= to_integer(unsigned(clk_mux1(19 downto 15)));
    
    drive_display_1: bcd_to_7seg_display port map(bcd => number1, display_7seg => dig1); --takes number1 bcd as input and outputs seven segment output segleft1  
    drive_display_2: bcd_to_7seg_display port map(bcd => number2, display_7seg => dig2); --takes number2 bcd as input and outputs seven segment output segleft0  
    drive_display_3: bcd_to_7seg_display port map(bcd => number3, display_7seg => dig3); --takes number3 bcd as input and outputs seven segment output segright1
    drive_display_4: bcd_to_7seg_display port map(bcd => number4, display_7seg => dig4); --takes number4 bcd as input and outputs seven segment output segright0
    
    PROCESS(clk_mux) --this is the process used to refresh the display with updated numbers and switch between each digit every 4ms
        BEGIN          -- btt signals determine the length of the time the digit stays on in the time alloted to each digit(1/4)
            IF enable = '1' THEN
                IF clk_mux >= 0 AND clk_mux < btt1  THEN              -- if 1st digit is to be displayed, send the corresponding values to the output
                    display_cathode <= digit1;   
                    display_anode <= "0111";
                ELSIF clk_mux >= 8 AND clk_mux < 8 + btt2 THEN       -- if 2nd digit is to be displayed, send the corresponding values to the output
                    display_cathode <= digit2;   
                    display_anode <= "1011";
                ELSIF clk_mux >= 16 AND clk_mux < 16 + btt3 THEN       -- if 3rd digit is to be displayed, send the corresponding values to the output
                    display_cathode <= digit3;
                    display_anode <= "1101";
                ELSIF clk_mux >= 24 AND clk_mux < 24 + btt4 THEN                                -- if 4th digit is to be displayed, send the corresponding values to the output
                    display_cathode <= digit4;  
                    display_anode <= "1110";
                ELSE                                                --disable anode when all numbers are out(brightness control)
                    display_anode <= "1111";
                END IF;
            ELSE
                display_anode <= "1111";
            END IF;
    END PROCESS;
    
    PROCESS(clk_mux)
        BEGIN
            IF btnC = '1' THEN                          -- take input from switches for the digits
                number1 <= input1;
                number2 <= input2;  
                number3 <= input3;  
                number4 <= input4;
            END IF;
    END PROCESS;
    
    PROCESS(clk_mux)
        BEGIN
        IF btnU = '1' THEN                          -- take input from switches for brightness
            bt1     <= input1(1 DOWNTO 0);
            bt2     <= input1(3 DOWNTO 2);
            bt3     <= input2(1 DOWNTO 0);
            bt4     <= input2(3 DOWNTO 2);
            enable  <= '1';
        END IF;
    END PROCESS;
    
    
    clk_cycle <= clk_mux1(28 DOWNTO 27);
    PROCESS(clk_cycle)                                                      -- cycling through the numbers and assign each number 
        BEGIN                                                               -- and its associated brightness to  a specific display according to clk_cycle
            IF clk_cycle = "00" THEN
                digit1 <= dig1;
                btt1 <= 2**to_integer(unsigned(bt1));                       -- 2 to the power for an extra difference in brightness
                
                digit2 <= dig2;
                btt2 <= 2**to_integer(unsigned(bt2));

                digit3 <= dig3;
                btt3 <= 2**to_integer(unsigned(bt3));

                digit4 <= dig4;
                btt4 <= 2**to_integer(unsigned(bt4));
            ELSIF clk_cycle = "01" THEN
                digit2 <= dig1;
                btt2 <= 2**to_integer(unsigned(bt1));
                
                digit3 <= dig2;
                btt3 <= 2**to_integer(unsigned(bt2));
    
                digit4 <= dig3;
                btt4 <= 2**to_integer(unsigned(bt3));
    
                digit1 <= dig4;
                btt1 <= 2**to_integer(unsigned(bt4));
             ELSIF clk_cycle = "10" THEN
             
                 digit3 <= dig1;
                 btt3 <= 2**to_integer(unsigned(bt1));
                 
                 digit4 <= dig2;
                 btt4 <= 2**to_integer(unsigned(bt2));
    
                 digit1 <= dig3;
                 btt1 <= 2**to_integer(unsigned(bt3));
    
                 digit2 <= dig4;
                 btt2 <= 2**to_integer(unsigned(bt4));
             ELSIF clk_cycle = "11" THEN
                 digit4 <= dig1;
                 btt4 <= 2**to_integer(unsigned(bt1));
                 
                 digit1 <= dig2;
                 btt1 <= 2**to_integer(unsigned(bt2));
    
                 digit2 <= dig3;
                 btt2 <= 2**to_integer(unsigned(bt3));
    
                 digit3 <= dig4;
                 btt3 <= 2**to_integer(unsigned(bt4));
             END IF;
     END PROCESS;

END logic;

                    
        
                

            

        