# origin_VGA
## VGA參數

這次題目我是要製作一個解析度為640x480且畫面更新率60Hz的VGA掃描程式。

首先，VGA的掃描分成水平掃描和垂直掃描，內部在更細分成{同步脈衝寬度,後沿,前沿,顯示寬度}，宣告如下:

    constant B : integer := 96; -- 水平同步脈衝寬度
    constant C : integer := 48; -- 水平後沿
    constant D : integer := 640; -- 水平顯示寬度
    constant E : integer := 16; -- 水平前沿
    constant A : integer := 800; -- 水平長度
    
    constant P : integer := 2; -- 垂直同步脈衝寬度
    constant Q : integer := 33; -- 垂直後沿
    constant R : integer := 480; -- 垂直顯示寬度
    constant S : integer := 10; -- 垂直前沿
    constant O : integer := 525; -- 垂直長度

同步脈衝寬度是代表每個水平和垂直的開始與結束，有這段時間能夠幫助顯示器定位當前的行與列。缺少此部分可能會導致顯示器無法正常定位，使圖像失真甚至無法顯示。

後沿是同步脈衝結束到顯示開始的時間，這是給顯示器做好準備去接收後面的顯示時間中資料的時間。缺少此部分可能會導致顯示器數據解讀錯誤，使畫面撕裂或閃爍。

前沿是顯示結束到下次同步脈衝開始的時間，這是給顯示器做好準備去接收下一筆資料的時間。

## 頻率決定

再來決定頻率的部分，頻率的計算為"水平長度x垂直長度x畫面更新率"，所以可得25,200,000Hz約為25MHz，而我的系統頻率為100MHz，所以除頻器需要除4，內容如下:

    signal divclk: STD_LOGIC;
    signal divcnt: integer := 0;
    constant divisor : integer := 4;
    
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

## 螢幕掃描

有了工作時脈後，就可以透過計數器進行畫面的掃描，horizontal進行水平座標掃秒，vertical進行垂直座標掃秒，程式如下:

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

## 畫面顯示

有了畫面掃描功能後，就可以透過垂直和水平座標在畫面上顯示我們想要的圖案，下面就用矩形、三角形和圓形舉例:

    picture : process(vertical, horizontal)
    begin
        -- mapping of the variable to the signals
         -- negative signs are because the conversion bits are reversed
        --if  vertical < 360 and horizontal < 350  then
        if  vertical < 2 * horizontal + 120 and vertical < (-1) * horizontal + 300 and vertical > 240  then --三角形
          red <= "1111";
        else
          red <= "0000";
        end if;
        
        if  vertical < 360 and horizontal > 250 and horizontal < 640  then  --矩形
          green <= "1111";
        else
          green <= "0000";
        end if;
        
        if  (((circle_b * circle_b)*(vertical - 300) * (vertical - 300)) + ((circle_a * circle_a)*(horizontal - 325) * (horizontal - 325))) < (circle_a * circle_a) * (circle_b * circle_b)  then  --橢圓
          blue <= "1111";
        else
          blue <= "0000";
        end if;
    end process;

## 橢圓長短邊

在執行上面的程式時，如果我們使用的橢圓公式長短邊相同的情況下會變成圓形公式，但這時會發現畫面上顯示的是橢圓而不是正圓。

所以要去調整橢圓的長短邊使橢圓變為正圓，程式內容如下:

宣告部分:

    signal circle_a : integer := 100;
    signal delta_circle : integer := 5;
    signal circle_b : integer := 100;

程式部分:

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

# VGA_VTC

## 新增額外VGA參數

VTC是使用過去PWM的概念下去做出VGA的功能，同樣需要使用2個計數器交互計數，分別代表水平座標中的HIGH和LOW。而計數完成的次數是代表垂直座標，然後需要設定HIGH和LOW的範圍。

宣告部分:

    signal pwm : STD_LOGIC;  --HSYNC
    signal pre_pwm : STD_LOGIC;
    signal counter_state : STD_LOGIC;  --counter FSM

    signal B : natural := 96;
    signal C : natural := 48;
    signal D : natural := 640;
    signal E : natural := 16;
    
    signal P : natural := 2;
    signal Q : natural := 33;
    signal R : natural := 480;
    signal S : natural := 10;
    
    signal upbound1 : integer := D + E + C;  --HSYNC "high" period
    signal upbound2 : integer := B;  --HSYNC "low" period
    signal horizontal : integer;
    signal vertical : integer;
    
    signal pwm_complete : STD_LOGIC;  --VSYNC
    signal pwm_count : integer := 0;  --VSYNC counter
    signal pwm_complete_range1 : integer := P;  --VSYNC "high" period
    signal pwm_complete_range2 : integer := Q + R + S;  --VSYNC "low" period
    signal pwm_set_zero : integer := P + Q + R + S;  --VSYNC max reset
    
    signal count1 : integer := 0;  --HSYNC "high" when count
    signal count2 : integer := 0;  --HSYNC "low" when count

程式部分:

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

## 顯示結果

在使用我設計的VTC去顯示時，如圖所示，會發現畫面的水平座標有整個向右移的狀況，所以會發現左邊有黑色的一條空間，並且下方的綠色矩形有變淡，推測有可能是圖案顏色超出了邊際導致的。



