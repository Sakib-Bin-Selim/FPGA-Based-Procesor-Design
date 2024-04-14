

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use work.CONFIG.ALL;



entity nn_rgb is
  port (clk       : in  std_logic; --system clk 50 MHz                     -- input clock 74.25 MHz, video 720p
        reset_n   : in  std_logic;                      -- reset (invoked during configuration)
        --enable_in : in  std_logic_vector(2 downto 0);   -- three slide switches
        -- video in
		  control_3     : in  std_logic_vector(2 downto 0); 
		  control_2     : in  std_logic;  
		  control_1     : in  std_logic;  
        vs_in     : out  std_logic;                      -- vertical sync
        hs_in     : out  std_logic;                      -- horizontal sync
       -- de_in     : in  std_logic;                      -- data enable is '1' for valid pixel
        r_i      : out  std_logic;   -- red component of pixel
        g_i      : out  std_logic;   -- green component of pixel
        b_i      : out  std_logic;   -- blue component of pixel
		 --r_in      : in  std_logic_vector(7 downto 0);   -- red component of pixel
       -- g_in      : in  std_logic_vector(7 downto 0);   -- green component of pixel
       -- b_in      : in  std_logic_vector(7 downto 0);   -- blue component of pixel
        -- video out
        vs_out    : out std_logic;                      -- corresponding to video-in
        hs_out    : out std_logic;
       -- de_out    : out std_logic;
        r_outt     : out std_logic_vector(7 downto 0);
        g_outt     : out std_logic_vector(7 downto 0);
        b_outt     : out std_logic_vector(7 downto 0)
		 -- r_outt     : out std_logic;
       -- g_outt     : out std_logic;
       -- b_outt     : out std_logic
		 -- r_o     : out std_logic_vector(1 downto 0);
       -- g_o     : out std_logic_vector(1 downto 0);
       -- b_o     : out std_logic_vector(1 downto 0);
        --
        );  -- not supported by remote lab

		 
		  
		  
		  end nn_rgb;

 architecture behave of nn_rgb is
  -- input FFs
    signal reset                    : std_logic;
    signal enable                  : std_logic_vector(2 downto 0);
    signal vs_0, hs_0, de_0     : std_logic;


    -- output of signal processing
    signal vs_1, hs_1         : std_logic;
    signal result_r, result_g, result_b : std_logic_vector(7 downto 0);

    type   y_array is array (0 to 10) of std_logic_vector(7 downto 0);
    signal y : y_array;
 
 
 
 
---------AGER
    -- input FFs
    
    signal r_0, g_0, b_0           : integer;
     
    -- internal Signals between neurons
    signal h_0, h_1, h_2, h_3, h_4, h_5,h_6,output0, output1  : integer range 0 to 255;
    -- output of signal processing
    
    
   
	--extra
	 signal     r_in      :   std_logic_vector(7 downto 0);   -- red component of pixel
    signal     g_in      :   std_logic_vector(7 downto 0);   -- green component of pixel
    signal     b_in      :   std_logic_vector(7 downto 0);   -- blue component of pixel
    signal     r_out     :   std_logic;   -- red component of pixel
    signal     g_out     :   std_logic;   -- green component of pixel
    signal     b_out     :   std_logic;   -- blue component of pixel
    
	 
	 
	    signal hsync : std_logic;
		  signal vsync : std_logic;
	 
	     signal hcount : std_logic_vector(9 downto 0);
		  signal vcount : std_logic_vector(9 downto 0);
		  signal h_dat : std_logic_vector(2 downto 0);
		  signal v_dat : std_logic_vector(2 downto 0);
		  signal flag : std_logic;
		  signal hcount_ov : std_logic;
		  signal vcount_ov : std_logic;
		  signal dat_act : std_logic;
		  signal vga_clk : std_logic;
        signal clk_game: std_logic;
		  
		  signal disp_RGB_R : std_logic_vector(7 downto 0);
        signal disp_RGB_G : std_logic_vector(7 downto 0);
        signal disp_RGB_B : std_logic_vector(7 downto 0);
        signal data_r     : std_logic_vector(7 downto 0);
		  signal data_g     : std_logic_vector(7 downto 0);
		  signal data_b     : std_logic_vector(7 downto 0);
		  
        signal background_colour_r : std_logic_vector(7 downto 0);
        signal background_colour_g : std_logic_vector(7 downto 0);
        signal background_colour_b : std_logic_vector(7 downto 0);

		  constant hsync_end : integer := 95;
		  constant hdat_begin : integer := 143;
		  constant hdat_end : integer := 783;
		  constant hpixel_end : integer := 799;
		  constant vsync_end : integer := 1;
		  constant vdat_begin : integer := 34;
		  constant vdat_end : integer := 514;
		  constant vline_end : integer := 524;
		  
		  
	
	 
	 

begin




 
 
 
 process (clk)
		  begin
			 if rising_edge(clk) then
				vga_clk <= not vga_clk;
			 end if;
		  end process;

		  hcount_proc: process (vga_clk)
		  begin
			 if rising_edge(vga_clk) then
				if (hcount_ov = '1') then
				  hcount <= (others => '0');
				else
				  hcount <= std_logic_vector(unsigned(hcount) + 1);
				end if;
			 end if;
		  end process hcount_proc;

		  hcount_ov <= '1' when (hcount = hpixel_end) else '0';

		  vcount_proc: process (vga_clk)
		  begin
			 if rising_edge(vga_clk) then
				if (hcount_ov = '1') then
				  if (vcount_ov = '1') then
					 vcount <= (others => '0');
				  else
					 vcount <= std_logic_vector(unsigned(vcount) + 1);
				  end if;
				end if;
			 end if;
		  end process vcount_proc;

		  vcount_ov <= '1' when (vcount = vline_end) else '0';

		  dat_act <= '1' when ((unsigned(hcount) >= hdat_begin) and (unsigned(hcount) < hdat_end)) and 
									((unsigned(vcount) >= vdat_begin) and (unsigned(vcount) < vdat_end)) else '0';

		  hsync <= '1' when (unsigned(hcount) > hsync_end) else '0';
		  vsync <= '1' when (unsigned(vcount) > vsync_end) else '0';

		  disp_RGB_R <= data_r when (dat_act = '1') else "00000000";
		  disp_RGB_G <= data_g when (dat_act = '1') else "00000000";
		  disp_RGB_B <= data_b when (dat_act = '1') else "00000000";
		
		   
		
	

	h_dat_proc: process (vga_clk)
		  begin
			 if rising_edge(vga_clk) then
				  
				  
				  
				  --------1st column
				  ------R1C1------
 if unsigned(hcount) >= 143 and unsigned(hcount) <= 272 and 
       unsigned(vcount) >= 34 and unsigned(vcount) <= 514 then				  
				  
				  
	--in 1st column			 
 if unsigned(hcount) > 143 and  unsigned(hcount) <= 272 then
		 
		  if unsigned(vcount) > 34 and  unsigned(vcount) <= 53 then  
		 	
						data_r <= "00000000";
						data_g <= "00000000";
						data_b <= "00000000";
		
      
		  elsif unsigned(vcount) >= 54 and  unsigned(vcount) <= 73 then  
		 	
						data_r <= "00000000";
						data_g <= "00100000";
						data_b <= "10000000";
		
		
			elsif unsigned(vcount) >= 74 and  unsigned(vcount) <= 93 then  
						data_r <= "00000000";
						data_g <= "01010000";
						data_b <= "00000000";
		
		
									
			elsif unsigned(vcount) >= 94 and  unsigned(vcount) <= 113 then  
						
						data_r <= "00000000";
						data_g <= "01110000";
						data_b <= "10000000";
		
		


			elsif unsigned(vcount) >= 114 and  unsigned(vcount) <= 133 then  
						
						data_r <= "00000000";
						data_g <= "10100000";
						data_b <= "00000000";
		 
									
			elsif unsigned(vcount) >= 134 and  unsigned(vcount) <= 153 then  
						
						data_r <= "00000000";
						data_g <= "11000000";
						data_b <= "10000000";
		
							
					
			elsif unsigned(vcount) >= 154 and  unsigned(vcount) <= 173 then  
						data_r <= "00000000";
						data_g <= "11110000";
						data_b <= "00000000";
		
			
							
					
			elsif unsigned(vcount) >= 174 and  unsigned(vcount) <= 193 then  
						
						data_r <= "00010000";
						data_g <= "00010000";
						data_b <= "10000000";
		
					
			elsif unsigned(vcount) >= 194 and  unsigned(vcount) <= 213 then  
						
						data_r <= "00010000";
						data_g <= "01000000";
						data_b <= "00000000";	
					
			elsif unsigned(vcount) >= 214 and  unsigned(vcount) <= 233 then  
						
									 data_r <="00010000";
									data_g <= "01100000";
									data_b <= "10000000";	
							
					
			elsif unsigned(vcount) >= 234 and  unsigned(vcount) <= 253 then  
						
									 data_r <="00010000";
									data_g <= "10010000";
									data_b <= "00000000";	
	
							
					
			elsif unsigned(vcount) >= 254 and  unsigned(vcount) <= 273 then  
						
									 data_r <="00010000";
									data_g <= "11100000";
									data_b <= "00000000";	
		
							
					
			elsif unsigned(vcount) >= 274 and  unsigned(vcount) <= 293 then  
						
									 data_r <="00100000";
									data_g <= "00000000";
									data_b <= "10000000";	

					
			elsif unsigned(vcount) >= 294 and  unsigned(vcount) <= 313 then  
						
									 data_r <="00100000";
									data_g <= "00110000";
									data_b <= "00000000";	
		
							
					
			elsif unsigned(vcount) >= 314 and  unsigned(vcount) <= 333 then  
						
									data_r <="00100000";
									data_g <= "01010000";
									data_b <= "10000000";	
	
							
					
			elsif unsigned(vcount) >= 334 and  unsigned(vcount) <= 353 then  
						
									data_r <="00100000";
									data_g <= "10000000";
									data_b <= "00000000";	

							
					

			elsif unsigned(vcount) >= 354 and  unsigned(vcount) <= 373 then  
						
									 data_r <="00100000";
									data_g <= "10100000";
									data_b <= "10000000";	
		
			elsif unsigned(vcount) >= 374 and  unsigned(vcount) <= 393 then  
						
									 data_r <="00100000";
									data_g <= "11010000";
									data_b <= "00000000";	
	
			elsif unsigned(vcount) >= 394 and  unsigned(vcount) <= 413 then  
						
									 data_r <="00100000";
									data_g <= "11110000";
									data_b <= "10000000";		
			elsif unsigned(vcount) >= 414 and  unsigned(vcount) <= 433 then  
						
									 data_r <="00110000";
									data_g <= "00100000";
									data_b <= "00000000";		
			elsif unsigned(vcount) >= 434 and  unsigned(vcount) <= 453 then  
						
									 data_r <="00110000";
									data_g <= "01000000";
									data_b <= "10000000";	
			elsif unsigned(vcount) >= 454 and  unsigned(vcount) <= 473 then  
						
									 data_r <="00110000";
									data_g <= "01110000";
									data_b <= "00000000";	
			elsif unsigned(vcount) >= 474 and  unsigned(vcount) <= 493 then  
						
									 data_r <="00110000";
									data_g <= "10010000";
									data_b <= "10000000";		
			elsif unsigned(vcount) >= 494 and  unsigned(vcount) <= 513 then  
						
									 data_r <="00110000";
									data_g <= "11000000";
									data_b <= "00000000";		
				
							
