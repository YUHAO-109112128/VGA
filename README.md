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

------------------------------------------------------
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

------------------------------------------------------
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

------------------------------------------------------
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

------------------------------------------------------
