----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/12/25 15:53:22
-- Design Name: 
-- Module Name: vgapingpong - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vgapingpong is
    Port ( i_rst : in STD_LOGIC;
           i_clk : in STD_LOGIC;
           i_swL : in STD_LOGIC;
           i_swR : in STD_LOGIC;
           i_swPlusa : in STD_LOGIC;
           i_swSuba : in STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0);
           H : out STD_LOGIC;
           V : out STD_LOGIC;
           o_led : out STD_LOGIC_VECTOR (7 downto 0));
end vgapingpong;

architecture Behavioral of vgapingpong is
signal swPlusa : STD_LOGIC;
signal swPlusa_count : integer;
signal swSuba : STD_LOGIC;
signal swSuba_count : integer;
signal swL : STD_LOGIC;
signal swR : STD_LOGIC;
signal swR_count : integer;
signal swL_count : integer;
constant sw_count_cycle : integer := 100;

subtype counter is std_logic_vector(9 downto 0);
signal vertical: integer := 0;
signal horizontal: integer := 0;

signal circle_a : integer := 20;
signal delta_circle : integer := 1;
signal circle_b : integer := 20;

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

constant ball_initial_positionx : natural := 320;
constant ball_initial_positiony : natural := 240;
constant ball_left_limit : natural := 40;
constant ball_right_limit : natural := 600;
signal ball_positionx : natural;
signal ball_pre_positionx : natural;
signal ball_positiony : natural;
signal ball_move_distance : natural := 70;

signal led_mode : STD_LOGIC_VECTOR (2 downto 0);
signal prev_led_mode : STD_LOGIC_VECTOR (2 downto 0);
signal led : STD_LOGIC_VECTOR (7 downto 0);

signal scoreL : STD_LOGIC_VECTOR (3 downto 0);
signal scoreR : STD_LOGIC_VECTOR (3 downto 0);

signal divclk: STD_LOGIC;
signal divcnt: INTEGER := 0;
constant divisor : INTEGER := 20000000;

signal divclkvga: STD_LOGIC;
signal divcntvga: INTEGER := 0;
constant divisorvga : INTEGER := 4;
begin
o_led <= led;
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

--swR_handling: 右側按鈕處理
swR_handling:process(i_clk, i_rst, i_swR)
begin
    if i_rst = '1' then
        swR_count <= 0;
        swR <= '0';
    elsif i_clk'event and i_clk = '1' then
        if (i_swR = '1') then  --確認右側按鈕按下
            if swR_count < 100 then  --彈跳處理時間
                swR_count <= swR_count + 1;
            elsif swR_count = 100 then  --確認按下按鈕後輸出一個clk的訊號
                swR <= '1';
                swR_count <= swR_count + 1;
            else  --要放開按鈕才可以按第二次
                swR <= '0';
            end if;
        else  --按鈕放開後重置計數
            swR_count <= 0;
            swR <= '0';
        end if;
    end if;
end process;

--swL_handling: 左側按鈕處理
swL_handling:process(i_clk, i_rst, i_swL)
begin
    if i_rst = '1' then
        swL_count <= 0;
        swL <= '0';
    elsif i_clk'event and i_clk = '1' then
        if (i_swL = '1') then  --確認左側按鈕按下
            if swL_count < 100 then  --彈跳處理時間
                swL_count <= swL_count + 1;
            elsif swL_count = 100 then  --確認按下按鈕後輸出一個clk的訊號
                swL <= '1';
                swL_count <= swL_count + 1;
            else  --要放開按鈕才可以按第二次
                swL <= '0';
            end if;
        else  --按鈕放開後重置計數
            swL_count <= 0;
            swL <= '0';
        end if;
    end if;
end process;


