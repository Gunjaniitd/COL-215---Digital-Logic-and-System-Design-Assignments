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
--        btnC                :   IN  std_logic;
--        btnU                :   IN  std_logic;
--        btnL                :   IN  std_logic;
        RsRx            :   IN std_logic;
        RsTx            :   OUT std_logic;
        display_cathode :   OUT std_logic_vector(6 DOWNTO 0) := "1111111";            -- cathode outputof the 7 segments(1 means the segment is off and 0 means segment is on)
        display_anode   :   OUT std_logic_vector(3 DOWNTO 0) := "1111"              -- anode output for the 4 digits
    );
END main;

ARCHITECTURE logic OF main is

    type states is (idle, start_bit, data_bits,
                     stop_bit, s_cleanup);
                     
     signal recv_state, trans_state : states := idle; --set it to idle, thus it is gonna start in an idle state
     
     --signal trans_state : states := idle;

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
    
    --SIGNAL tenth, sec1, sec2, min                      : std_logic_vector(3 DOWNTO 0) := "0000";
    SIGNAL numb1, numb2                                             : std_logic_vector(3 DOWNTO 0) := "0000";
   
    SIGNAL clk_mux                                                 : integer;
--    SIGNAL clk_cycle                                               : std_logic_vector(1 DOWNTO 0);
    SIGNAL clk_mux1                                                : std_logic_vector(30 DOWNTO 0);
    
    --SIGNAL tenhz                                                     : std_logic;
--    SIGNAL bt1, bt2, bt3, bt4                                      : std_logic_vector(1 DOWNTO 0) := "00";
--    SIGNAL btt1, btt2, btt3, btt4                                  : integer := 0;
   
--    SIGNAL digit, digit1, digit2, digit3, digit4                   : std_logic_vector(6 DOWNTO 0);  -- signals which represent the cathode output version of the above signals(left1 left0 right1 right0)
    SIGNAL dig1, dig2, dig3, dig4                                  : std_logic_vector(6 DOWNTO 0);
    
    SIGNAL reset                                                    : std_logic := '1';
    SIGNAL counter, counter1                                                  : std_logic_vector(9 DOWNTO 0) := "0000000000" ;
    SIGNAL bit_counter, bit_counter1                                              : std_logic_vector(4 DOWNTO 0) := "00000";
    SIGNAL data_counter, data_counter1                                              : std_logic_vector(4 DOWNTO 0) := "00000";
    SIGNAL data, trans_buff                                                     : std_logic_vector(7 DOWNTO 0) := "00000000";
    signal flag                                                        : std_logic := '0';

BEGIN

    --RsTx <= RsRx;
    create_mux_clock: time_clk_mux port map (clk => clk, clk_mux => clk_mux1);
    
    clk_mux <= to_integer(unsigned(clk_mux1(16 downto 16)));
    
    drive_display_1: bcd_to_7seg_display port map(bcd => numb1, display_7seg => dig1); --takes left1 bcd as input and outputs seven segment output segleft1  
    drive_display_2: bcd_to_7seg_display port map(bcd => numb2, display_7seg => dig2); --takes left0 bcd as input and outputs seven segment output segleft0  
    --drive_display_3: bcd_to_7seg_display port map(bcd => sec2, display_7seg => dig3); --takes right1 bcd as input and outputs seven segment output segright1
    --drive_display_4: bcd_to_7seg_display port map(bcd => min, display_7seg => dig4); --takes right0 bcd as input and outputs seven segment output segright0
    
    PROCESS(clk_mux) --this is the process used to refresh the display with updated numbers and switch between each digit every 4ms
        BEGIN
--            IF enable = '1' THEN
                IF clk_mux = 0 THEN              -- if 1st digit is to be displayed, send the corresponding values to the output
                    display_cathode <= dig1;   
                    display_anode <= "0111";
                    dp <= '1';
                ELSIF clk_mux = 1  THEN
                    display_cathode <= dig2;   
                    display_anode <= "1011";
                    dp <= '1';
--                ELSIF clk_mux = 2 THEN
--                    display_cathode <= dig3;
--                    display_anode <= "1101";
--                    dp <= '1';
--                ELSIF clk_mux = 3 THEN                                -- if 4th digit is to be displayed, send the corresponding values to the output
--                    display_cathode <= dig4;  
--                    display_anode <= "1110";
--                    dp <= '0';
                ELSE
                    display_anode <= "1111";
                END IF;
--            ELSE
--                display_anode <= "1111";
--            END IF;
    END PROCESS;
    
--    PROCESS(clk_mux)
--        BEGIN
--            IF btnC = '1' THEN
--                reset <= '0';
--                enable <= '1';
--            END IF;
--            IF btnU = '1' THEN
--                enable <= '0';
--            END IF;
--            IF btnL = '1' THEN
--                reset <= '1';
--                --enable <= '0';
   