end if;----hcount
end  if;--vcount
							
				
					
			  	   --	elsif unsigned(hcount) < 223 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
					--   v_dat <= "000";
					--	h_dat <= "011"; 
					 
					 --elsif unsigned(hcount) < 223 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
					  -- v_dat <= "000";
					 --h_dat <= "011";
					 
					--elsif unsigned(hcount) < 223 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
					--elsif unsigned(hcount) < 223 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
						--v_dat <= "000";
						--h_dat <= "011"; 
				  -- elsif unsigned(hcount) < 223 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
				  -- v_dat <= "000";
						--h_dat <= "011";	
						
					---- 2nd column 
					----R1C2
elsif unsigned(hcount) >= 273 and unsigned(hcount) <= 402 and 
					unsigned(vcount) >= 34 and unsigned(vcount) <= 514 then		
					   
		 	--in 1st column			 
 if unsigned(hcount) > 273 and  unsigned(hcount) <= 402 then
		 
		  if unsigned(vcount) > 34 and  unsigned(vcount) <= 53 then  
		 	
						data_b <= "00000000";
						data_g <= "00000000";
						data_r <= "00000000";
		
      
		  elsif unsigned(vcount) >= 54 and  unsigned(vcount) <= 73 then  
		 	
						data_b <= "00000000";
						data_r <= "00100000";
						data_g <= "10000000";
		
		
			elsif unsigned(vcount) >= 74 and  unsigned(vcount) <= 93 then  
						data_b <= "00000000";
						data_r <= "01010000";
						data_g <= "00000000";
		
		
									
			elsif unsigned(vcount) >= 94 and  unsigned(vcount) <= 113 then  
						
						data_b <= "00000000";
						data_g <= "01110000";
						data_r <= "10000000";
		
		


			elsif unsigned(vcount) >= 114 and  unsigned(vcount) <= 133 then  
						
						data_b <= "00000000";
						data_r <= "10100000";
						data_g <= "00000000";
		 
									
			elsif unsigned(vcount) >= 134 and  unsigned(vcount) <= 153 then  
						
						data_b <= "00000000";
						data_g <= "11000000";
						data_r <= "10000000";
		
							
					
			elsif unsigned(vcount) >= 154 and  unsigned(vcount) <= 173 then  
						data_r <= "00000000";
						data_b <= "11110000";
						data_g <= "00000000";
		
			
							
					
			elsif unsigned(vcount) >= 174 and  unsigned(vcount) <= 193 then  
						
						data_r <= "00010000";
						data_b <= "00010000";
						data_g <= "10000000";
		
					
			elsif unsigned(vcount) >= 194 and  unsigned(vcount) <= 213 then  
						
						data_b <= "00010000";
						data_r <= "01000000";
						data_g <= "00000000";	
					
			elsif unsigned(vcount) >= 214 and  unsigned(vcount) <= 233 then  
						
									 data_b <="00010000";
									data_g <= "01100000";
									data_r <= "10000000";	
							
					
			elsif unsigned(vcount) >= 234 and  unsigned(vcount) <= 253 then  
						
									 data_r <="00010000";
									data_b <= "10010000";
									data_g <= "00000000";	
	
							
					
			elsif unsigned(vcount) >= 254 and  unsigned(vcount) <= 273 then  
						
									 data_g <="00010000";
									data_r <= "11100000";
									data_b <= "00000000";	
		
							
					
			elsif unsigned(vcount) >= 274 and  unsigned(vcount) <= 293 then  
						
									 data_b <="00100000";
									data_r <= "00000000";
									data_g <= "10000000";	

					
			elsif unsigned(vcount) >= 294 and  unsigned(vcount) <= 313 then  
						
									 data_b <="00100000";
									data_g <= "00110000";
									data_r <= "00000000";	
		
							
					
			elsif unsigned(vcount) >= 314 and  unsigned(vcount) <= 333 then  
						
									data_b <="00100000";
									data_g <= "01010000";
									data_r <= "10000000";	
	
							
					
			elsif unsigned(vcount) >= 334 and  unsigned(vcount) <= 353 then  
						
									data_b <="00100000";
									data_g <= "10000000";
									data_r <= "00000000";	

							
					

			elsif unsigned(vcount) >= 354 and  unsigned(vcount) <= 373 then  
						
									 data_b <="00100000";
									data_g <= "10100000";
									data_r <= "10000000";	
		
			elsif unsigned(vcount) >= 374 and  unsigned(vcount) <= 393 then  
						
									 data_b <="00100000";
									data_g <= "11010000";
									data_r <= "00000000";	
	
			elsif unsigned(vcount) >= 394 and  unsigned(vcount) <= 413 then  
						
									 data_b <="00100000";
									data_g <= "11110000";
									data_r <= "10000000";		
			elsif unsigned(vcount) >= 414 and  unsigned(vcount) <= 433 then  
						
									 data_b <="00110000";
									data_g <= "00100000";
									data_r <= "00000000";		
			elsif unsigned(vcount) >= 434 and  unsigned(vcount) <= 453 then  
						
									 data_b <="00110000";
									data_g <= "01000000";
									data_r <= "10000000";	
			elsif unsigned(vcount) >= 454 and  unsigned(vcount) <= 473 then  
						
									 data_b <="00110000";
									data_g <= "01110000";
									data_r <= "00000000";	
			elsif unsigned(vcount) >= 474 and  unsigned(vcount) <= 493 then  
						
									 data_b <="00110000";
									data_g <= "10010000";
									data_r <= "10000000";		
			elsif unsigned(vcount) >= 494 and  unsigned(vcount) <= 513 then  
						
									 data_b <="00110000";
									data_g <= "11000000";
									data_r <= "00000000";		
				
							
end if;----hcount
end  if;--vcount
				
