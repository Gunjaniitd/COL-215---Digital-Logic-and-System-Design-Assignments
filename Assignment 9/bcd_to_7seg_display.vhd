----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2022 12:52:16 AM
-- Design Name: 
-- Module Name: bcd_to_7seg_display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


ENTITY bcd_to_7seg_display IS
	PORT(
		bcd				:	IN		std_logic_vector(3 DOWNTO 0);		--number to display in BCD
        display_7seg	:	OUT	    std_logic_vector(6 DOWNTO 0)	--outputs to seven segment display
    );
END bcd_to_7seg_display;

ARCHITECTURE logic OF bcd_to_7seg_display IS
BEGIN

	--map bcd input to desired output segments
    PROCESS(bcd) --triggered when input bcd changes
    BEGIN
        CASE bcd IS
            WHEN "0000" => 	display_7seg <=    "0000001";
            WHEN "0001" => 	display_7seg <=    "1001111";
            WHEN "0010" => 	display_7seg <=    "0010010";
            WHEN "0011" => 	display_7seg <=    "0000110";
            WHEN "0100" => 	display_7seg <=    "1001100";
            WHEN "0101" => 	display_7seg <=    "0100100";
            WHEN "0110" => 	display_7seg <=    "0100000";
            WHEN "0111" => 	display_7seg <=    "0001111";
            WHEN "1000" =>  display_7seg <=    "0000000";
            WHEN "1001" => 	display_7seg <=    "0000100";
            WHEN "1010" => 	display_7seg <=    "0001000";	
            WHEN "1011" => 	display_7seg <=    "1100000";
            WHEN "1100" => 	display_7seg <=    "0110001";
            WHEN "1101" => 	display_7seg <=    "1000010";
            WHEN "1110" => 	display_7seg <=    "0110000";
            WHEN "1111" => 	display_7seg <=    "0111000";
            WHEN OTHERS =>  display_7seg <=    "1111111";                       
        END CASE;
	END PROCESS;
END logic;