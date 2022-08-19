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
        display_cathode :   OUT std_logic_vector(6 DOWNTO 0) := "1111111";            -- cathode outputof the 7 segments(1 means the segment is off and 0 means segment is on)
        display_anode   :   OUT std_logic_vector(3 DOWNTO 0)              -- anode output for the 4 digits
    );
END main;

ARCHITECTURE logic OF main is
   -- COMPONENT time_clk_1s IS                                    -- component for generating 1Hz signal
   --     PORT (
   --         clk     :       IN std_logic;                       -- processor clock input
   --         clk_1s  :       OUT std_logic := '0'                -- out put of 1Hz signal
   --     );
    --END COMPONENT;

    --COMPONENT time_clk_1ms IS                                   -- component for generating 1KHz singal
        --PORT (
          --  clk         :       IN std_logic;                   -- processor clock input
        --    clk_1ms     :       OUT std_logic := '0'            -- out put of 1KHz signal
      --  );
    --END COMPONENT;

    --COMPONENT time_clk_8ms IS                                   -- component for generating 125 Hz singal
    --    PORT (
    --        clk         :       IN std_logic;                   -- processor clock input
    --        clk_8ms     :       OUT std_logic           -- out put of 125 Hz signal
    --    );
    --END COMPONENT;
    
    COMPONENT time_clk_mux IS
        PORT (
            clk         :       IN std_logic;
            clk_mux     :       OUT std_logic_vector(18 DOWNTO 0)
        );
    END COMPONENT;
    
    --COMPONENT time_clk_pwm is
    --  Port
        --PORT (
      --          clk         :       IN std_logic;
     --           clk_pwm     :       OUT std_logic_vector(17 DOWNTO 0)
     --   );
   -- end COMPONENT;
    
--    COMPONENT pwm is
--    --  Port ( );
--        PORT (
--                clk_p   :   IN std_logic_vector(1 DOWNTO 0);
--                anode   :   OUT std_logic
--        );
--    end COMPONENT;



    COMPONENT bcd_to_7seg_display is                            -- component for converting bcd to cathode output of 7 segment display
        PORT(
		    bcd				:	IN	std_logic_vector(3 DOWNTO 0);   --number to display in BCD
            display_7seg	:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0)	--outputs to seven segment display
        );
    END COMPONENT;
    


    --SIGNAL clk_1ms                                              :   std_logic := '0';   -- clock signal of 1Khz
    --SIGNAL clk_1s                                               :   std_logic := '0';   -- clock signal of 1Hz
    --SIGNAL clk_8ms                                              :   std_logic := '0';   -- clock signal of 125Hz
    --SIGNAL refresh                                              :   unsigned(1 DOWNTO 0) := "00";   -- a counter used for refreshing the display every 4ms
--    SIGNAL clk_p0                                                 :   std_logic_vector(1 DOWNTO 0);
--    SIGNAL clk_p1                                                 :   std_logic_vector(1 DOWNTO 0);
--    SIGNAL clk_p2                                                 :   std_logic_vector(1 DOWNTO 0);
--    SIGNAL clk_p3                                                 :   std_logic_vector(1 DOWNTO 0);
--    SIGNAL temp_anode                                             :   std_logic_vector(3 DOWNTO 0);
    --SIGNAL clk_pwm                                                :   std_logic_vector(17 DOWNTO 0);
    SIGNAL clk_mux                                                 :    std_logic_vector(4 DOWNTO 0);
    SIGNAL clk_mux1                                                :   std_logic_vector(18 DOWNTO 0);
    SIGNAL digit1, digit2, digit3, digit4             :   std_logic_vector(6 DOWNTO 0);  -- signals which represent the cathode output version of the above signals(left1 left0 right1 right0)
    --SIGNAL count    :       unsigned(20 DOWNTO 0) := "000000000000000000000"; --counter used for n modulo counter
    --SIGNAL temp     :       std_logic := '0'; --temp holds the value of clock of 125hz which is used during execution, as clk_8ms can't be used