FSM:process(i_clk, i_rst, swL, swR, scoreL, scoreR)
begin
    if i_rst = '1' then
        led_mode <= "000";
    elsif i_clk'event and i_clk = '1' then
        case led_mode is
            when "000" =>  --決定發球權
                if swR = '1' then  --右邊取得初始發球權，右邊發球
                    led_mode <= "001";
                elsif swL = '1' then  --左邊取得初始發球權，左邊發球
                    led_mode <= "100";
                else
                    null;
                end if;
            when "001" =>  -- 右邊發球
                if swR = '1' then  --右邊發球，球往左移
                    led_mode <= "110";
                else
                    null;
                end if;
            when "010" =>  --右邊得分
                if scoreR = "1111" then  --右邊滿分比賽結束
                    led_mode <= "111";
                elsif swR = '1' then  --右邊得分f且比賽尚未結束，右邊取得發球權
                    led_mode <= "001";
                else
                    null;
                end if;
            when "011" =>  --球往右移
                if ball_positionx = ball_right_limit and swR = '1' then  --球到最右邊後擊打成功，球往右移
                    led_mode <= "110";
                elsif ball_pre_positionx = ball_right_limit or swR = '1' then  --球還未到最右邊就擊打或是右邊擊打失敗，左邊得分
                    led_mode <= "101";
                else  --還沒到最右邊，繼續右移
                    led_mode <= "011";
                end if;
            when "100" =>  --左邊發球
                if swL = '1' then --左邊發球，球往右移
                    led_mode <= "011";
                else
                    null;
                end if;
            when "101" =>  --左邊得分
                if scoreL = "1111" then  --左邊滿分比賽結束
                    led_mode <= "111";
                elsif swL = '1' then  --左邊得分f且比賽尚未結束，左邊取得發球權
                    led_mode <= "100";
                else
                    null;
                end if;
            when "110" =>  --球往左移
                if ball_positionx = ball_left_limit and swL = '1' then  --球到最左邊後擊打成功，球往右移
                    led_mode <= "011";
                elsif ball_pre_positionx = ball_left_limit or swL = '1' then  --球還未到最左邊就擊打或是左邊擊打失敗，右邊得分
                    led_mode <= "010";
                else  --還沒到最左邊，繼續左移
                    led_mode <= "110";
                end if;
            when "111" =>  --比賽結束
                null;
            when others =>
                led_mode <= "000";
        end case;
    end if;
end process;


ball_adjust : process(i_clk, swSuba, swPlusa)
begin
    if i_clk'event and i_clk = '1' then
        if swSuba = '1' then
            if circle_a > 10 then
                circle_a <= circle_a - delta_circle;
            end if;
        elsif swPlusa = '1' then
            if circle_a < 40 then
                circle_a <= circle_a + delta_circle;
            end if;
        end if;
    end if;
end process;


picture : process(vertical, horizontal)
begin
    if(led_mode = "010")then
        if  horizontal > 320  then
          red <= "1111";
        else
          red <= "0000";
       end if;
    elsif(led_mode = "101")then
        if  horizontal < 320  then
          red <= "1111";
        else
          red <= "0000";
       end if;
    elsif(led_mode = "000" or led_mode = "001" or led_mode = "011" or led_mode = "100" or led_mode = "110")then
        if  (((circle_b * circle_b)*(vertical - ball_positiony) * (vertical - ball_positiony)) + ((circle_a * circle_a)*(horizontal - ball_positionx) * (horizontal - ball_positionx))) < (circle_a * circle_a) * (circle_b * circle_b)  then
          red <= "1111";
          blue <= "1111";
          green <= "1111";
        else
          red <= "0000";
          blue <= "0000";
          green <= "0000";
        end if;
    elsif(led_mode = "111")then
          red <= "0000";
          blue <= "0000";
          green <= "0000";
    end if;
end process;


