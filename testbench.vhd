LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 -- Testbench VHDL code for traffic light controller 

ENTITY tb_traffic_light_controller IS
END tb_traffic_light_controller;

ARCHITECTURE behavioral OF tb_traffic_light_controller IS 
    -- Component Declaration for the traffic light controller 
    COMPONENT traffic_light_controller
    PORT(
         push_botton : IN  std_logic;
         clk : IN  std_logic;
         rst : IN  std_logic;
         Car_light : OUT  std_logic_vector(2 downto 0);
         Ped_light : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
   signal push_botton : std_logic := '0';
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
  --Outputs
   signal Car_light : std_logic_vector(2 downto 0);
   signal Ped_light : std_logic_vector(2 downto 0);
   constant clk_period : time := 10 ns;
BEGIN
 -- Instantiate the traffic light controller 
   trafficlightcontroller : traffic_light_controller PORT MAP (
          push_botton => push_botton,
          clk => clk,
          rst => rst,
          Car_light => Car_light,
          Ped_light => Ped_light
        );
   -- Clock process definitions
   clk_process :process
   begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
   end process;
   stim_proc: process
   begin    
  rst <= '0';
  push_botton <= '0';
      wait for clk_period*10;
  rst <= '1';
  wait for clk_period*20;
  push_botton <= '1';
  wait for clk_period*100;
  push_botton <= '0';
      wait;
   end process;

END;