BEGIN
    --create_1s_clock: time_clk_1s port map (clk, clk_1s);        -- initialization to generate signal of 1Hz
    --create_1ms_clock: time_clk_1ms port map (clk, clk_1ms);     -- initialization to generate singal of 1KHz
    --create_8ms_clock: time_clk_8ms port map (clk => clk, clk_8ms => clk_8ms);     -- initialization to generate signal of 125 Hz
    
    create_mux_clock: time_clk_mux port map (clk => clk, clk_mux => clk_mux1);
    
    clk_mux <= clk_mux1(18 downto 14);
    
    --create_pwm_clock: time_clk_pwm port map (clk => clk, clk_pwm => clk_pwm);
    
    
    --PROCESS(clk)    --triggered when clk changes
            --BEGIN
                --IF (rising_edge(clk)) THEN  --process only runs on rising edge of clk
                    --IF (count = "001100001101001111111") THEN --if count = 399999(100M/(125*2) - 1), count is made zero and clk_8ms and temp flipped
                     --   count <="000000000000000000000";
                        --IF (temp = '0') THEN --if temp was 0, then clk_8ms was also 0, and thus both are flipped and vice versa for if temp was 1
                        --    clk_8ms <= '1';
                        --    temp <= '1';
                        --ELSE
                        --    clk_8ms <= '0';
                        --    temp <= '0';
                        --END IF;
                        --clk_8ms <= not clk_8ms;
                    --ELSE 
                        --count <= count + 1; -- else count is increased by 1
                    --END IF;
                --END IF;
            --END PROCESS;
    drive_display_1: bcd_to_7seg_display port map(bcd => input1, display_7seg => digit1); --takes left1 bcd as input and outputs seven segment output segleft1  
    drive_display_2: bcd_to_7seg_display port map(bcd => input2, display_7seg => digit2); --takes left0 bcd as input and outputs seven segment output segleft0  
    drive_display_3: bcd_to_7seg_display port map(bcd => input3, display_7seg => digit3); --takes right1 bcd as input and outputs seven segment output segright1
    drive_display_4: bcd_to_7seg_display port map(bcd => input4, display_7seg => digit4); --takes right0 bcd as input and outputs seven segment output segright0
    
    PROCESS(clk_mux) --this is the process used to refresh the display with updated numbers and switch between each digit every 4ms
        BEGIN
        --display_anode <= "1111";    -- all anodes are turned off in the beginning
            
            IF clk_mux = "00000" THEN              -- if 1st digit is to be displayed, send the corresponding values to the output
                display_cathode <= digit1;
                --IF temp_anode(3) = '0' THEN    
                    display_anode <= "0111";
                --ELSE
                    --display_anode <= "1111";
                --END IF;
                --refresh <= "01";        -- turns on 1st digit
            ELSIF clk_mux > "00000" AND clk_mux < "00100" THEN
            --ELSIF clk_mux = "0001" OR clk_mux = "0010" OR clk_mux = "0111" THEN           -- if 2nd digit is to be displayed, send the corresponding values to the output
                display_cathode <= digit2;
                --IF temp_anode(2) = '0' THEN    
                    display_anode <= "1011";
                --ELSE
                    --display_anode <= "1111";
                --END IF;
                --refresh <= "10";         -- turns on 2nd digit
            ELSIF clk_mux > "00011" AND clk_mux < "01100" THEN
            --ELSIF clk_mux = "0110" OR clk_mux = "0011" OR clk_mux = "0100" OR clk_mux = "0101" OR clk_mux = "1000" THEN           -- if 3rd digit is to be displayed, send the corresponding values to the output
                display_cathode <= digit3;
                --IF temp_anode(1) = '0' THEN    
                    display_anode <= "1101";
                --ELSE
                    --display_anode <= "1111";
                --END IF;  
                --refresh <= "11";       -- turns on 3rd digit
            ELSE                                -- if 4th digit is to be displayed, send the corresponding values to the output
                display_cathode <= digit4;  
                --IF temp_anode(0) = '0' THEN    
                    display_anode <= "1110";
                --ELSE
                    --display_anode <= "1111";
                --END IF;
                --refresh <= "00";        -- turns on 4th digit
            END IF;
            
            --IF refresh = "11" THEN  -- if the digit is being displayed is 4th, change the digit to be displayed to 1st
            --    refresh <= "00";
            --ELSE                    -- else increase the counter by 1 to change the digit to be displayed(the next digit)
             --   refresh <= refresh + 1; 
            --END IF;


        END PROCESS;
        
    
--    clk_p0(1) <= clk_mux1(14);
--    clk_p0(0) <= clk_mux1(0);
    
--    clk_p1(1) <= clk_mux1(15);
--    clk_p1(0) <= clk_mux1(0);
        
--    clk_p2(1) <= clk_mux1(16);
--    clk_p2(0) <= clk_mux1(0);
            
--    clk_p3(1) <= clk_mux1(16);
--    clk_p3(0) <= clk_mux1(16);
    
--    pwm_display_0 : pwm port map (clk_p => clk_p0, anode => temp_anode(3));
--    pwm_display_1 : pwm port map (clk_p => clk_p1, anode => temp_anode(2));
--    pwm_display_2 : pwm port map (clk_p => clk_p2, anode => temp_anode(1));
--    pwm_display_3 : pwm port map (clk_p => clk_p3, anode => temp_anode(0));
    
    
    
    

    
    


END logic;

                    
        
                

            

        