ball_position : process(divclk, i_rst, swL, swR)
begin
    if i_rst = '1' then
        ball_positionx <= ball_initial_positionx;
        ball_positiony <= ball_initial_positiony;
    elsif divclk'event and divclk = '1' then
        ball_pre_positionx <= ball_positionx;
        case led_mode is
            when "000" =>  --決定發球權
                null;
            when "001" =>  -- 右邊發球
                ball_positionx <= ball_right_limit;
                ball_positiony <= ball_initial_positiony;
            when "010" =>  --右邊得分
                null;
            when "011" =>  --球往右移
                if(ball_positionx < ball_right_limit)then
                    ball_positionx <= ball_positionx + ball_move_distance;
                end if;
                ball_positiony <= ball_initial_positiony;
            when "100" =>  --左邊發球
                ball_positionx <= ball_left_limit;
                ball_positiony <= ball_initial_positiony;
            when "101" =>  --左邊得分
                null;
            when "110" =>  --球往左移
                if(ball_positionx > ball_left_limit)then
                    ball_positionx <= ball_positionx - ball_move_distance;
                end if;
                ball_positiony <= ball_initial_positiony;
            when "111" =>  --比賽結束
                null;
            when others =>
                ball_positionx <= ball_initial_positionx;
                ball_positiony <= ball_initial_positiony;
        end case;
    end if;
end process;


led_reg:process(divclk, i_rst, swL, swR, scoreL, scoreR)
begin
    if i_rst = '1' then
        led <= "0000" & "0000";
    elsif divclk'event and divclk = '1' then
        case led_mode is
            when "000" =>  --決定發球權
                led <= "0000" & "0000";
            when "001" =>  -- 右邊發球
                led <= "0000" & "0001";
            when "010" =>  --右邊得分
                led <= scoreL & scoreR;
            when "011" =>  --球往右移
                if led = "0000" & "0000" then
                    null;
                else
                    led <= '0' & led(7 downto 1);
                end if;
            when "100" =>  --左邊發球
                led <= "1000" & "0000";
            when "101" =>  --左邊得分
                led <= scoreL & scoreR;
            when "110" =>  --球往左移
                if led = "0000" & "0000" then
                    null;
                else
                    led <= led(6 downto 0) & '0';
                end if;
            when "111" =>  --比賽結束
                if scoreL = "1111" then
                    led <= "1111" & "0000";
                end if;
                if scoreR = "1111" then
                    led <= "0000" & "1111";
                end if;
            when others =>
        end case;
    end if;
end process;


score_sign:process(i_rst, divclk, led_mode)
begin
    if i_rst = '1' then
        scoreL <= "0000";
        scoreR <= "0000";
    elsif divclk'event and divclk = '1' then
        prev_led_mode <= led_mode;
        case led_mode is
            when "000" =>  --決定發球權
                null;
            when "001" =>  -- 右邊發球
                null;
            when "010" =>  --右邊得分
                if prev_led_mode = "110" then
                    scoreR <= scoreR + '1';
                else
                    null;
                end if;
            when "011" =>  --球往右移
                null;
            when "100" =>  --左邊發球
                null;
            when "101" =>  --左邊得分
                if prev_led_mode = "011" then
                    scoreL <= scoreL + '1';
                else
                    null;
                end if;
            when "110" =>  --球往左移
                null;
            when "111" =>  --比賽結束
                scoreL <= "0000";
                scoreR <= "0000";
            when others =>
                null;
        end case;
    end if;
end process;


division: process(i_clk, i_rst, divcnt)
begin
    if i_rst = '1' then
        divcnt <= 0;
        divclk <= '0';
        divcntvga <= 0;
        divclkvga <= '0';
    elsif i_clk'event and i_clk = '1' then
        if divcnt = (divisor/2) - 1 then
            divcnt <= 0;
            divclk <= not divclk;
        else
            divcnt <= divcnt + 1;
        end if;
        if divcntvga = (divisorvga/2) - 1 then
            divcntvga <= 0;
            divclkvga <= not divclkvga;
        else
            divcntvga <= divcntvga + 1;
        end if;
    end if;
end process;


vga_counter:process
    --variable vertical, horizontal : counter;  -- define counters
  begin
    wait until divclkvga = '1';

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



end Behavioral;
