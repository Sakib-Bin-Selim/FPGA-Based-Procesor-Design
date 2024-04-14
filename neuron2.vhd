
-- neuron.vhd
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Thomas Florkowski, Hochschule Bonn-Rhein-Sieg, 21.04.2020

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity neuron2 is
  generic ( w1 : integer;
            w2 : integer;
            w3 : integer;
				w4 : integer;
            w5 : integer;
            w6 : integer;
				w7 : integer;
            
				
            bias : integer);
                
  port    ( clk : in std_logic;
            x1 : in integer;
            x2 : in integer;
            x3 : in integer;
				x4 : in integer;
            x5 : in integer;
            x6 : in integer;
				x7 : in integer;
            
            output : out integer := 0);
end neuron2;

architecture behave of neuron2 is
    
    signal sum : integer;
    signal sumAdress : std_logic_vector(15 downto 0);
    signal afterActivation : std_logic_vector(7 downto 0);
begin
    
process
begin
    wait until rising_edge(clk);
    
    -- sum of input with factors and bias
    sum <= (w1 * x1 + w2 * x2 + w3 * x3 + w4 * x4 + w5 * x5 + w6 * x6 + w7 * x7  +  bias);
    
    -- limiting and invoking ROM for sigmoid
    if (sum < -32768) then
        sumAdress <= (others => '0');
    elsif (sum > 32767) then
        sumAdress <= (others => '1');
    else 
        sumAdress <= std_logic_vector(to_unsigned(sum + 32768, 16));
    end if;
end process;     

sigmoid : entity work.sigmoid_IP 
    port map (clock   => clk,
              address => sumAdress(15 downto 5),
              q       => afterActivation);
                  
    -- format conversion
    output <= to_integer(unsigned(afterActivation));

end behave;