elsif unsigned(hcount) >= 403 and unsigned(hcount) < 532 and 
					unsigned(vcount) >= 34 and unsigned(vcount) <= 514 then		
					   
		 	--in 1st column			 
 if unsigned(hcount) > 403 and  unsigned(hcount) <= 532 then
		 
		  if unsigned(vcount) > 34 and  unsigned(vcount) <= 53 then  
		 	
						data_b <= "00000000";
						data_r <= "00000000";
						data_g <= "00000000";
		
      
		  elsif unsigned(vcount) >= 54 and  unsigned(vcount) <= 73 then  
		 	
						data_r <= "00000000";
						data_b <= "00100000";
						data_g <= "10000000";
		
		
			elsif unsigned(vcount) >= 74 and  unsigned(vcount) <= 93 then  
						data_r <= "00000000";
						data_b <= "01010000";
						data_g <= "00000000";
		
		
									
			elsif unsigned(vcount) >= 94 and  unsigned(vcount) <= 113 then  
						
						data_b <= "00000000";
						data_r <= "01110000";
						data_g <= "10000000";
		
		


			elsif unsigned(vcount) >= 114 and  unsigned(vcount) <= 133 then  
						
						data_r <= "00000000";
						data_b <= "10100000";
						data_g <= "00000000";
		 
									
			elsif unsigned(vcount) >= 134 and  unsigned(vcount) <= 153 then  
						
						data_b <= "00000000";
						data_r <= "11000000";
						data_g <= "10000000";
		
							
					
			elsif unsigned(vcount) >= 154 and  unsigned(vcount) <= 173 then  
						data_g <= "00000000";
						data_r <= "11110000";
						data_b <= "00000000";
		
			
							
					
			elsif unsigned(vcount) >= 174 and  unsigned(vcount) <= 193 then  
						
						data_g <= "00010000";
						data_r <= "00010000";
						data_b <= "10000000";
		
					
			elsif unsigned(vcount) >= 194 and  unsigned(vcount) <= 213 then  
						--
						data_r <= "00010000";
						data_b <= "01000000";
						data_g <= "00000000";	
					
			elsif unsigned(vcount) >= 214 and  unsigned(vcount) <= 233 then  
						
									 data_b <="00010000";
									data_r <= "01100000";
									data_g <= "10000000";	
							
					
			elsif unsigned(vcount) >= 234 and  unsigned(vcount) <= 253 then  
						
									 data_b <="00010000";
									data_r <= "10010000";
									data_g <= "00000000";	
	
							
					
			elsif unsigned(vcount) >= 254 and  unsigned(vcount) <= 273 then  
						
									 data_b <="00010000";
									data_r <= "11100000";
									data_g <= "00000000";	
		
							
					
			elsif unsigned(vcount) >= 274 and  unsigned(vcount) <= 293 then  
						
									 data_g <="00100000";
									data_r <= "00000000";
									data_b <= "10000000";	

					
			elsif unsigned(vcount) >= 294 and  unsigned(vcount) <= 313 then  
						
									 data_b <="00100000";
									data_r <= "00110000";
									data_g <= "00000000";	
		
							
					
			elsif unsigned(vcount) >= 314 and  unsigned(vcount) <= 333 then  
						
									data_b <="00100000";
									data_r <= "01010000";
									data_g <= "10000000";	
	
							
					
			elsif unsigned(vcount) >= 334 and  unsigned(vcount) <= 353 then  
						
									data_b <="00100000";
									data_r <= "10000000";
									data_g <= "00000000";	

							
					

			elsif unsigned(vcount) >= 354 and  unsigned(vcount) <= 373 then  
						
									 data_b <="00100000";
									data_r <= "10100000";
									data_g <= "10000000";	
		
			elsif unsigned(vcount) >= 374 and  unsigned(vcount) <= 393 then  
						
									 data_b <="00100000";
									data_r <= "11010000";
									data_g <= "00000000";	
	
			elsif unsigned(vcount) >= 394 and  unsigned(vcount) <= 413 then  
						
									 data_b <="00100000";
									data_r <= "11110000";
									data_g <= "10000000";		
			elsif unsigned(vcount) >= 414 and  unsigned(vcount) <= 433 then  
						
									 data_b <="00110000";
									data_r <= "00100000";
									data_g <= "00000000";		
			elsif unsigned(vcount) >= 434 and  unsigned(vcount) <= 453 then  
						
									 data_b <="00110000";
									data_r <= "01000000";
									data_g <= "10000000";	
			elsif unsigned(vcount) >= 454 and  unsigned(vcount) <= 473 then  
						
									 data_b <="00110000";
									data_r <= "01110000";
									data_g <= "00000000";	
			elsif unsigned(vcount) >= 474 and  unsigned(vcount) <= 493 then  
						
									 data_b <="00110000";
									data_r <= "10010000";
									data_g <= "10000000";		
			elsif unsigned(vcount) >= 494 and  unsigned(vcount) <= 513 then  
						
									 data_b <="00110000";
									data_r <= "11000000";
									data_g <= "00000000";		
				
							
end if;----hcount
end  if;--vcount
						
					 
					--elsif unsigned(hcount) > 223 and unsigned(hcount) < 303 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
						--v_dat <= "000";
						--h_dat <= "011"; 
					 
					-- elsif unsigned(hcount) > 223 and unsigned(hcount) < 303 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
					  -- v_dat <= "000";
						--h_dat <= "011";
					 
					--elsif unsigned(hcount) > 223 and unsigned(hcount) < 303 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
					  -- v_dat <= "000";
						--h_dat <= "000"; 
					--elsif unsigned(hcount) > 223 and unsigned(hcount) < 303 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
					  -- v_dat <= "000";
						--h_dat <= "000"; 
					--elsif unsigned(hcount) > 223 and unsigned(hcount) < 303 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
					  -- v_dat <= "000";
						--h_dat <= "011";	
				
			

			
						
						
						
										----R2C3	
-----------------ctg 120 km start					
					 elsif unsigned(hcount) > 533 and unsigned(hcount) < 783 and 
					 unsigned(vcount) > 145 and unsigned(vcount) < 405 then
		
case control_3 is 

when "000" =>

		            background_colour_r<= "00000000";
						background_colour_g<= "00000000";
						 background_colour_b<= "11111111";
						
					---	h_dat <= "101";	
	-------nill line  ---------------------------------------------    
 if unsigned(vcount) >= 400 and unsigned(vcount) <= 405 then 
			          
                  data_r <= background_colour_r;
						data_g <= background_colour_g;
						data_b <= background_colour_b;
		


		
			end if;	
	

	
       -------1st-14 ---------------------------------------------    
	       if unsigned(vcount) >= 330 and unsigned(vcount) <= 399 then

	               data_r <= background_colour_r;
						data_g <= background_colour_g;
						data_b <= background_colour_b;
           
			          

          
           end if;
------------------------------------------			  


-------15th ---------------------------------------------    
 if unsigned(vcount) >= 325 and unsigned(vcount) <= 329 then 
 
              if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  
					   data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
		else			
 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
			  end if;
 


-------16th ---------------------------------------------    
 if unsigned(vcount) >= 320 and unsigned(vcount) <= 324 then

	
           if unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

                        data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;
			 		  			 		  
										  
-------17th ---------------------------------------------    
 if unsigned(vcount) >= 315 and unsigned(vcount) <= 319 then

	
           if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                        data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 727  then

			      
					    data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
			 
           else 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;										  
			  
	-------18th ---------------------------------------------    
 if unsigned(vcount) >= 310 and unsigned(vcount) <= 314 then

	
           if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                        data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 728 and unsigned(hcount) <= 732  then

			      
					    data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
			 
           else 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;											  
			  
		  
-------19th ---------------------------------------------    
 if unsigned(vcount) >= 305 and unsigned(vcount) <= 309 then

	
          if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 737  then

			      
					    data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;										  
				  
-------20th ---------------------------------------------    
 if unsigned(vcount) >= 300 and unsigned(vcount) <= 304 then

	
      if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
					
			  elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 742  then

			      
					   data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;	

-------21th ---------------------------------------------    
 if unsigned(vcount) >= 295 and unsigned(vcount) <= 299 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 717  then

                  data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 747  then

			      
					   data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
			 
           else 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;	
-------22th ---------------------------------------------    
 if unsigned(vcount) >= 290 and unsigned(vcount) <= 294 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

                        data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                        data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
			  elsif   unsigned(hcount) >= 748 and unsigned(hcount) <= 752  then

			      
					   data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;	



-------23th ---------------------------------------------    
 if unsigned(vcount) >= 285 and unsigned(vcount) <= 289 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

                         data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                         data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";	
					
			  elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 757  then

			      
					   data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;
						 data_g <= background_colour_g;
						 data_b <= background_colour_b;

           end if; 
           end if;	



 
