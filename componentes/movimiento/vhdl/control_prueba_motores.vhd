library ieee;
use ieee.std_logic_1164.all;

-- Prueba manual; no es aun el control de navegacion.
-- KEY0 activo en bajo. Soltar, elegir switches, pulsar para mover.
entity control_prueba_motores is
    port (
        clk : in std_logic;
        key0_n : in std_logic;
        sw : in std_logic_vector(2 downto 0);
        ain1, ain2, bin1, bin2 : out std_logic;
        stby : out std_logic;
        duty_a, duty_b : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of control_prueba_motores is
    -- Inicializar a pulsado obliga a observar KEY0 suelto antes de arrancar.
    signal key_1, key_2 : std_logic := '0';
    signal sw_1, sw_2 : std_logic_vector(2 downto 0) := "000";
    signal armado, activo : std_logic := '0';
    signal seleccion : std_logic_vector(2 downto 0) := "000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            key_1 <= key0_n;
            key_2 <= key_1;
            sw_1 <= sw;
            sw_2 <= sw_1;
            if key_2 = '1' then
                activo <= '0';
                armado <= '1';
            elsif armado = '1' then
                seleccion <= sw_2;
                activo <= '1';
                armado <= '0';
            end if;
        end if;
    end process;

    -- Los switches se capturan al pulsar; no invierten un motor en marcha.
    stby <= activo and (seleccion(0) or seleccion(1));
    ain1 <= activo and seleccion(0) and not seleccion(2);
    ain2 <= activo and seleccion(0) and seleccion(2);
    bin1 <= activo and seleccion(1) and not seleccion(2);
    bin2 <= activo and seleccion(1) and seleccion(2);
    duty_a <= x"80" when activo = '1' and seleccion(0) = '1' else x"00";
    duty_b <= x"80" when activo = '1' and seleccion(1) = '1' else x"00";
end architecture;
