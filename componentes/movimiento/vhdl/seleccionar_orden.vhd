library ieee;
use ieee.std_logic_1164.all;

-- Prueba manual: capturar SW2..0 al pulsar KEY0, soltar para parar.
entity seleccionar_orden is
    port (
        clk : in std_logic;
        key0_n : in std_logic;
        sw : in std_logic_vector(2 downto 0);
        orden : out std_logic_vector(2 downto 0) := "000";
        permiso : out std_logic := '0';
        duty_marcha : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of seleccionar_orden is
    signal key_1, key_2 : std_logic := '0';
    signal sw_1, sw_2 : std_logic_vector(2 downto 0) := "000";
    signal armado : std_logic := '0';
begin
    duty_marcha <= x"80"; -- 128/256 = 50 %.
    process(clk)
    begin
        if rising_edge(clk) then
            key_1 <= key0_n;
            key_2 <= key_1;
            sw_1 <= sw;
            sw_2 <= sw_1;
            if key_2 = '1' then
                permiso <= '0';
                orden <= "000";
                armado <= '1';
            elsif armado = '1' then
                orden <= sw_2;
                permiso <= '1';
                armado <= '0';
            end if;
        end if;
    end process;
end architecture;