-------24th ---------------------------------------------    
 if unsigned(vcount) >= 280 and unsigned(vcount) <= 284 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
			  elsif   unsigned(hcount) >= 758 and unsigned(hcount) <= 762  then

			      
					   data_r <= "11111111";
						data_g <= "11111111";
						data_b <= "11111111";
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------25th ---------------------------------------------    
 if unsigned(vcount) >= 275 and unsigned(vcount) <= 279 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 763 and unsigned(hcount) <= 767  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------26th ---------------------------------------------    
 if unsigned(vcount) >= 270 and unsigned(vcount) <= 274 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 768 and unsigned(hcount) <= 772  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------27th ---------------------------------------------    
 if unsigned(vcount) >= 265 and unsigned(vcount) <= 269 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 773 and unsigned(hcount) <= 777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------28th ---------------------------------------------    
 if unsigned(vcount) >= 260 and unsigned(vcount) <= 264 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 768 and unsigned(hcount) <= 772  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------29th ---------------------------------------------    
 if unsigned(vcount) >= 255 and unsigned(vcount) <= 259 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 763 and unsigned(hcount) <= 767  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------30th ---------------------------------------------    
 if unsigned(vcount) >= 250 and unsigned(vcount) <= 254 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 758 and unsigned(hcount) <= 762  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------31th ---------------------------------------------    
 if unsigned(vcount) >= 245 and unsigned(vcount) <= 249 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 757  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------32th ---------------------------------------------    
 if unsigned(vcount) >= 240 and unsigned(vcount) <= 244 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			   elsif   unsigned(hcount) >= 748 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------33th ---------------------------------------------    
 if unsigned(vcount) >= 235 and unsigned(vcount) <= 239 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 712  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			   elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------34th ---------------------------------------------    
 if unsigned(vcount) >= 230 and unsigned(vcount) <= 234 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 742  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	



-------35th ---------------------------------------------    
 if unsigned(vcount) >= 225 and unsigned(vcount) <= 229 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 737  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------36th ---------------------------------------------    
 if unsigned(vcount) >= 220 and unsigned(vcount) <= 224 then

	
     
					
		    if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 728 and unsigned(hcount) <= 732  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------37th ---------------------------------------------    
 if unsigned(vcount) >= 215 and unsigned(vcount) <= 219 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 727  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	
-------38th ---------------------------------------------    
 if unsigned(vcount) >= 210 and unsigned(vcount) <= 214 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			  elsif   unsigned(hcount) >= 718 and unsigned(hcount) <= 722  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------39th ---------------------------------------------    
 if unsigned(vcount) >= 205 and unsigned(vcount) <= 209 then

	
      if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
		     
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

			  
			-----------------			
	-------40-50th ---------------------------------------------    
 if unsigned(vcount) >= 155 and unsigned(vcount) <= 204 then
		
            
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           
           end if;
			-----------------				-----------------					
when "001" =>


		            background_colour_r<= "11111111";
						background_colour_g<= "11111111";
						background_colour_b<= "00000000";
						
					---	h_dat <= "101";	
	-------nill line  ---------------------------------------------    
 if unsigned(vcount) >= 400 and unsigned(vcount) <= 405 then 
			          
                  data_r <= background_colour_r;
						data_g <= background_colour_g;
						data_b <= background_colour_b;
		


		
			end if;	
	

	
 

      -------1st-14 ---------------------------------------------    
	       if unsigned(vcount) >= 330 and unsigned(vcount) <= 399 then

	               data_r <= background_colour_r;
						data_g <= background_colour_g;
						data_b <= background_colour_b;
           
			          

          
           end if;
------------------------------------------			  


-------15th ---------------------------------------------    
 if unsigned(vcount) >= 325 and unsigned(vcount) <= 329 then 
 
              if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  
					   data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
		else			
 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
			  end if;
           
-------16th ---------------------------------------------    
 if unsigned(vcount) >= 320 and unsigned(vcount) <= 324 then

	
           if unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

                  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;
			 		  			 		  
										  
-------17th ---------------------------------------------    
 if unsigned(vcount) >= 315 and unsigned(vcount) <= 319 then

	
           if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
					
					
			  elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 727  then

			      
					   data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
			 
           else 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;										  
			  
	-------18th ---------------------------------------------    
 if unsigned(vcount) >= 310 and unsigned(vcount) <= 314 then

	
           if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
					
					
			  elsif   unsigned(hcount) >= 728 and unsigned(hcount) <= 732  then

			      
					   data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
			 
           else 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;											  
			  
		  
-------19th ---------------------------------------------    
 if unsigned(vcount) >= 305 and unsigned(vcount) <= 309 then

	
          if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
					
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 737  then

			      
					   data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;										  
				  
-------20th ---------------------------------------------    
 if unsigned(vcount) >= 300 and unsigned(vcount) <= 304 then

	
      if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

                  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
					
					
			  elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 742  then

			      
					   data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;	

-------21th ---------------------------------------------    
 if unsigned(vcount) >= 295 and unsigned(vcount) <= 299 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 717  then

                  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
					
					
			  elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 747  then

			      
					   data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
					
			 
           else 
			         data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;	
-------22th ---------------------------------------------    
 if unsigned(vcount) >= 290 and unsigned(vcount) <= 294 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

              data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

             data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
			  elsif   unsigned(hcount) >= 748 and unsigned(hcount) <= 752  then

			      
					   data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
						
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
           end if; 
           end if;	



-------23th ---------------------------------------------    
 if unsigned(vcount) >= 285 and unsigned(vcount) <= 289 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 757  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------24th ---------------------------------------------    
 if unsigned(vcount) >= 280 and unsigned(vcount) <= 284 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 758 and unsigned(hcount) <= 762  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------25th ---------------------------------------------    
 if unsigned(vcount) >= 275 and unsigned(vcount) <= 279 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 763 and unsigned(hcount) <= 767  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------26th ---------------------------------------------    
 if unsigned(vcount) >= 270 and unsigned(vcount) <= 274 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 768 and unsigned(hcount) <= 772  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------27th ---------------------------------------------    
 if unsigned(vcount) >= 265 and unsigned(vcount) <= 269 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 773 and unsigned(hcount) <= 777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------28th ---------------------------------------------    
 if unsigned(vcount) >= 260 and unsigned(vcount) <= 264 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 768 and unsigned(hcount) <= 772  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------29th ---------------------------------------------    
 if unsigned(vcount) >= 255 and unsigned(vcount) <= 259 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 763 and unsigned(hcount) <= 767  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------30th ---------------------------------------------    
 if unsigned(vcount) >= 250 and unsigned(vcount) <= 254 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 758 and unsigned(hcount) <= 762  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------31th ---------------------------------------------    
 if unsigned(vcount) >= 245 and unsigned(vcount) <= 249 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 757  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------32th ---------------------------------------------    
 if unsigned(vcount) >= 240 and unsigned(vcount) <= 244 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 542  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			   elsif   unsigned(hcount) >= 748 and unsigned(hcount) <= 752  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------33th ---------------------------------------------    
 if unsigned(vcount) >= 235 and unsigned(vcount) <= 239 then

	
      if unsigned(hcount) >= 538 and unsigned(hcount) <= 712  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     elsif	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			   elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------34th ---------------------------------------------    
 if unsigned(vcount) >= 230 and unsigned(vcount) <= 234 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 742  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	



-------35th ---------------------------------------------    
 if unsigned(vcount) >= 225 and unsigned(vcount) <= 229 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 737  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------36th ---------------------------------------------    
 if unsigned(vcount) >= 220 and unsigned(vcount) <= 224 then

	
     
					
		    if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 728 and unsigned(hcount) <= 732  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------37th ---------------------------------------------    
 if unsigned(vcount) >= 215 and unsigned(vcount) <= 219 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 727  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	
-------38th ---------------------------------------------    
 if unsigned(vcount) >= 210 and unsigned(vcount) <= 214 then

	
      
					
		     if	unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			  elsif   unsigned(hcount) >= 718 and unsigned(hcount) <= 722  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	


-------39th ---------------------------------------------    
 if unsigned(vcount) >= 205 and unsigned(vcount) <= 209 then

	
      if unsigned(hcount) >= 713 and unsigned(hcount) <= 717  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
		     
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	










			  
			-----------------			
	-------40-50th ---------------------------------------------    
 if unsigned(vcount) >= 155 and unsigned(vcount) <= 204 then
		
            
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           
           end if;
			-----------------				-----------------					

when "010" =>

		            background_colour_r<= "00000000";
						background_colour_g<= "00000000";
						background_colour_b<= "11111111";	

	
	-------nill line  ---------------------------------------------    
 if unsigned(vcount) >= 400 and unsigned(vcount) <= 405 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;	
	

	
       -------1st-2nd ---------------------------------------------    
	       if unsigned(vcount) >= 390 and unsigned(vcount) <= 399 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 727  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
------------------------------------------			  
			 
			  
			  
			  
---------------------------------------
          
			   -------3rd -10th---------------------------------------------    
	       if unsigned(vcount) >= 350 and unsigned(vcount) <= 389 then

	
           if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
			  elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
----------------------------------------------------			   
 
