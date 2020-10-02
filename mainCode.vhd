-- 01/09/2020-- Marouamx

library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity TrafficLight is 

port (   Clk : in std_logic; 
			rst : in std_logic; -- for reset active low -- Car_G_Ped_R mode 
			push_botton : in std_logic; 
			Car_light : out std_logic_vector(2 downto 0); -- light order : RED_AMBER_GREEN
			Ped_light : out std_logic_vector(2 downto 0) -- light order : RED_AMBER_GREEN
			
		);
		
end TrafficLight; 

architecture light_controller of TrafficLight is 

signal counter_1s: std_logic_vector(27 downto 0):= x"0000000"; 
signal delay_count:std_logic_vector(3 downto 0):= x"0";
signal delay_10s, delay_3s_Car,delay_3s_Ped, RED_LIGHT_ENABLE, AMBER_LIGHT1_ENABLE,AMBER_LIGHT2_ENABLE: std_logic:='0';
signal clk_1s_enable: std_logic; -- 1s clock enable 

type light_States is (CARGRE_PEDRED, CARAMB_PEDRED, CARRED_PEDGRE, CARRED_PEDAMB);
-- CARGRE_PEDRED : traffic light green and pedestrian light red

signal current_state, next_state: light_States;
begin 
process(clk,rst) 
	begin
		if(rst='0') then
			current_state <= CARGRE_PEDRED;
		elsif(rising_edge(clk)) then 
		 current_state <= next_state; 
		end if; 
	end process;


process(current_state,push_botton,delay_3s_Car,delay_3s_ped,delay_10s)


	begin
	case current_state is 
		when CARGRE_PEDRED => -- When Green light on Traffic and Red light on pedestrian
			 RED_LIGHT_ENABLE <= '0';-- disable RED light delay counting
			 AMBER_LIGHT1_ENABLE<= '0';-- disable AMBER light Traffic delay counting
			 AMBER_LIGHT1_ENABLE<= '0';-- disable AMBER light Pedestrian delay counting
			 car_light <= "001"; -- Green light ofor cars
			 Ped_light <= "100"; -- Red light for pedtrian 
			 if(push_botton = '1') then -- if a ped is there
				next_state <= CARAMB_PEDRED; 
				-- High way turns to amber light 
			 else 
				next_state <= CARGRE_PEDRED; 
				-- Otherwise, remains GREEN ON highway and RED for peds
			 end if;
		when CARAMB_PEDRED => 
			Car_light <= "010";-- Amber light on Highway
			Ped_light <= "100";-- Red light for peds 
			RED_LIGHT_ENABLE <= '0';-- disable RED light delay counting
			AMBER_LIGHT1_ENABLE <= '1';-- enable AMBER light Highway delay counting
			AMBER_LIGHT2_ENABLE <= '0';-- disable AMBER light Pedestrian delay counting
			if(delay_3s_Car='1') then 
			
				-- if amber light delay counts to 3s, 
				-- turn Highway to RED, 
				-- ped way to green light 
				next_state <= CARRED_PEDGRE; 
			else 
				
				next_state <= CARAMB_PEDRED; 
				-- Remains amber on highway and Red on pedestrian way  
				-- if AMber light not yet in 3s 
			end if;
	
		when CARRED_PEDGRE=> 
			Car_light <= "100";-- RED light on Highway 
			Ped_light <= "001";-- GREEN light on PED way 
			RED_LIGHT_ENABLE <= '1';-- enable RED light delay counting
			AMBER_LIGHT1_ENABLE <= '0';-- disable AMBER light Highway delay counting
			AMBER_LIGHT2_ENABLE <= '0';-- disable AMBER light Pedestrian delay counting
			
			if(delay_10s='1') then
				-- if RED light on highway is 10s, ped way turns to amber
				next_state <= CARRED_PEDAMB;
			else 
				next_state <= CARRED_PEDGRE; 
				-- Remains if delay counts for RED light on highway not enough 10s 
			end if;
			
		when CARRED_PEDAMB =>
			Car_light <= "100";-- RED light on Highway 
			Ped_light <= "010";-- amber light on ped way 
			RED_LIGHT_ENABLE <= '0'; -- disable RED light delay counting
			AMBER_LIGHT1_ENABLE <= '0';-- disable AMBER light Highway delay counting
			AMBER_LIGHT2_ENABLE <= '1';-- enable AMBER light Pedestrian delay counting
			
			if(delay_3s_Ped='1') then 
				
				-- if delay for amber light is 3s,
				-- turn highway to GREEN light
				-- PED way to RED Light
				next_state <= CARGRE_PEDRED;
			else 
				next_state <= CARRED_PEDAMB;
				-- if not enough 3s, remain the same state 
			end if;
		when others => next_state <= CARGRE_PEDRED; -- Green on highway, red on Ped way 
		end case;
end process;


-- Delay counts for Yellow and RED light  
process(clk)
begin
	if(rising_edge(clk)) then 
		if(clk_1s_enable='1') then
			if(RED_LIGHT_ENABLE='1' or AMBER_LIGHT1_ENABLE='1' or AMBER_LIGHT2_ENABLE='1') then
				delay_count <= delay_count + x"1";
				if((delay_count = x"9") and RED_LIGHT_ENABLE ='1') then 
					delay_10s <= '1';
					delay_3s_car <= '0';
					delay_3s_ped <= '0';
					delay_count <= x"0";
				elsif((delay_count = x"2") and AMBER_LIGHT1_ENABLE= '1') then
				delay_10s <= '0';
				delay_3s_Car <= '1';
				delay_3s_Ped <= '0';
				delay_count <= x"0";
			  elsif((delay_count = x"2") and AMBER_LIGHT2_ENABLE= '1') then
				delay_10s <= '0';
				delay_3s_Car <= '0';
				delay_3s_Ped <= '1';
				delay_count <= x"0";
			  else
				delay_10s <= '0';
				delay_3s_Car <= '0';
				delay_3s_Ped <= '0';
				end if;
			end if;
		end if;
	end if;
end process;



-- create delay 1s
process(clk)
begin
	if(rising_edge(clk)) then 
		counter_1s <= counter_1s + x"0000001";
		if(counter_1s >= x"0000003") then -- x"0004" is for simulation
			-- change to x"2FAF080" for 50 MHz clock running real DE0-nano
			counter_1s <= x"0000000";
		end if;
	end if;
end process;

clk_1s_enable <= '1' when counter_1s = x"0003" else '0'; -- x"0002" is for simulation
-- x"2FAF080" for 50Mhz clock on DE0-nano
end architecture; 
