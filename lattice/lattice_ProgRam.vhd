-- VHDL netlist generated by SCUBA Diamond (64-bit) 3.3.0.109
-- Module  Version: 7.4
--/usr/local/diamond/3.3_x64/ispfpga/bin/lin64/scuba -w -n lattice_ProgRam -lang vhdl -synth synplify -bus_exp 7 -bb -arch mg5a00 -type bram -wp 10 -rp 1000 -addr_width 13 -data_width 8 -num_rows 8192 -outdata REGISTERED -writemode NORMAL -resetmode SYNC -cascade -1 

-- Thu Dec 25 19:37:47 2014

library IEEE;
use IEEE.std_logic_1164.all;
-- synopsys translate_off
library xp2;
use xp2.components.all;
-- synopsys translate_on

entity lattice_ProgRam is
    port (
        Clock: in  std_logic; 
        ClockEn: in  std_logic; 
        Reset: in  std_logic; 
        WE: in  std_logic; 
        Address: in  std_logic_vector(12 downto 0); 
        Data: in  std_logic_vector(7 downto 0); 
        Q: out  std_logic_vector(7 downto 0));
end lattice_ProgRam;

architecture Structure of lattice_ProgRam is

    -- internal signal declarations
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;

    -- local component declarations
    component VHI
        port (Z: out  std_logic);
    end component;
    component VLO
        port (Z: out  std_logic);
    end component;
    component DP16KB
    -- synopsys translate_off
        generic (GSR : in String; WRITEMODE_B : in String; 
                CSDECODE_B : in std_logic_vector(2 downto 0); 
                CSDECODE_A : in std_logic_vector(2 downto 0); 
                WRITEMODE_A : in String; RESETMODE : in String; 
                REGMODE_B : in String; REGMODE_A : in String; 
                DATA_WIDTH_B : in Integer; DATA_WIDTH_A : in Integer);
    -- synopsys translate_on
        port (DIA0: in  std_logic; DIA1: in  std_logic; 
            DIA2: in  std_logic; DIA3: in  std_logic; 
            DIA4: in  std_logic; DIA5: in  std_logic; 
            DIA6: in  std_logic; DIA7: in  std_logic; 
            DIA8: in  std_logic; DIA9: in  std_logic; 
            DIA10: in  std_logic; DIA11: in  std_logic; 
            DIA12: in  std_logic; DIA13: in  std_logic; 
            DIA14: in  std_logic; DIA15: in  std_logic; 
            DIA16: in  std_logic; DIA17: in  std_logic; 
            ADA0: in  std_logic; ADA1: in  std_logic; 
            ADA2: in  std_logic; ADA3: in  std_logic; 
            ADA4: in  std_logic; ADA5: in  std_logic; 
            ADA6: in  std_logic; ADA7: in  std_logic; 
            ADA8: in  std_logic; ADA9: in  std_logic; 
            ADA10: in  std_logic; ADA11: in  std_logic; 
            ADA12: in  std_logic; ADA13: in  std_logic; 
            CEA: in  std_logic; CLKA: in  std_logic; WEA: in  std_logic; 
            CSA0: in  std_logic; CSA1: in  std_logic; 
            CSA2: in  std_logic; RSTA: in  std_logic; 
            DIB0: in  std_logic; DIB1: in  std_logic; 
            DIB2: in  std_logic; DIB3: in  std_logic; 
            DIB4: in  std_logic; DIB5: in  std_logic; 
            DIB6: in  std_logic; DIB7: in  std_logic; 
            DIB8: in  std_logic; DIB9: in  std_logic; 
            DIB10: in  std_logic; DIB11: in  std_logic; 
            DIB12: in  std_logic; DIB13: in  std_logic; 
            DIB14: in  std_logic; DIB15: in  std_logic; 
            DIB16: in  std_logic; DIB17: in  std_logic; 
            ADB0: in  std_logic; ADB1: in  std_logic; 
            ADB2: in  std_logic; ADB3: in  std_logic; 
            ADB4: in  std_logic; ADB5: in  std_logic; 
            ADB6: in  std_logic; ADB7: in  std_logic; 
            ADB8: in  std_logic; ADB9: in  std_logic; 
            ADB10: in  std_logic; ADB11: in  std_logic; 
            ADB12: in  std_logic; ADB13: in  std_logic; 
            CEB: in  std_logic; CLKB: in  std_logic; WEB: in  std_logic; 
            CSB0: in  std_logic; CSB1: in  std_logic; 
            CSB2: in  std_logic; RSTB: in  std_logic; 
            DOA0: out  std_logic; DOA1: out  std_logic; 
            DOA2: out  std_logic; DOA3: out  std_logic; 
            DOA4: out  std_logic; DOA5: out  std_logic; 
            DOA6: out  std_logic; DOA7: out  std_logic; 
            DOA8: out  std_logic; DOA9: out  std_logic; 
            DOA10: out  std_logic; DOA11: out  std_logic; 
            DOA12: out  std_logic; DOA13: out  std_logic; 
            DOA14: out  std_logic; DOA15: out  std_logic; 
            DOA16: out  std_logic; DOA17: out  std_logic; 
            DOB0: out  std_logic; DOB1: out  std_logic; 
            DOB2: out  std_logic; DOB3: out  std_logic; 
            DOB4: out  std_logic; DOB5: out  std_logic; 
            DOB6: out  std_logic; DOB7: out  std_logic; 
            DOB8: out  std_logic; DOB9: out  std_logic; 
            DOB10: out  std_logic; DOB11: out  std_logic; 
            DOB12: out  std_logic; DOB13: out  std_logic; 
            DOB14: out  std_logic; DOB15: out  std_logic; 
            DOB16: out  std_logic; DOB17: out  std_logic);
    end component;
    attribute MEM_LPC_FILE : string; 
    attribute MEM_INIT_FILE : string; 
    attribute CSDECODE_B : string; 
    attribute CSDECODE_A : string; 
    attribute WRITEMODE_B : string; 
    attribute WRITEMODE_A : string; 
    attribute GSR : string; 
    attribute RESETMODE : string; 
    attribute REGMODE_B : string; 
    attribute REGMODE_A : string; 
    attribute DATA_WIDTH_B : string; 
    attribute DATA_WIDTH_A : string; 
    attribute MEM_LPC_FILE of lattice_ProgRam_0_0_3 : label is "lattice_ProgRam.lpc";
    attribute MEM_INIT_FILE of lattice_ProgRam_0_0_3 : label is "";
    attribute CSDECODE_B of lattice_ProgRam_0_0_3 : label is "0b111";
    attribute CSDECODE_A of lattice_ProgRam_0_0_3 : label is "0b000";
    attribute WRITEMODE_B of lattice_ProgRam_0_0_3 : label is "NORMAL";
    attribute WRITEMODE_A of lattice_ProgRam_0_0_3 : label is "NORMAL";
    attribute GSR of lattice_ProgRam_0_0_3 : label is "DISABLED";
    attribute RESETMODE of lattice_ProgRam_0_0_3 : label is "SYNC";
    attribute REGMODE_B of lattice_ProgRam_0_0_3 : label is "NOREG";
    attribute REGMODE_A of lattice_ProgRam_0_0_3 : label is "OUTREG";
    attribute DATA_WIDTH_B of lattice_ProgRam_0_0_3 : label is "2";
    attribute DATA_WIDTH_A of lattice_ProgRam_0_0_3 : label is "2";
    attribute MEM_LPC_FILE of lattice_ProgRam_0_1_2 : label is "lattice_ProgRam.lpc";
    attribute MEM_INIT_FILE of lattice_ProgRam_0_1_2 : label is "";
    attribute CSDECODE_B of lattice_ProgRam_0_1_2 : label is "0b111";
    attribute CSDECODE_A of lattice_ProgRam_0_1_2 : label is "0b000";
    attribute WRITEMODE_B of lattice_ProgRam_0_1_2 : label is "NORMAL";
    attribute WRITEMODE_A of lattice_ProgRam_0_1_2 : label is "NORMAL";
    attribute GSR of lattice_ProgRam_0_1_2 : label is "DISABLED";
    attribute RESETMODE of lattice_ProgRam_0_1_2 : label is "SYNC";
    attribute REGMODE_B of lattice_ProgRam_0_1_2 : label is "NOREG";
    attribute REGMODE_A of lattice_ProgRam_0_1_2 : label is "OUTREG";
    attribute DATA_WIDTH_B of lattice_ProgRam_0_1_2 : label is "2";
    attribute DATA_WIDTH_A of lattice_ProgRam_0_1_2 : label is "2";
    attribute MEM_LPC_FILE of lattice_ProgRam_0_2_1 : label is "lattice_ProgRam.lpc";
    attribute MEM_INIT_FILE of lattice_ProgRam_0_2_1 : label is "";
    attribute CSDECODE_B of lattice_ProgRam_0_2_1 : label is "0b111";
    attribute CSDECODE_A of lattice_ProgRam_0_2_1 : label is "0b000";
    attribute WRITEMODE_B of lattice_ProgRam_0_2_1 : label is "NORMAL";
    attribute WRITEMODE_A of lattice_ProgRam_0_2_1 : label is "NORMAL";
    attribute GSR of lattice_ProgRam_0_2_1 : label is "DISABLED";
    attribute RESETMODE of lattice_ProgRam_0_2_1 : label is "SYNC";
    attribute REGMODE_B of lattice_ProgRam_0_2_1 : label is "NOREG";
    attribute REGMODE_A of lattice_ProgRam_0_2_1 : label is "OUTREG";
    attribute DATA_WIDTH_B of lattice_ProgRam_0_2_1 : label is "2";
    attribute DATA_WIDTH_A of lattice_ProgRam_0_2_1 : label is "2";
    attribute MEM_LPC_FILE of lattice_ProgRam_0_3_0 : label is "lattice_ProgRam.lpc";
    attribute MEM_INIT_FILE of lattice_ProgRam_0_3_0 : label is "";
    attribute CSDECODE_B of lattice_ProgRam_0_3_0 : label is "0b111";
    attribute CSDECODE_A of lattice_ProgRam_0_3_0 : label is "0b000";
    attribute WRITEMODE_B of lattice_ProgRam_0_3_0 : label is "NORMAL";
    attribute WRITEMODE_A of lattice_ProgRam_0_3_0 : label is "NORMAL";
    attribute GSR of lattice_ProgRam_0_3_0 : label is "DISABLED";
    attribute RESETMODE of lattice_ProgRam_0_3_0 : label is "SYNC";
    attribute REGMODE_B of lattice_ProgRam_0_3_0 : label is "NOREG";
    attribute REGMODE_A of lattice_ProgRam_0_3_0 : label is "OUTREG";
    attribute DATA_WIDTH_B of lattice_ProgRam_0_3_0 : label is "2";
    attribute DATA_WIDTH_A of lattice_ProgRam_0_3_0 : label is "2";
    attribute NGD_DRC_MASK : integer;
    attribute NGD_DRC_MASK of Structure : architecture is 1;