-------11th ---------------------------------------------    
 if unsigned(vcount) >= 345 and unsigned(vcount) <= 349 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	-------12th ---------------------------------------------    
 if unsigned(vcount) >= 340 and unsigned(vcount) <= 344 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 712  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
						

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
			  
			  
-------13th ---------------------------------------------    
 if unsigned(vcount) >= 335 and unsigned(vcount) <= 339 then

	
           if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 712  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
					
			  elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
						
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	

-------14th-15th ---------------------------------------------    
 if unsigned(vcount) >= 325 and unsigned(vcount) <= 334 then 
         if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
					
			  elsif  unsigned(hcount) >= 708 and unsigned(hcount) <= 717  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
						
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;

          
           
-------16-17th ---------------------------------------------    
 if unsigned(vcount) >= 315 and unsigned(vcount) <= 324 then

	if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
					
			  
				  
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 737  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
						
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  			 		  
										  
-------18-19th ---------------------------------------------    
 if unsigned(vcount) >= 305 and unsigned(vcount) <= 314 then

	
          if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
			  elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
			  									  
			  
	-------20-21th ---------------------------------------------    
 if unsigned(vcount) >= 295 and unsigned(vcount) <= 304 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 727  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;									  
			  
		  
-------22-23th ---------------------------------------------    
 if unsigned(vcount) >= 285 and unsigned(vcount) <= 294 then
            data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;
	
--	
           							  
				  
-------24-25th ---------------------------------------------    
 if unsigned(vcount) >= 275 and unsigned(vcount) <= 284 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 727  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 757  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
			  
-------26-27th ---------------------------------------------    
 if unsigned(vcount) >= 265 and unsigned(vcount) <= 274 then

	
           if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 758 and unsigned(hcount) <=  767  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
-------28-29th ---------------------------------------------    
 if unsigned(vcount) >= 255 and unsigned(vcount) <= 264 then

	
            if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;															  
			  
-------30th-34th ---------------------------------------------    
 if unsigned(vcount) >= 220 and unsigned(vcount) <= 254 then 
		   
					
				
			if   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			

-------35th ---------------------------------------------    
 if unsigned(vcount) >= 215 and unsigned(vcount) <= 219 then 
		   
					
				
			if   unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
			  
			  
	-------36 ---------------------------------------------    
 if unsigned(vcount) >= 210 and unsigned(vcount) <= 214 then

	
         if   unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  727  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			

-------37 ---------------------------------------------    
 if unsigned(vcount) >= 205 and unsigned(vcount) <= 209 then

	
         if   unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 617  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  727  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
-------38 ---------------------------------------------    
 if unsigned(vcount) >= 200 and unsigned(vcount) <= 204 then

	
         if   unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 617  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
-------39-40 ---------------------------------------------    
 if unsigned(vcount) >= 190 and unsigned(vcount) <= 199 then

	
         if   unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 627  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  

-------41-42 ---------------------------------------------    
 if unsigned(vcount) >= 180 and unsigned(vcount) <= 189 then

	
         if   unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 637  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
			  
			  
					-----------------
	-------43-44 ---------------------------------------------    
 if unsigned(vcount) >= 170 and unsigned(vcount) <= 179 then

	
           if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
			
					
			  elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
			elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 637  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
			elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------			
	-------45-46th ---------------------------------------------    
 if unsigned(vcount) >= 160 and unsigned(vcount) <= 169 then

	
            if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
			
					
			  elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
			elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 627  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
			elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 758 and unsigned(hcount) <=  767  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------					
	

-------47-48th ---------------------------------------------    
 if unsigned(vcount) >= 150 and unsigned(vcount) <= 159 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 617  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 727  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
			  elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 757  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
-------49th-50th ---------------------------------------------    
 if unsigned(vcount) >= 145 and unsigned(vcount) <= 149 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;					  


when "011" =>


		                background_colour_r<= "11111111";
						background_colour_g<= "11111111";
						background_colour_b<= "00000000";
						
						
-------nill line  ---------------------------------------------    
 if unsigned(vcount) >= 400 and unsigned(vcount) <= 405 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;	
	

	
       -------1st-2nd ---------------------------------------------    
	       if unsigned(vcount) >= 390 and unsigned(vcount) <= 399 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 727  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
------------------------------------------			  
			 
			  
			  
			  
---------------------------------------
          
			   -------3rd -10th---------------------------------------------    
	       if unsigned(vcount) >= 350 and unsigned(vcount) <= 389 then

	
           if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
			  elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
----------------------------------------------------			   
 
-------11th ---------------------------------------------    
 if unsigned(vcount) >= 345 and unsigned(vcount) <= 349 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	-------12th ---------------------------------------------    
 if unsigned(vcount) >= 340 and unsigned(vcount) <= 344 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 712  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
			  
			  
-------13th ---------------------------------------------    
 if unsigned(vcount) >= 335 and unsigned(vcount) <= 339 then

	
           if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 712  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
					
			  elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	

-------14th-15th ---------------------------------------------    
 if unsigned(vcount) >= 325 and unsigned(vcount) <= 334 then 
         if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
					
			  elsif  unsigned(hcount) >= 708 and unsigned(hcount) <= 717  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;

          
           
-------16-17th ---------------------------------------------    
 if unsigned(vcount) >= 315 and unsigned(vcount) <= 324 then

	if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
					
			  
				  
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 737  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
						
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  			 		  
										  
-------18-19th ---------------------------------------------    
 if unsigned(vcount) >= 305 and unsigned(vcount) <= 314 then

	
          if unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 673 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
			  elsif   unsigned(hcount) >= 693 and unsigned(hcount) <= 702  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 728 and unsigned(hcount) <= 737  then

				  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
			  									  
			  
	-------20-21th ---------------------------------------------    
 if unsigned(vcount) >= 295 and unsigned(vcount) <= 304 then

	
           if unsigned(hcount) >= 648 and unsigned(hcount) <= 672  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 727  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;									  
			  
		  
-------22-23th ---------------------------------------------    
 if unsigned(vcount) >= 285 and unsigned(vcount) <= 294 then
            data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;
	
--	
           							  
				  
-------24-25th ---------------------------------------------    
 if unsigned(vcount) >= 275 and unsigned(vcount) <= 284 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 727  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 757  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
			  
-------26-27th ---------------------------------------------    
 if unsigned(vcount) >= 265 and unsigned(vcount) <= 274 then

	
           if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 758 and unsigned(hcount) <=  767  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
-------28-29th ---------------------------------------------    
 if unsigned(vcount) >= 255 and unsigned(vcount) <= 264 then

	
            if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;															  
			  
-------30th-34th ---------------------------------------------    
 if unsigned(vcount) >= 220 and unsigned(vcount) <= 254 then 
		   
					
				
			if   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			

-------35th ---------------------------------------------    
 if unsigned(vcount) >= 215 and unsigned(vcount) <= 219 then 
		   
					
				
			if   unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
			  
			  
	-------36 ---------------------------------------------    
 if unsigned(vcount) >= 210 and unsigned(vcount) <= 214 then

	
         if   unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  727  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			

-------37 ---------------------------------------------    
 if unsigned(vcount) >= 205 and unsigned(vcount) <= 209 then

	
         if   unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 617  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  727  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
-------38 ---------------------------------------------    
 if unsigned(vcount) >= 200 and unsigned(vcount) <= 204 then

	
         if   unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 617  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
-------39-40 ---------------------------------------------    
 if unsigned(vcount) >= 190 and unsigned(vcount) <= 199 then

	
         if   unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 627  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  

-------41-42 ---------------------------------------------    
 if unsigned(vcount) >= 180 and unsigned(vcount) <= 189 then

	
         if   unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 637  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
			 elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
			  
			  
			  
					-----------------
	-------43-44 ---------------------------------------------    
 if unsigned(vcount) >= 170 and unsigned(vcount) <= 179 then

	
           if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
			
					
			  elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
			elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 637  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
			elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 768 and unsigned(hcount) <=  777  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------			
	-------45-46th ---------------------------------------------    
 if unsigned(vcount) >= 160 and unsigned(vcount) <= 169 then

	
            if unsigned(hcount) >= 543 and unsigned(hcount) <= 552  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
			
					
			  elsif   unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
			elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 627  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
			elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 652  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 688 and unsigned(hcount) <=  697  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <=  747  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 758 and unsigned(hcount) <=  767  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------					
	

-------47-48th ---------------------------------------------    
 if unsigned(vcount) >= 150 and unsigned(vcount) <= 159 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 572  then

               data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 617  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 643 and unsigned(hcount) <= 682  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 727  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
			  elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 757  then

			      
					data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
-------49th-50th ---------------------------------------------    
 if unsigned(vcount) >= 145 and unsigned(vcount) <= 149 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;					  


				 