--            END IF;
--    END PROCESS;
    
    

    PROCESS(clk)
    BEGIN
        if rising_edge(clk) then
            if counter = "1010001011" then
                counter <= "0000000000";
                
                case recv_state is
                    when idle =>
                        flag <= '0'; 
                        if RsRx = '1' then
                            recv_state <= idle;
                            bit_counter <= "00000";
                        elsif RsRx = '0' then
                            if bit_counter = "00111" then
                                recv_state <= data_bits;
                                bit_counter <= "00000";
                                data_counter <= "00000";
                            else
                                recv_state <= idle;
                                bit_counter <= bit_counter +1;
                            end if;
                        end if;
                        
                    when data_bits =>
                        if bit_counter < "01111" then
                            bit_counter <= bit_counter + 1;
                            recv_state <= data_bits;
                        else 
                           data <= RsRx & data(7 DOWNTO 1);
                           if data_counter < "00111" then
                                data_counter <= data_counter + 1;
                                recv_state <= data_bits;
                                bit_counter <= "00000";
                           else
                                
                                recv_state <= stop_bit;
                                bit_counter <= "00000";
                                data_counter <= "00000";
                            end if;
                        end if;
                    when stop_bit =>
                        if bit_counter = "00000" then
                            numb2 <= data(7 DOWNTO 4);
                            numb1 <= data(3 DOWNTO 0);
                            bit_counter <= bit_counter +1;
                            recv_state <= stop_bit;
                            flag <= '1';
                            --trans_buff <= data;
                        elsif bit_counter < "10111" then
                            bit_counter <= bit_counter + 1;
                            recv_state <= stop_bit;
                        else
                            bit_counter <= "00000";
                            recv_state <= idle;
                        end if;
                    when others =>
                         recv_state <= idle;
                 end case;
             else
                counter <= counter +1;
            end if;
        end if;
    END process;
    
   PROCESS(clk)
        BEGIN
            if rising_edge(clk) then
                if counter1 = "1010001011" then
                    counter1 <= "0000000000";
                    
                    case trans_state is
                        when idle =>                                        -- idle state
--                            if RsRx = '1' then
--                                recv_state <= idle;
--                                bit_counter <= "00000";
                            RsTx <= '1';
                            if flag = '1' then                              -- goes to start bit state when flag becomes 1. flag is set by the receiver when it reaches stop bit
                                trans_state <= start_bit;
                                trans_buff <= data;                         -- data to be transferred is copied
                        
                            end if;
                            bit_counter1 <= "00000";
                            data_counter1 <= "00000";
                            
                            
                        when start_bit =>
                            --if RsRx = '0' then
                                RsTx <= '0';
                                if bit_counter1 = "01111" then              --Tx is set to 0 for 16 steps (start bit), and then proceeds to data bits state
                                    trans_state <= data_bits;
                                    bit_counter1 <= "00000";
                                    data_counter1 <= "00000";
                                else
                                    trans_state <= start_bit;
                                    bit_counter1 <= bit_counter1 +1;
                                end if;
                            --end if;
                            
                        when data_bits =>
--                            if bit_counter < "01111" then
--                                bit_counter <= bit_counter + 1;
--                                recv_state <= data_bits;
--                            else 
--                               data <= RsRx & data(7 DOWNTO 1);
--                               if data_counter < "00111" then
--                                    data_counter <= data_counter + 1;
--                                    recv_state <= data_bits;
--                                    bit_counter <= "00000";
--                               else
                                    
--                                    recv_state <= stop_bit;
--                                    bit_counter <= "00000";
--                                    data_counter <= "00000";
--                                end if;
--                            end if;
                            RsTx <= trans_buff(0);                      -- data is set as the rightmost bit
                            if bit_counter1 < "01111" then      
                                bit_counter1 <= bit_counter1 + 1;
                                trans_state <= data_bits;
                                
                            else 
                                trans_buff <= '0' & trans_buff(7 DOWNTO 1);         -- when a bit is over, the trans_buff is right shifted
                                if data_counter1 < "00111" then
                                    data_counter1 <= data_counter1 + 1;
                                    trans_state <= data_bits;
                                    bit_counter1 <= "00000";
                               else
                                         
                                 trans_state <= stop_bit;                   -- when data is sent, it goes to stop bit
                                 bit_counter1 <= "00000";
                                 data_counter1 <= "00000";
                               end if;
                            end if;
                                    
                        when stop_bit =>
                            RsTx <= '1';
--                            if bit_counter1 = "00000" then
--                                --numb2 <= data(7 DOWNTO 4);
--                                --numb1 <= data(3 DOWNTO 0);
--                                bit_counter1 <= bit_counter1 +1;
--                                trans_state <= stop_bit;
                            if bit_counter1 < "01111" then                  -- stop bit '1' is sent for 16 timesteps and then goes to idle
                                bit_counter1 <= bit_counter1 + 1;
                                trans_state <= stop_bit;
                            else
                                bit_counter1 <= "00000";
                                trans_state <= idle;
                            end if;
                        when others =>
                             trans_state <= idle;
                     end case;
                 else
                    counter1 <= counter1 +1;
                end if;
            end if;
        END process;
                    
    --tenhz <= clk_mux1(0);
--    PROCESS(clk)
--    BEGIN
--        if (rising_edge(clk)) then
--                if reset ='0' then
--                    if counter = "100110001001011010000000" then
--                        counter <= "000000000000000000000000";
--        --                clock_t <= not clock_t;
--                        if (enable = '1')  then
--                            if tenth < "1001" then
--                                tenth <= tenth+1;
--                            else
--                                tenth <= "0000";
--                                if (sec1 < "1001") then 
--                                    sec1 <= sec1 + 1;
--                                else 
--                                    sec1 <= "0000";
--                                    if (sec2 < "0101") then 
--                                        sec2 <= sec2 + 1;
--                                    else
--                                        sec2 <= "0000";
--                                        if (min < "1001") then 
--                                            min <= min + 1;
--                                        else 
--                                            min<="0000";
--                                        end if;
--                                    end if;
--                                end if;
--                            end if;
--                        end if;
--                    else
--                        counter <= counter+1;
--                    end if;
--                else
--                    tenth <= "0000";
--                    sec1 <= "0000";
--                    sec2 <= "0000";
--                    min <= "0000";
--                    --counter <= counter+1;
--                    counter <= "000000000000000000000000";
--                end if;
--            end if;
--    end process;
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