begin
    -- component instantiation statements
    lattice_ProgRam_0_0_3: DP16KB
        -- synopsys translate_off
        generic map (CSDECODE_B=> "111", CSDECODE_A=> "000", WRITEMODE_B=> "NORMAL", 
        WRITEMODE_A=> "NORMAL", GSR=> "DISABLED", RESETMODE=> "SYNC", 
        REGMODE_B=> "NOREG", REGMODE_A=> "OUTREG", DATA_WIDTH_B=>  2, 
        DATA_WIDTH_A=>  2)
        -- synopsys translate_on
        port map (DIA0=>scuba_vlo, DIA1=>Data(1), DIA2=>scuba_vlo, 
            DIA3=>scuba_vlo, DIA4=>scuba_vlo, DIA5=>scuba_vlo, 
            DIA6=>scuba_vlo, DIA7=>scuba_vlo, DIA8=>scuba_vlo, 
            DIA9=>scuba_vlo, DIA10=>scuba_vlo, DIA11=>Data(0), 
            DIA12=>scuba_vlo, DIA13=>scuba_vlo, DIA14=>scuba_vlo, 
            DIA15=>scuba_vlo, DIA16=>scuba_vlo, DIA17=>scuba_vlo, 
            ADA0=>scuba_vlo, ADA1=>Address(0), ADA2=>Address(1), 
            ADA3=>Address(2), ADA4=>Address(3), ADA5=>Address(4), 
            ADA6=>Address(5), ADA7=>Address(6), ADA8=>Address(7), 
            ADA9=>Address(8), ADA10=>Address(9), ADA11=>Address(10), 
            ADA12=>Address(11), ADA13=>Address(12), CEA=>ClockEn, 
            CLKA=>Clock, WEA=>WE, CSA0=>scuba_vlo, CSA1=>scuba_vlo, 
            CSA2=>scuba_vlo, RSTA=>Reset, DIB0=>scuba_vlo, 
            DIB1=>scuba_vlo, DIB2=>scuba_vlo, DIB3=>scuba_vlo, 
            DIB4=>scuba_vlo, DIB5=>scuba_vlo, DIB6=>scuba_vlo, 
            DIB7=>scuba_vlo, DIB8=>scuba_vlo, DIB9=>scuba_vlo, 
            DIB10=>scuba_vlo, DIB11=>scuba_vlo, DIB12=>scuba_vlo, 
            DIB13=>scuba_vlo, DIB14=>scuba_vlo, DIB15=>scuba_vlo, 
            DIB16=>scuba_vlo, DIB17=>scuba_vlo, ADB0=>scuba_vlo, 
            ADB1=>scuba_vlo, ADB2=>scuba_vlo, ADB3=>scuba_vlo, 
            ADB4=>scuba_vlo, ADB5=>scuba_vlo, ADB6=>scuba_vlo, 
            ADB7=>scuba_vlo, ADB8=>scuba_vlo, ADB9=>scuba_vlo, 
            ADB10=>scuba_vlo, ADB11=>scuba_vlo, ADB12=>scuba_vlo, 
            ADB13=>scuba_vlo, CEB=>scuba_vhi, CLKB=>scuba_vlo, 
            WEB=>scuba_vlo, CSB0=>scuba_vlo, CSB1=>scuba_vlo, 
            CSB2=>scuba_vlo, RSTB=>scuba_vlo, DOA0=>Q(0), DOA1=>Q(1), 
            DOA2=>open, DOA3=>open, DOA4=>open, DOA5=>open, DOA6=>open, 
            DOA7=>open, DOA8=>open, DOA9=>open, DOA10=>open, DOA11=>open, 
            DOA12=>open, DOA13=>open, DOA14=>open, DOA15=>open, 
            DOA16=>open, DOA17=>open, DOB0=>open, DOB1=>open, DOB2=>open, 
            DOB3=>open, DOB4=>open, DOB5=>open, DOB6=>open, DOB7=>open, 
            DOB8=>open, DOB9=>open, DOB10=>open, DOB11=>open, 
            DOB12=>open, DOB13=>open, DOB14=>open, DOB15=>open, 
            DOB16=>open, DOB17=>open);

    lattice_ProgRam_0_1_2: DP16KB
        -- synopsys translate_off
        generic map (CSDECODE_B=> "111", CSDECODE_A=> "000", WRITEMODE_B=> "NORMAL", 
        WRITEMODE_A=> "NORMAL", GSR=> "DISABLED", RESETMODE=> "SYNC", 
        REGMODE_B=> "NOREG", REGMODE_A=> "OUTREG", DATA_WIDTH_B=>  2, 
        DATA_WIDTH_A=>  2)
        -- synopsys translate_on
        port map (DIA0=>scuba_vlo, DIA1=>Data(3), DIA2=>scuba_vlo, 
            DIA3=>scuba_vlo, DIA4=>scuba_vlo, DIA5=>scuba_vlo, 
            DIA6=>scuba_vlo, DIA7=>scuba_vlo, DIA8=>scuba_vlo, 
            DIA9=>scuba_vlo, DIA10=>scuba_vlo, DIA11=>Data(2), 
            DIA12=>scuba_vlo, DIA13=>scuba_vlo, DIA14=>scuba_vlo, 
            DIA15=>scuba_vlo, DIA16=>scuba_vlo, DIA17=>scuba_vlo, 
            ADA0=>scuba_vlo, ADA1=>Address(0), ADA2=>Address(1), 
            ADA3=>Address(2), ADA4=>Address(3), ADA5=>Address(4), 
            ADA6=>Address(5), ADA7=>Address(6), ADA8=>Address(7), 
            ADA9=>Address(8), ADA10=>Address(9), ADA11=>Address(10), 
            ADA12=>Address(11), ADA13=>Address(12), CEA=>ClockEn, 
            CLKA=>Clock, WEA=>WE, CSA0=>scuba_vlo, CSA1=>scuba_vlo, 
            CSA2=>scuba_vlo, RSTA=>Reset, DIB0=>scuba_vlo, 
            DIB1=>scuba_vlo, DIB2=>scuba_vlo, DIB3=>scuba_vlo, 
            DIB4=>scuba_vlo, DIB5=>scuba_vlo, DIB6=>scuba_vlo, 
            DIB7=>scuba_vlo, DIB8=>scuba_vlo, DIB9=>scuba_vlo, 
            DIB10=>scuba_vlo, DIB11=>scuba_vlo, DIB12=>scuba_vlo, 
            DIB13=>scuba_vlo, DIB14=>scuba_vlo, DIB15=>scuba_vlo, 
            DIB16=>scuba_vlo, DIB17=>scuba_vlo, ADB0=>scuba_vlo, 
            ADB1=>scuba_vlo, ADB2=>scuba_vlo, ADB3=>scuba_vlo, 
            ADB4=>scuba_vlo, ADB5=>scuba_vlo, ADB6=>scuba_vlo, 
            ADB7=>scuba_vlo, ADB8=>scuba_vlo, ADB9=>scuba_vlo, 
            ADB10=>scuba_vlo, ADB11=>scuba_vlo, ADB12=>scuba_vlo, 
            ADB13=>scuba_vlo, CEB=>scuba_vhi, CLKB=>scuba_vlo, 
            WEB=>scuba_vlo, CSB0=>scuba_vlo, CSB1=>scuba_vlo, 
            CSB2=>scuba_vlo, RSTB=>scuba_vlo, DOA0=>Q(2), DOA1=>Q(3), 
            DOA2=>open, DOA3=>open, DOA4=>open, DOA5=>open, DOA6=>open, 
            DOA7=>open, DOA8=>open, DOA9=>open, DOA10=>open, DOA11=>open, 
            DOA12=>open, DOA13=>open, DOA14=>open, DOA15=>open, 
            DOA16=>open, DOA17=>open, DOB0=>open, DOB1=>open, DOB2=>open, 
            DOB3=>open, DOB4=>open, DOB5=>open, DOB6=>open, DOB7=>open, 
            DOB8=>open, DOB9=>open, DOB10=>open, DOB11=>open, 
            DOB12=>open, DOB13=>open, DOB14=>open, DOB15=>open, 
            DOB16=>open, DOB17=>open);

    lattice_ProgRam_0_2_1: DP16KB
        -- synopsys translate_off
        generic map (CSDECODE_B=> "111", CSDECODE_A=> "000", WRITEMODE_B=> "NORMAL", 
        WRITEMODE_A=> "NORMAL", GSR=> "DISABLED", RESETMODE=> "SYNC", 
        REGMODE_B=> "NOREG", REGMODE_A=> "OUTREG", DATA_WIDTH_B=>  2, 
        DATA_WIDTH_A=>  2)
        -- synopsys translate_on
        port map (DIA0=>scuba_vlo, DIA1=>Data(5), DIA2=>scuba_vlo, 
            DIA3=>scuba_vlo, DIA4=>scuba_vlo, DIA5=>scuba_vlo, 
            DIA6=>scuba_vlo, DIA7=>scuba_vlo, DIA8=>scuba_vlo, 
            DIA9=>scuba_vlo, DIA10=>scuba_vlo, DIA11=>Data(4), 
            DIA12=>scuba_vlo, DIA13=>scuba_vlo, DIA14=>scuba_vlo, 
            DIA15=>scuba_vlo, DIA16=>scuba_vlo, DIA17=>scuba_vlo, 
            ADA0=>scuba_vlo, ADA1=>Address(0), ADA2=>Address(1), 
            ADA3=>Address(2), ADA4=>Address(3), ADA5=>Address(4), 
            ADA6=>Address(5), ADA7=>Address(6), ADA8=>Address(7), 
            ADA9=>Address(8), ADA10=>Address(9), ADA11=>Address(10), 
            ADA12=>Address(11), ADA13=>Address(12), CEA=>ClockEn, 
            CLKA=>Clock, WEA=>WE, CSA0=>scuba_vlo, CSA1=>scuba_vlo, 
            CSA2=>scuba_vlo, RSTA=>Reset, DIB0=>scuba_vlo, 
            DIB1=>scuba_vlo, DIB2=>scuba_vlo, DIB3=>scuba_vlo, 
            DIB4=>scuba_vlo, DIB5=>scuba_vlo, DIB6=>scuba_vlo, 
            DIB7=>scuba_vlo, DIB8=>scuba_vlo, DIB9=>scuba_vlo, 
            DIB10=>scuba_vlo, DIB11=>scuba_vlo, DIB12=>scuba_vlo, 
            DIB13=>scuba_vlo, DIB14=>scuba_vlo, DIB15=>scuba_vlo, 
            DIB16=>scuba_vlo, DIB17=>scuba_vlo, ADB0=>scuba_vlo, 
            ADB1=>scuba_vlo, ADB2=>scuba_vlo, ADB3=>scuba_vlo, 
            ADB4=>scuba_vlo, ADB5=>scuba_vlo, ADB6=>scuba_vlo, 
            ADB7=>scuba_vlo, ADB8=>scuba_vlo, ADB9=>scuba_vlo, 
            ADB10=>scuba_vlo, ADB11=>scuba_vlo, ADB12=>scuba_vlo, 
            ADB13=>scuba_vlo, CEB=>scuba_vhi, CLKB=>scuba_vlo, 
            WEB=>scuba_vlo, CSB0=>scuba_vlo, CSB1=>scuba_vlo, 
            CSB2=>scuba_vlo, RSTB=>scuba_vlo, DOA0=>Q(4), DOA1=>Q(5), 
            DOA2=>open, DOA3=>open, DOA4=>open, DOA5=>open, DOA6=>open, 
            DOA7=>open, DOA8=>open, DOA9=>open, DOA10=>open, DOA11=>open, 
            DOA12=>open, DOA13=>open, DOA14=>open, DOA15=>open, 
            DOA16=>open, DOA17=>open, DOB0=>open, DOB1=>open, DOB2=>open, 
            DOB3=>open, DOB4=>open, DOB5=>open, DOB6=>open, DOB7=>open, 
            DOB8=>open, DOB9=>open, DOB10=>open, DOB11=>open, 
            DOB12=>open, DOB13=>open, DOB14=>open, DOB15=>open, 
            DOB16=>open, DOB17=>open);

    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    lattice_ProgRam_0_3_0: DP16KB
        -- synopsys translate_off
        generic map (CSDECODE_B=> "111", CSDECODE_A=> "000", WRITEMODE_B=> "NORMAL", 
        WRITEMODE_A=> "NORMAL", GSR=> "DISABLED", RESETMODE=> "SYNC", 
        REGMODE_B=> "NOREG", REGMODE_A=> "OUTREG", DATA_WIDTH_B=>  2, 
        DATA_WIDTH_A=>  2)
        -- synopsys translate_on
        port map (DIA0=>scuba_vlo, DIA1=>Data(7), DIA2=>scuba_vlo, 
            DIA3=>scuba_vlo, DIA4=>scuba_vlo, DIA5=>scuba_vlo, 
            DIA6=>scuba_vlo, DIA7=>scuba_vlo, DIA8=>scuba_vlo, 
            DIA9=>scuba_vlo, DIA10=>scuba_vlo, DIA11=>Data(6), 
            DIA12=>scuba_vlo, DIA13=>scuba_vlo, DIA14=>scuba_vlo, 
            DIA15=>scuba_vlo, DIA16=>scuba_vlo, DIA17=>scuba_vlo, 
            ADA0=>scuba_vlo, ADA1=>Address(0), ADA2=>Address(1), 
            ADA3=>Address(2), ADA4=>Address(3), ADA5=>Address(4), 
            ADA6=>Address(5), ADA7=>Address(6), ADA8=>Address(7), 
            ADA9=>Address(8), ADA10=>Address(9), ADA11=>Address(10), 
            ADA12=>Address(11), ADA13=>Address(12), CEA=>ClockEn, 
            CLKA=>Clock, WEA=>WE, CSA0=>scuba_vlo, CSA1=>scuba_vlo, 
            CSA2=>scuba_vlo, RSTA=>Reset, DIB0=>scuba_vlo, 
            DIB1=>scuba_vlo, DIB2=>scuba_vlo, DIB3=>scuba_vlo, 
            DIB4=>scuba_vlo, DIB5=>scuba_vlo, DIB6=>scuba_vlo, 
            DIB7=>scuba_vlo, DIB8=>scuba_vlo, DIB9=>scuba_vlo, 
            DIB10=>scuba_vlo, DIB11=>scuba_vlo, DIB12=>scuba_vlo, 
            DIB13=>scuba_vlo, DIB14=>scuba_vlo, DIB15=>scuba_vlo, 
            DIB16=>scuba_vlo, DIB17=>scuba_vlo, ADB0=>scuba_vlo, 
            ADB1=>scuba_vlo, ADB2=>scuba_vlo, ADB3=>scuba_vlo, 
            ADB4=>scuba_vlo, ADB5=>scuba_vlo, ADB6=>scuba_vlo, 
            ADB7=>scuba_vlo, ADB8=>scuba_vlo, ADB9=>scuba_vlo, 
            ADB10=>scuba_vlo, ADB11=>scuba_vlo, ADB12=>scuba_vlo, 
            ADB13=>scuba_vlo, CEB=>scuba_vhi, CLKB=>scuba_vlo, 
            WEB=>scuba_vlo, CSB0=>scuba_vlo, CSB1=>scuba_vlo, 
            CSB2=>scuba_vlo, RSTB=>scuba_vlo, DOA0=>Q(6), DOA1=>Q(7), 
            DOA2=>open, DOA3=>open, DOA4=>open, DOA5=>open, DOA6=>open, 
            DOA7=>open, DOA8=>open, DOA9=>open, DOA10=>open, DOA11=>open, 
            DOA12=>open, DOA13=>open, DOA14=>open, DOA15=>open, 
            DOA16=>open, DOA17=>open, DOB0=>open, DOB1=>open, DOB2=>open, 
            DOB3=>open, DOB4=>open, DOB5=>open, DOB6=>open, DOB7=>open, 
            DOB8=>open, DOB9=>open, DOB10=>open, DOB11=>open, 
            DOB12=>open, DOB13=>open, DOB14=>open, DOB15=>open, 
            DOB16=>open, DOB17=>open);

end Structure;

-- synopsys translate_off
library xp2;
configuration Structure_CON of lattice_ProgRam is
    for Structure
        for all:VHI use entity xp2.VHI(V); end for;
        for all:VLO use entity xp2.VLO(V); end for;
        for all:DP16KB use entity xp2.DP16KB(V); end for;
    end for;
end Structure_CON;

-- synopsys translate_on