when "100" =>					   



					   background_colour_r<= "00000000";
						background_colour_g<= "00000000";
						background_colour_b<= "11111111";	
	


	---	h_dat <= "101";	
	-------nill line  ---------------------------------------------    
 if unsigned(vcount) >= 400 and unsigned(vcount) <= 405 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;	
	

	
       -------1st ---------------------------------------------    
	       if unsigned(vcount) >= 395 and unsigned(vcount) <= 399 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 603  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				elsif  unsigned(hcount) >= 743 and unsigned(hcount) <= 753  then

                   data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
------------------------------------------			  
			  -------2nd ---------------------------------------------    
	       if unsigned(vcount) >= 390 and unsigned(vcount) <= 394 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				elsif  unsigned(hcount) >= 743 and unsigned(hcount) <= 753  then

                   data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
			  
			  
---------------------------------------
          
			   -------3rd ---------------------------------------------    
	       if unsigned(vcount) >= 385 and unsigned(vcount) <= 389 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
----------------------------------------------------			   
 -------4th -5th ---------------------------------------------    
 if unsigned(vcount) >= 375 and unsigned(vcount) <= 384 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 613 and unsigned(hcount) <= 622  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 
			  
---------------------------------------------------			  
  -------6th-7th ---------------------------------------------    
 if unsigned(vcount) >= 365 and unsigned(vcount) <= 374 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 603 and unsigned(hcount) <= 612  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 
			  
	 -------8th ---------------------------------------------    
 if unsigned(vcount) >= 360 and unsigned(vcount) <= 364 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 603 and unsigned(hcount) <= 612  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
			  
 -------9th ---------------------------------------------    
 if unsigned(vcount) >= 355 and unsigned(vcount) <= 359 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 613 and unsigned(hcount) <= 622  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
-------10th ---------------------------------------------    
 if unsigned(vcount) >= 349 and unsigned(vcount) <= 354 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 613 and unsigned(hcount) <= 622  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 678 and unsigned(hcount) <= 687  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 elsif   unsigned(hcount) >= 698 and unsigned(hcount) <= 707  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;

-------11th ---------------------------------------------    
 if unsigned(vcount) >= 345 and unsigned(vcount) <= 349 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 678 and unsigned(hcount) <= 687  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 elsif   unsigned(hcount) >= 698 and unsigned(hcount) <= 707  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	-------12th ---------------------------------------------    
 if unsigned(vcount) >= 340 and unsigned(vcount) <= 344 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 668 and unsigned(hcount) <= 677  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 elsif   unsigned(hcount) >= 708 and unsigned(hcount) <= 717  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
			  
			  
-------13th ---------------------------------------------    
 if unsigned(vcount) >= 335 and unsigned(vcount) <= 339 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 668 and unsigned(hcount) <= 677  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 elsif   unsigned(hcount) >= 708 and unsigned(hcount) <= 717  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				  data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	

-------14th-15th ---------------------------------------------    
 if unsigned(vcount) >= 325 and unsigned(vcount) <= 334 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           
-------16-17th ---------------------------------------------    
 if unsigned(vcount) >= 315 and unsigned(vcount) <= 324 then

	
           if unsigned(hcount) >= 588 and unsigned(hcount) <= 607  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 677  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 742  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  			 		  
										  
-------18-19th ---------------------------------------------    
 if unsigned(vcount) >= 305 and unsigned(vcount) <= 314 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 637  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
	-------20-21th ---------------------------------------------    
 if unsigned(vcount) >= 295 and unsigned(vcount) <= 304 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 722  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
		  
-------22-23th ---------------------------------------------    
 if unsigned(vcount) >= 285 and unsigned(vcount) <= 294 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 657  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 732  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
				  
-------24-25th ---------------------------------------------    
 if unsigned(vcount) >= 275 and unsigned(vcount) <= 284 then

	
           if unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
			  
-------26-27th ---------------------------------------------    
 if unsigned(vcount) >= 265 and unsigned(vcount) <= 274 then

	
           if unsigned(hcount) >= 583 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 627  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
				
			elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
-------28-29th ---------------------------------------------    
 if unsigned(vcount) >= 255 and unsigned(vcount) <= 264 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 657  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 742  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
-------30th-31th ---------------------------------------------    
 if unsigned(vcount) >= 245 and unsigned(vcount) <= 254 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;
	

-------32-33th ---------------------------------------------    
 if unsigned(vcount) >= 235 and unsigned(vcount) <= 244 then

	
           if unsigned(hcount) >= 573 and unsigned(hcount) <= 592  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------34-35th ---------------------------------------------    
 if unsigned(vcount) >= 225 and unsigned(vcount) <= 234 then

	
           if unsigned(hcount) >= 563 and unsigned(hcount) <= 572  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 732  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
			elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 762  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
	-------36-37th ---------------------------------------------    
 if unsigned(vcount) >= 215 and unsigned(vcount) <= 224 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 562  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
			elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
			elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 762  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------
	-------38-39th ---------------------------------------------    
 if unsigned(vcount) >= 205 and unsigned(vcount) <= 214 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 562  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
			elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 762  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";		
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------			
	-------40-44th ---------------------------------------------    
 if unsigned(vcount) >= 185 and unsigned(vcount) <= 204 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 562  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
			elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
			
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------					
	-------45-46th ---------------------------------------------    
 if unsigned(vcount) >= 175 and unsigned(vcount) <= 184 then

	
           if unsigned(hcount) >= 563 and unsigned(hcount) <= 572  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
					
			elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 732  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
			
					
			elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 762  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";	
				
			
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------	

-------47-48th ---------------------------------------------    
 if unsigned(vcount) >= 165 and unsigned(vcount) <= 174 then

	
           if unsigned(hcount) >= 573 and unsigned(hcount) <= 592  then

               data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
				
			elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 697  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
			
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 752  then

			      
					data_r <= "11111111";data_g <= "11111111";data_b <= "11111111";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
-------49th-50th ---------------------------------------------    
 if unsigned(vcount) >= 155 and unsigned(vcount) <= 164 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;					  



when others =>


		            background_colour_r<= "11111111";
						background_colour_g<= "11111111";
						background_colour_b<= "00000000";			
			

					


	---	h_dat <= "101";	
	-------nill line  ---------------------------------------------    
 if unsigned(vcount) >= 400 and unsigned(vcount) <= 405 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;	
	

	
       -------1st ---------------------------------------------    
	       if unsigned(vcount) >= 395 and unsigned(vcount) <= 399 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 603  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				elsif  unsigned(hcount) >= 743 and unsigned(hcount) <= 753  then

                     data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
------------------------------------------			  
			  -------2nd ---------------------------------------------    
	       if unsigned(vcount) >= 390 and unsigned(vcount) <= 394 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				elsif  unsigned(hcount) >= 743 and unsigned(hcount) <= 753  then

                     data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
			  
			  
---------------------------------------
          
			   -------3rd ---------------------------------------------    
	       if unsigned(vcount) >= 385 and unsigned(vcount) <= 389 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			  
----------------------------------------------------			   
 -------4th -5th ---------------------------------------------    
 if unsigned(vcount) >= 375 and unsigned(vcount) <= 384 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 613 and unsigned(hcount) <= 622  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 
			  
---------------------------------------------------			  
  -------6th-7th ---------------------------------------------    
 if unsigned(vcount) >= 365 and unsigned(vcount) <= 374 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 603 and unsigned(hcount) <= 612  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 
			  
	 -------8th ---------------------------------------------    
 if unsigned(vcount) >= 360 and unsigned(vcount) <= 364 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 603 and unsigned(hcount) <= 612  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 697  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
			  
 -------9th ---------------------------------------------    
 if unsigned(vcount) >= 355 and unsigned(vcount) <= 359 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 613 and unsigned(hcount) <= 622  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 688 and unsigned(hcount) <= 697  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
-------10th ---------------------------------------------    
 if unsigned(vcount) >= 349 and unsigned(vcount) <= 354 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 613 and unsigned(hcount) <= 622  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 678 and unsigned(hcount) <= 687  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 elsif   unsigned(hcount) >= 698 and unsigned(hcount) <= 707  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;

-------11th ---------------------------------------------    
 if unsigned(vcount) >= 345 and unsigned(vcount) <= 349 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 678 and unsigned(hcount) <= 687  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 elsif   unsigned(hcount) >= 698 and unsigned(hcount) <= 707  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	-------12th ---------------------------------------------    
 if unsigned(vcount) >= 340 and unsigned(vcount) <= 344 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				elsif   unsigned(hcount) >= 623 and unsigned(hcount) <= 632  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 668 and unsigned(hcount) <= 677  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 elsif   unsigned(hcount) >= 708 and unsigned(hcount) <= 717  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
			  
			  
-------13th ---------------------------------------------    
 if unsigned(vcount) >= 335 and unsigned(vcount) <= 339 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 668  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 668 and unsigned(hcount) <= 677  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 elsif   unsigned(hcount) >= 708 and unsigned(hcount) <= 717  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				elsif  unsigned(hcount) >= 718 and unsigned(hcount) <= 728  then

				    data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				  
				

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  
	

