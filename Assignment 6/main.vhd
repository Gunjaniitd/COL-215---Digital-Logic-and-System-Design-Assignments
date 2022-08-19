LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY main IS
    PORT (
        clk             :   IN  std_logic;                                            --clock of 100 Mhz
--        input1				:	IN	std_logic_vector(3 DOWNTO 0);
--        input2				:	IN	std_logic_vector(3 DOWNTO 0);    
--        input3				:	IN	std_logic_vector(3 DOWNTO 0);       
--        input4				:	IN	std_logic_vector(3 DOWNTO 0);                                                  --button inputs (of 1, 2, 3, 4 respectively)
        dp                  :   OUT std_logic;                 
        btnC                :   IN  std_logic;
        btnU                :   IN  std_logic;
        btnL                :   IN  std_logic;
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
    
    SIGNAL enable                                                  : std_logic := '1';
    
    SIGNAL tenth, sec1, sec2, min                      : std_logic_vector(3 DOWNTO 0) := "0000";
   
    SIGNAL clk_mux                                                 : integer;
--    SIGNAL clk_cycle                                               : std_logic_vector(1 DOWNTO 0);
    SIGNAL clk_mux1                                                : std_logic_vector(30 DOWNTO 0);
    
    --SIGNAL tenhz                                                     : std_logic;
--    SIGNAL bt1, bt2, bt3, bt4                                      : std_logic_vector(1 DOWNTO 0) := "00";
--    SIGNAL btt1, btt2, btt3, btt4                                  : integer := 0;
   
--    SIGNAL digit, digit1, digit2, digit3, digit4                   : std_logic_vector(6 DOWNTO 0);  -- signals which represent the cathode output version of the above signals(left1 left0 right1 right0)
    SIGNAL dig1, dig2, dig3, dig4                                  : std_logic_vector(6 DOWNTO 0);
    
    SIGNAL reset                                                    : std_logic := '1';
    SIGNAL counter                                                  : std_logic_vector(23 DOWNTO 0) := "000000000000000000000000" ;

BEGIN
    create_mux_clock: time_clk_mux port map (clk => clk, clk_mux => clk_mux1);
    
    clk_mux <= to_integer(unsigned(clk_mux1(16 downto 15)));
    
    drive_display_1: bcd_to_7seg_display port map(bcd => tenth, display_7seg => dig1); --takes tenth bcd as input and outputs seven segment output segleft1  
    drive_display_2: bcd_to_7seg_display port map(bcd => sec1, display_7seg => dig2); --takes sec1 bcd as input and outputs seven segment output segleft0  
    drive_display_3: bcd_to_7seg_display port map(bcd => sec2, display_7seg => dig3); --takes sec2 bcd as input and outputs seven segment output segright1
    drive_display_4: bcd_to_7seg_display port map(bcd => min, display_7seg => dig4); --takes min bcd as input and outputs seven segment output segright0
    
    PROCESS(clk_mux) --this is the process used to refresh the display with updated numbers and switch between each digit every 4ms
        BEGIN
--            IF enable = '1' THEN
                IF clk_mux = 0 THEN              -- if 1st digit is to be displayed, send the corresponding values to the output
                    display_cathode <= dig1;   
                    display_anode <= "0111";
                    dp <= '1';
                ELSIF clk_mux = 1  THEN         -- if 2nd digit is to be displayed, send the corresponding values to the output
                    display_cathode <= dig2;   
                    display_anode <= "1011";
                    dp <= '0';
                ELSIF clk_mux = 2 THEN          -- if 3rd digit is to be displayed, send the corresponding values to the output
                    display_cathode <= dig3;
                    display_anode <= "1101";
                    dp <= '1';
                ELSIF clk_mux = 3 THEN          -- if 4th digit is to be displayed, send the corresponding values to the output
                    display_cathode <= dig4;  
                    display_anode <= "1110";
                    dp <= '0';
                ELSE
                    display_anode <= "1111";
                END IF;
--            ELSE
--                display_anode <= "1111";
--            END IF;
    END PROCESS;
    
    PROCESS(clk_mux)
        BEGIN
            IF btnC = '1' THEN              -- start button, putting reset to 0 to start time
                reset <= '0';
                enable <= '1';
            END IF;
            IF btnU = '1' THEN              -- pause, pausing by making enable 0
                enable <= '0';
            END IF;
            IF btnL = '1' THEN              -- reset, putting reset =1
                reset <= '1';
                --enable <= '0';
   
            END IF;
    END PROCESS;
    
    

    
    --tenhz <= clk_mux1(0);
    PROCESS(clk)                -- using clk(100MHz) to count time using counter
    BEGIN
        if (rising_edge(clk)) then
                if reset ='0' then      --starts countime time only when reset is 0
                    if counter = "100110001001011010000000" then -- convert it into 10 hz signal
                        counter <= "000000000000000000000000";
        --                clock_t <= not clock_t;
                        if (enable = '1')  then         --used for pausing stopwatch
                            if tenth < "1001" then
                                tenth <= tenth+1;       -- increment
                            else
                                tenth <= "0000";        --increment the next unit (at 9)
                                if (sec1 < "1001") then 
                                    sec1 <= sec1 + 1;   --increment
                                else 
                                    sec1 <= "0000";     --else increment the enxt unit at(9)
                                    if (sec2 < "0101") then 
                                        sec2 <= sec2 + 1;       --increment
                                    else
                                        sec2 <= "0000";     --else increment the next unit at 5
                                        if (min < "1001") then 
                                            min <= min + 1;     --increment
                                        else 
                                            min<="0000";        --reset the minutes to 0 when it reaches 9
                                        end if;
                                    end if;
                                end if;
                            end if;
                        end if;
                    else
                        counter <= counter+1;
                    end if;
                else            --reset button pressed, all untits are reset
                    tenth <= "0000";    
                    sec1 <= "0000";
                    sec2 <= "0000";
                    min <= "0000";
                    --counter <= counter+1;
                    counter <= "000000000000000000000000";
                end if;
            end if;
    end process;
--    clk_cycle <= clk_mux1(28 DOWNTO 27);
--    PROCESS(clk_cycle)
--        BEGIN
--            IF clk_cycle = "00" THEN
--                digit1 <= dig1;
--                btt1 <= 2**to_integer(unsigned(bt1));
                
--                digit2 <= dig2;
--                btt2 <= 2**to_integer(unsigned(bt2));

--                digit3 <= dig3;
--                btt3 <= 2**to_integer(unsigned(bt3));

--                digit4 <= dig4;
--                btt4 <= 2**to_integer(unsigned(bt4));
--            ELSIF clk_cycle = "01" THEN
--                digit2 <= dig1;
--                btt2 <= 2**to_integer(unsigned(bt1));
                
--                digit3 <= dig2;
--                btt3 <= 2**to_integer(unsigned(bt2));
    
--                digit4 <= dig3;
--                btt4 <= 2**to_integer(unsigned(bt3));
    
--                digit1 <= dig4;
--                btt1 <= 2**to_integer(unsigned(bt4));
--             ELSIF clk_cycle = "10" THEN
             
--                 digit3 <= dig1;
--                 btt3 <= 2**to_integer(unsigned(bt1));
                 
--                 digit4 <= dig2;
--                 btt4 <= 2**to_integer(unsigned(bt2));
    
--                 digit1 <= dig3;
--                 btt1 <= 2**to_integer(

END logic;
