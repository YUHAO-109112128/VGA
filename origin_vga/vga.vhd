Library IEEE;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vga is
    Port ( i_clk : in STD_LOGIC;
           i_swPlusa : in STD_LOGIC;
           i_swSuba : in STD_LOGIC;
           i_swPlusb : in STD_LOGIC;
           i_swSubb : in STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0);
           H : out STD_LOGIC;
           V : out STD_LOGIC);
end vga;

architecture Behavioral of vga is
signal swPlusa : STD_LOGIC;
signal swPlusa_count : integer;
signal swSuba : STD_LOGIC;
signal swSuba_count : integer;
signal swPlusb : STD_LOGIC;
signal swPlusb_count : integer;
signal swSubb : STD_LOGIC;
signal swSubb_count : integer;
constant sw_count_cycle : integer := 100;

subtype counter is std_logic_vector(9 downto 0);
signal vertical: integer := 0;
signal horizontal: integer := 0;

signal circle_a : integer := 100;
signal delta_circle : integer := 5;
signal circle_b : integer := 100;

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

signal divclk: STD_LOGIC;
signal divcnt: INTEGER := 0;
constant divisor : INTEGER := 4;

begin

swPlusa_handling:process(i_clk, i_swPlusa)
begin
    if i_clk'event and i_clk = '1' then
        if (i_swPlusa = '1') then  --確認按鈕按下
            if swPlusa_count < 100 then  --彈跳處理時間
                swPlusa_count <= swPlusa_count + 1;
            elsif swPlusa_count = 100 then  --確認按下按鈕後輸出一個clk的訊號
                swPlusa <= '1';
                swPlusa_count <= swPlusa_count + 1;
            else  --要放開按鈕才可以按第二次
                swPlusa <= '0';
            end if;
        else  --按鈕放開後重置計數
            swPlusa_count <= 0;
            swPlusa <= '0';
        end if;
    end if;
end process;

swSuba_handling:process(i_clk, i_swSuba)
begin
    if i_clk'event and i_clk = '1' then
        if (i_swSuba = '1') then  --確認按鈕按下
            if swSuba_count < 100 then  --彈跳處理時間
                swSuba_count <= swSuba_count + 1;
            elsif swSuba_count = 100 then  --確認按下按鈕後輸出一個clk的訊號
                swSuba <= '1';
                swSuba_count <= swSuba_count + 1;
            else  --要放開按鈕才可以按第二次
                swSuba <= '0';
            end if;
        else  --按鈕放開後重置計數
            swSuba_count <= 0;
            swSuba <= '0';
        end if;
    end if;
end process;

swPlusb_handling:process(i_clk, i_swPlusb)
begin
    if i_clk'event and i_clk = '1' then
        if (i_swPlusb = '1') then  --確認按鈕按下
            if swPlusb_count < 100 then  --彈跳處理時間
                swPlusb_count <= swPlusb_count + 1;
            elsif swPlusb_count = 100 then  --確認按下按鈕後輸出一個clk的訊號
                swPlusb <= '1';
                swPlusb_count <= swPlusb_count + 1;
            else  --要放開按鈕才可以按第二次
                swPlusb <= '0';
            end if;
        else  --按鈕放開後重置計數
            swPlusb_count <= 0;
            swPlusb <= '0';
        end if;
    end if;
end process;

swSubb_handling:process(i_clk, i_swSubb)
begin
    if i_clk'event and i_clk = '1' then
        if (i_swSubb = '1') then  --確認按鈕按下
            if swSubb_count < 100 then  --彈跳處理時間
                swSubb_count <= swSubb_count + 1;
            elsif swSubb_count = 100 then  --確認按下按鈕後輸出一個clk的訊號
                swSubb <= '1';
                swSubb_count <= swSubb_count + 1;
            else  --要放開按鈕才可以按第二次
                swSubb <= '0';
            end if;
        else  --按鈕放開後重置計數
            swSubb_count <= 0;
            swSubb <= '0';
        end if;
    end if;
end process;

vga_counter:process
    --variable vertical, horizontal : counter;  -- define counters
  begin
    wait until divclk = '1';

  -- increment counters
      if  horizontal < A - 1  then
        horizontal <= horizontal + 1;
      else
        horizontal <= 0;

        if  vertical < O - 1  then -- less than oh
          vertical <= vertical + 1;
        else
          vertical <= 0;       -- is set to zero
        end if;
      end if;

  -- define H pulse
      if  horizontal >= (D + E)  and  horizontal < (D + E + B)  then
        H <= '0';
      else
        H <= '1';
      end if;

  -- define V pulse
      if  vertical >= (R + S)  and  vertical < (R + S + P)  then
        V <= '0';
      else
        V <= '1';
      end if;
end process;

picture_adjust : process(i_clk, swSuba, swPlusa, swSubb, swPlusb)
begin
    if i_clk'event and i_clk = '1' then
        if swSuba = '1' then
            if circle_a > 50 then
                circle_a <= circle_a - delta_circle;
            end if;
        elsif swPlusa = '1' then
            if circle_a < 150 then
                circle_a <= circle_a + delta_circle;
            end if;
        elsif swSubb = '1' then
            if circle_b > 50 then
                circle_b <= circle_b - delta_circle;
            end if;
        elsif swPlusb = '1' then
            if circle_b < 150 then
                circle_b <= circle_b + delta_circle;
            end if;
        end if;
    end if;
end process;

picture : process(vertical, horizontal)
begin
    -- mapping of the variable to the signals
     -- negative signs are because the conversion bits are reversed
    --if  vertical < 360 and horizontal < 350  then
    if  vertical < 2 * horizontal + 120 and vertical < (-1) * horizontal + 300 and vertical > 240  then
      red <= "1111";
    else
      red <= "0000";
    end if;
    
    --if  vertical < 360 and horizontal > 250 and horizontal < 640  then
    if  vertical < 360 and horizontal > 250 and horizontal < 640  then
      green <= "1111";
    else
      green <= "0000";
    end if;
    
    --if  vertical > 120 and vertical < 480 and horizontal > 150 and horizontal < 500  then
    --if  (((vertical - 300) * (vertical - 300)) + ((horizontal - 325) * (horizontal - 325))) < (175 * 175)  then
    if  (((circle_b * circle_b)*(vertical - 300) * (vertical - 300)) + ((circle_a * circle_a)*(horizontal - 325) * (horizontal - 325))) < (circle_a * circle_a) * (circle_b * circle_b)  then
      blue <= "1111";
    else
      blue <= "0000";
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