-------14th-15th ---------------------------------------------    
 if unsigned(vcount) >= 325 and unsigned(vcount) <= 334 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           
-------16-17th ---------------------------------------------    
 if unsigned(vcount) >= 315 and unsigned(vcount) <= 324 then

	
           if unsigned(hcount) >= 588 and unsigned(hcount) <= 607  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 677  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 742  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			 		  			 		  
										  
-------18-19th ---------------------------------------------    
 if unsigned(vcount) >= 305 and unsigned(vcount) <= 314 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 637  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
	-------20-21th ---------------------------------------------    
 if unsigned(vcount) >= 295 and unsigned(vcount) <= 304 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 638 and unsigned(hcount) <= 647  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 722  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
		  
-------22-23th ---------------------------------------------    
 if unsigned(vcount) >= 285 and unsigned(vcount) <= 294 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 657  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 732  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
				  
-------24-25th ---------------------------------------------    
 if unsigned(vcount) >= 275 and unsigned(vcount) <= 284 then

	
           if unsigned(hcount) >= 573 and unsigned(hcount) <= 582  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 752  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
			  
-------26-27th ---------------------------------------------    
 if unsigned(vcount) >= 265 and unsigned(vcount) <= 274 then

	
           if unsigned(hcount) >= 583 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 627  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 658 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			 elsif   unsigned(hcount) >= 703 and unsigned(hcount) <= 712  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
				
			elsif   unsigned(hcount) >= 743 and unsigned(hcount) <= 752  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
					
				 	

           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
-------28-29th ---------------------------------------------    
 if unsigned(vcount) >= 255 and unsigned(vcount) <= 264 then

	
           if unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 628 and unsigned(hcount) <= 657  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 742  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;										  
			  
-------30th-31th ---------------------------------------------    
 if unsigned(vcount) >= 245 and unsigned(vcount) <= 254 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;
	

-------32-33th ---------------------------------------------    
 if unsigned(vcount) >= 235 and unsigned(vcount) <= 244 then

	
           if unsigned(hcount) >= 573 and unsigned(hcount) <= 592  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 752  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;	

-------34-35th ---------------------------------------------    
 if unsigned(vcount) >= 225 and unsigned(vcount) <= 234 then

	
           if unsigned(hcount) >= 563 and unsigned(hcount) <= 572  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 732  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
			elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 762  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
	-------36-37th ---------------------------------------------    
 if unsigned(vcount) >= 215 and unsigned(vcount) <= 224 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 562  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
			elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
			elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 762  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------
	-------38-39th ---------------------------------------------    
 if unsigned(vcount) >= 205 and unsigned(vcount) <= 214 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 562  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
			elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
			elsif   unsigned(hcount) >= 738 and unsigned(hcount) <= 762  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";		
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------			
	-------40-44th ---------------------------------------------    
 if unsigned(vcount) >= 185 and unsigned(vcount) <= 204 then

	
           if unsigned(hcount) >= 553 and unsigned(hcount) <= 562  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
			
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
			elsif   unsigned(hcount) >= 713 and unsigned(hcount) <= 722  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
			
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------					
	-------45-46th ---------------------------------------------    
 if unsigned(vcount) >= 175 and unsigned(vcount) <= 184 then

	
           if unsigned(hcount) >= 563 and unsigned(hcount) <= 572  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			elsif   unsigned(hcount) >= 593 and unsigned(hcount) <= 602  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			  elsif   unsigned(hcount) >= 648 and unsigned(hcount) <= 667  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
					
			elsif   unsigned(hcount) >= 723 and unsigned(hcount) <= 732  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
			
					
			elsif   unsigned(hcount) >= 753 and unsigned(hcount) <= 762  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";	
				
			
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;
			-----------------	

-------47-48th ---------------------------------------------    
 if unsigned(vcount) >= 165 and unsigned(vcount) <= 174 then

	
           if unsigned(hcount) >= 573 and unsigned(hcount) <= 592  then

                 data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
				
			elsif   unsigned(hcount) >= 618 and unsigned(hcount) <= 697  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
			
					
			  elsif   unsigned(hcount) >= 733 and unsigned(hcount) <= 752  then

			      
					  data_r <= "00000000";data_g <= "00000000";data_b <= "00000000";
					
           else 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;

           end if; 
           end if;			
-------49th-50th ---------------------------------------------    
 if unsigned(vcount) >= 155 and unsigned(vcount) <= 164 then 
			          data_r <= background_colour_r;data_g <= background_colour_g;data_b <= background_colour_b;
			  
			end if;					  

		
			
			
			
			
			
			
			
end case;

			
			
						------R3C3	 
					elsif unsigned(hcount) > 463 and unsigned(hcount) < 623 and 
					unsigned(vcount) > 405 and unsigned(vcount) < 534 then
						data_r <= "00001111";
						data_g <= "11110000";
						data_b <= "00001111";
					
					--elsif unsigned(hcount) > 303 and unsigned(hcount) < 383 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
						--v_dat <= "000";
						--h_dat <= "011"; 
					 
					 --elsif unsigned(hcount) > 303 and unsigned(hcount) < 383 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
						--v_dat <= "000";
						--h_dat <= "011";
					 
					--elsif unsigned(hcount) > 303 and unsigned(hcount) < 383 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
						--v_dat <= "000";
						--h_dat <= "000"; 
					--elsif unsigned(hcount) > 303 and unsigned(hcount) < 383 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
					  -- v_dat <= "000";
						--h_dat <= "000"; 
				  -- elsif unsigned(hcount) > 303 and unsigned(hcount) < 383 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
					  -- v_dat <= "000";
						--h_dat <= "011";	
				 
		----- 4th column		
					
					--elsif unsigned(hcount) > 383 and unsigned(hcount) < 463 and unsigned(vcount) < 94 then
					  -- v_dat <= "000";
						--h_dat <= "011";
						
					-- elsif unsigned(hcount) > 383 and unsigned(hcount) < 463 and unsigned(vcount) > 94 and unsigned(vcount) < 154 then
					 --  v_dat <= "000";
						--h_dat <= "011"; 
					 
				  -- elsif unsigned(hcount) > 383 and unsigned(hcount) < 463 and unsigned(vcount) > 154 and unsigned(vcount) < 214 then
					 --  v_dat <= "000";
						--h_dat <= "011";  
					
					--elsif unsigned(hcount) > 383 and unsigned(hcount) < 463 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
					 
					-- elsif unsigned(hcount) > 383 and unsigned(hcount) < 463 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
					  -- v_dat <= "000";
						--h_dat <= "011";
					 
					--elsif unsigned(hcount) > 383 and unsigned(hcount) <  463 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
					--elsif unsigned(hcount) > 383 and unsigned(hcount) < 463 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
				  -- elsif unsigned(hcount) > 383 and unsigned(hcount) < 463 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
					--   v_dat <= "000";
					--	h_dat <= "011";	

		--------5th column 
				  
				  
				-- elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) < 94 then
					  -- v_dat <= "000";
						--h_dat <= "011";
						
					-- elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) > 94 and unsigned(vcount) < 154 then
					 --  v_dat <= "000";
						--h_dat <= "000"; 
					 
				--   elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) > 154 and unsigned(vcount) < 214 then
					--   v_dat <= "000";
					--	h_dat <= "000";  
					
					--elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
					 
					 --elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
					 --  v_dat <= "000";
						--h_dat <= "011";
					 
					--elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
					  -- v_dat <= "000";
						--h_dat <= "000"; 
					--elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
					  -- v_dat <= "000";
						--h_dat <= "000"; 
				  -- elsif unsigned(hcount) > 463 and unsigned(hcount) < 543 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
					  -- v_dat <= "000";
						--h_dat <= "011";	
				
		-------6th column 


				--  elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) < 94 then
					 --  v_dat <= "000";
					--	h_dat <= "011";
						
					-- elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) > 94 and unsigned(vcount) < 154 then
					 --  v_dat <= "000";
					--	h_dat <= "000"; 
					 
				 --  elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) > 154 and unsigned(vcount) < 214 then
					--   v_dat <= "000";
					--	h_dat <= "000";  
					
					--elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
					 
					-- elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
					  -- v_dat <= "000";
						--h_dat <= "011";
					 
				--	elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
					 --  v_dat <= "000";
					--	h_dat <= "000"; 
				--	elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
					 --  v_dat <= "000";
						--h_dat <= "000"; 
				  -- elsif unsigned(hcount) > 543 and unsigned(hcount) < 623 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
					 --  v_dat <= "000";
					--	h_dat <= "011";			
						
						
			-----7th column 


				--  elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) < 94 then
				  --    v_dat <= "000";
					--	h_dat <= "011";
						
				--	 elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) > 94 and unsigned(vcount) < 154 then
				  --    v_dat <= "000";
					--	h_dat <= "011"; 
					 
				 --  elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) > 154 and unsigned(vcount) < 214 then
					--   v_dat <= "000";
					--	h_dat <= "011";  
					
					--elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
					 --  v_dat <= "000";
						--h_dat <= "011"; 
					 
					-- elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
					  -- v_dat <= "000";
						--h_dat <= "011";
					 
					--elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
					--elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
					 --  v_dat <= "000";
					--	h_dat <= "011"; 
				  -- elsif unsigned(hcount) > 623 and unsigned(hcount) < 703 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
					 --  v_dat <= "000";
						--h_dat <= "011";		
						

					
				------8th column 
			
				 
				
				  -- elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) < 94 then
					 --  v_dat <= "000";
					--	h_dat <= "011";
						
					-- elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) > 94 and unsigned(vcount) < 154 then
					 --  v_dat <= "000";
					--	h_dat <= "000"; 
					 
				 --  elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) > 154 and unsigned(vcount) < 214 then
					 --  v_dat <= "000";
					--	h_dat <= "000";  
					
					--elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) > 214 and unsigned(vcount) < 274 then
					  -- v_dat <= "000";
						--h_dat <= "011"; 
					 
					-- elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) > 274 and unsigned(vcount) < 334 then
					  -- v_dat <= "000";
						--h_dat <= "011";
					 
				--	elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) > 334 and unsigned(vcount) < 394 then
					  -- v_dat <= "000";
						--h_dat <= "000"; 
					--elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) > 394 and unsigned(vcount) < 454 then
					 --  v_dat <= "000";
					--	h_dat <= "000"; 
				  -- elsif unsigned(hcount) > 703 and unsigned(hcount) < 783 and unsigned(vcount) > 454 and unsigned(vcount) < 514 then
					 --  v_dat <= "000";
					--	h_dat <= "011";		

						
						
						
						
					-------row bora aro 5 ta
				
				
					
					 
					 -------------column borabor 

						
					 else
						data_r <= "00001111";
						data_g <= "11110000";
						data_b <= "00001111";
						
					 end if;
				  
			 end if;
		  end process h_dat_proc;
	
		r_i<= disp_RGB_R(7);----output orginal
		g_i<= disp_RGB_G(7);
		b_i<= disp_RGB_B(7);
		hs_in<= hsync;
		vs_in<= vsync;
		--process (clock)
		--begin
		
	--	if rising_edge (clock) then
		--disp_R_out<= disp_R_in;
		--disp_G_out<= disp_G_in;
		--disp_B_out<= disp_B_in;
		-- hsync_O <= hsync;
		--  vsync_O <=vsync;
		  
		--  end if;
		  
		 -- end process;
		  -----------------------------------------
		


 r_in<= disp_RGB_R;
 g_in<= disp_RGB_G;
 b_in<= disp_RGB_B;
 
