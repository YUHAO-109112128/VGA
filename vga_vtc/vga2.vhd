----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/12/09 14:37:36
-- Design Name: 
-- Module Name: vga2 - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga2 is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           H : out STD_LOGIC;
           V : out STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end vga2;

architecture Behavioral of vga2 is
signal pwm : STD_LOGIC;  --HSYNC
signal pre_pwm : STD_LOGIC;
signal counter_state : STD_LOGIC;  --counter FSM

signal swPlusa : STD_LOGIC;
signal swPlusa_count : integer;
signal swSuba : STD_LOGIC;
signal swSuba_count : integer;
signal swL : STD_LOGIC;
signal swR : STD_LOGIC;
signal swR_count : integer;
signal swL_count : integer;
constant sw_count_cycle : integer := 100;

signal B : natural := 96;
signal C : natural := 48;
signal D : natural := 640;
signal E : natural := 16;
signal A : natural := B + C + D + E;

signal P : natural := 2;
signal Q : natural := 33;
signal R : natural := 480;
signal S : natural := 10;
signal O : natural := P + Q + R + S;

signal upbound1 : integer := D + E + C;  --HSYNC begin "high"
signal upbound2 : integer := B;  --HSYNC begin "low"
signal horizontal : integer;
signal vertical : integer;

signal pwm_complete : STD_LOGIC;  --VSYNC
signal pwm_count : integer := 0;  --VSYNC counter
signal pwm_complete_range1 : integer := P;  --VSYNC begin "high" when pwm_count > pwm_complete_range1
signal pwm_complete_range2 : integer := Q + R + S;  --VSYNC begin "low" when pwm_count < pwm_complete_range2
signal pwm_set_zero : integer := P + Q + R + S;

signal count1 : integer := 0;  --HSYNC "high" when count
signal count2 : integer := 0;  --HSYNC "low" when count

signal divclk: STD_LOGIC;
signal divcnt: integer := 0;
constant divisor : integer := 4;
begin
pwm <= counter_state;
H <= pwm;
V <= pwm_complete;


picture_display : process(count1, pwm_count)
begin
    horizontal <= count1 - E - C;
    vertical <= pwm_count - P - Q;
    if  vertical < 360 and horizontal < 350 and horizontal > 0 then
        red <= "1111";
    else
        red <= "0000";
    end if;
    if  vertical < 360 and horizontal > 250 and horizontal < 640  then
        green <= "1111";
    else
        green <= "0000";
    end if;
    if  vertical > 120 and vertical < 480 and horizontal > 150 and horizontal < 500  then
        blue <= "1111";
    else
        blue <= "0000";
    end if;
end process;

counter_complete : process(divclk, counter_state)
begin
    if i_rst = '1' then
        pwm_count <= 0;
        pwm_complete <= '0';
    elsif divclk'event and divclk = '1' then
        pre_pwm <= pwm;
        if pwm_count >= pwm_set_zero then
            pwm_count <= 0;
        elsif pre_pwm = '1' and pwm = '0' then
            pwm_count <= pwm_count + 1;
        end if;
        
        if pwm_count > pwm_complete_range2 then
            pwm_complete <= '0';
        else
            pwm_complete <= '1';
        end if;
    end if;
end process;

counter_FSM : process(i_clk, i_rst, count1, count2)
begin
    if i_rst = '1' then
        counter_state <= '0';
    elsif i_clk'event and i_clk = '1' then
        case counter_state is
            when '0' =>
                if count1 >= upbound1 then
                    counter_state <= '1';
                end if;
            when '1' =>
                if count2 > upbound2 then
                    counter_state <= '0';
                end if;
            when others =>
                counter_state <= '0';
        end case;
    end if;
end process;

counter1 : process(divclk, i_rst, upbound1, counter_state)
begin
    if i_rst = '1' then
        count1 <= 0;
    elsif divclk'event and divclk = '1' then
        case counter_state is
            when '0' =>
                if count1 < upbound1 then
                    count1 <= count1 + 1;
                end if;
            when '1' =>
                count1 <= 0;
            when others =>
                count1 <= 0;
        end case;
    end if;
end process;

counter2 : process(divclk, i_rst, upbound2, counter_state)
begin
    if i_rst = '1' then
        count2 <= 0;
    elsif divclk'event and divclk = '1' then
        case counter_state is
            when '0' =>
                count2 <= 0;
            when '1' =>
                if count2 <= upbound2 then
                    count2 <= count2 + 1;
                end if;
            when others =>
                count2 <= 0;
        end case;
    end if;
end process;

division: process(i_clk, divcnt)
begin
    if i_clk'event and i_clk = '1' then
        if divcnt = (divisor/2) - 1 then
            divcnt <= 0;
            divclk <= not divclk;
        else
            divcnt <= divcnt + 1;
        end if;
    end if;
end process;

end Behavioral;
