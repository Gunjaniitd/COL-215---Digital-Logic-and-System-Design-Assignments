----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2022 10:20:23 PM
-- Design Name: 
-- Module Name: time_clk_mux - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_clk_mux is
--  Port
    PORT (
            clk         :       IN std_logic;
            clk_mux     :       OUT std_logic_vector(18 DOWNTO 0)
    );
end time_clk_mux;

architecture Behavioral of time_clk_mux is
    
    SIGNAL count    :       std_logic_vector(18 DOWNTO 0) := "0000000000000000000"; --counter used for n modulo counter

begin

    PROCESS(clk)    --triggered when clk changes
        BEGIN
        IF (rising_edge(clk)) THEN
            count <= count + 1;
        END IF;
        
    END PROCESS;
    
    clk_mux <= count;


end Behavioral;