--r_in <= "00000000" when (r_i <= '0') else "11111111";
--g_in <= "00000000" when (g_i <= '0') else "11111111";
--b_in <= "00000000" when (b_i <=  '0') else "11111111";


--generate the neural network with the parameters from config.vhd
--the outer loops creates the layers and the inner loop the neurons within the layer
--input Layer is assgined later
gen : FOR i IN 1 TO networkStructure'length - 1 GENERATE --layers
    gen2: FOR j IN 0 TO networkStructure(i) - 1 GENERATE --neurons within the Layers
     begin
        knot: entity work.neuron
             generic map ( weightsIn => weights(positions(j+1,i)-1 downto positions(j,i)))
             port map (  clk      => clk,
                         inputsIn => (connection(connnectionRange(i)-1 downto connnectionRange(i-1))),
                         output   => connection(connnectionRange(i)+j));
    END GENERATE;
END GENERATE;


control: entity work.control
    generic map (delay => 9) 
    port map (  clk      => clk,
                reset    => reset,
                vs_in    => vs_0,
                hs_in    => hs_0,
                --de_in    => de_0,
                vs_out   => vs_1,
                hs_out   => hs_1
               -- de_out   => de_1
					);


process
begin   
    wait until rising_edge(clk);
   
    -- input FFs for control
    reset <= not reset_n;
   -- enable <= enable_in;
    -- input FFs for video signal
    vs_0  <= vsync;
    hs_0  <= hsync;
    --de_0  <= de_in;
   connection(0) <= to_integer(unsigned(r_in));
   connection(1) <= to_integer(unsigned(g_in));
   connection(2) <= to_integer(unsigned(b_in));
	 
	 -- convert RGB to luminance: Y (5*R + 9*G + 2*B)
   y(0) <= std_logic_vector(to_unsigned(
          (5*connection(0) + 9*connection(1) + 2*connection(2))/16,8));
   for i in 1 to 10 loop
      y(i) <= y(i-1);
   end loop;
	  
   
    
end process;


process
variable luminance : std_logic_vector(7 downto 0);
variable r_yellow, r_blue, r_gray : std_logic_vector(7 downto 0);
variable g_yellow, g_blue, g_gray : std_logic_vector(7 downto 0);
variable b_yellow, b_blue, b_gray : std_logic_vector(7 downto 0);

begin

  wait until rising_edge(clk);
-- output processing
-- assign the pixel a value depending on the output of the neural network

luminance := y(8);

-- yellow: amplify red and green
r_yellow := '1' & luminance(7 downto 1);
g_yellow := '1' & luminance(7 downto 1);
b_yellow := '0' & luminance(7 downto 1);

-- blue: amplify blue
r_blue   := '0' & luminance(7 downto 1);
g_blue   := '0' & luminance(7 downto 1);
b_blue   := '1' & luminance(7 downto 1);

-- gray: use luminance
r_gray   := luminance;
g_gray   := luminance;
b_gray   := luminance;


           if (connection(11)= 252 and   connection(10)= 2 and 
			      connection(3) = 2 and    connection(4)=252 and 
					connection(5) = 2 and   connection(6)=252  and
					connection(7) = 2 and   connection(8)=252   and
					connection(9) = 2 ) then	
					
					 result_r <= "11111111";
                result_g <= "11111111";
                result_b <= "00000000";
					 
	else	 

       if(connection(11) > 127) then
      
            if(connection(11) > connection(10)) then
				
				   
				
                -- yellow
		 	if(connection(11) > 251 and  3 > connection(10) and 
				   connection(3)  = 6 and  251 < connection(4) and 
					connection(5) < 3 and  251 < connection(6)  and
					connection(7) < 3 and  251 < connection(8)   and
					connection(9) < 3 ) then	 
             
                result_r <= "11111111";
                result_g <= "00000000";
                result_b <= "00000000";
					 
			elsif (connection(11) > 184 and  3 > connection(10) and 
				   connection(3) = 99 and  251 < connection(4) and 
					connection(5) = 36 and  240 < connection(6)  and
					connection(7) = 29  and  251 < connection(8)   and
					connection(9) >= 5 ) then	
					   
					 result_r <= "00000000";
                result_g <= "11111111";
                result_b <= "00000000";
		  
			     
		
				else
				     result_r <= r_yellow;
                 result_g <= g_yellow;
                 result_b <= b_yellow;
				end if;	 
					 
            else
                -- blue
                result_r <= r_blue;
                result_g <= g_blue;
                result_b <= b_blue;
            end if;
      elsif (connection(10)>127) then
            -- blue
            result_r <= r_blue;
            result_g <= g_blue;
            result_b <= b_blue;

      else
            -- gray
            result_r <= r_gray;
            result_g <= g_gray;
            result_b <= b_gray;
      end if;
end if;
    -- output FFs 
    vs_out  <= vs_1;
    hs_out  <= hs_1;
   -- de_out  <= de_1;
    r_outt   <= result_r;
    g_outt   <= result_g;
    b_outt   <= result_b;
	 
	 
	 case control_2 is 
	 when '0' =>
	 r_outt   <= result_r;
    g_outt   <= result_g;
    b_outt   <= result_b; 
	 
	 when '1' =>
	 r_outt   <= disp_RGB_R;
    g_outt   <= disp_RGB_G;
    b_outt   <= disp_RGB_B; 
	 
 end case;
end process;

                     

                     

     




      
    
	 
	 -- r_o <= r_out ;
    -- g_o <= g_out ;
    -- b_o <= b_out ;
	 
	 --case r_out is 
	-- when "00000000" =>
	-- r_o<= '0';
	-- when others =>
	-- r_o<= '1';
	-- end case;
	 































--r_o <= '0' when (r_out <= "00000000") else '1';
--g_o <= '0' when (g_out <= "00000000") else '1';
--b_o <= '0' when (b_out <= "00000000") else '1';




end behave;
	
		
		
		
		
		
		
		





		