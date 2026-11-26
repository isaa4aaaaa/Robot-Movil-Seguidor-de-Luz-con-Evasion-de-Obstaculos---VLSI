library ieee;
use ieee.std_logic_1164.all;

-- A: rueda izquierda. B: derecha.
-- Adelante provisional: IN1=1, IN2=0, como en la prueba manual.
entity movimiento is
    port (
        orden : in std_logic_vector(2 downto 0);
        permiso : in std_logic;
        duty_marcha : in std_logic_vector(7 downto 0);
        ain1, ain2, bin1, bin2 : out std_logic;
        stby : out std_logic;
        duty_a, duty_b : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of movimiento is
begin
    process(orden, permiso, duty_marcha)
    begin
        ain1 <= '0'; ain2 <= '0';
        bin1 <= '0'; bin2 <= '0';
        stby <= '0';
        duty_a <= x"00"; duty_b <= x"00";
        if permiso = '1' and duty_marcha /= x"00" then
            case orden is
                when "001" => -- Avanzar: ambas ruedas hacia delante.
                    ain1 <= '1'; bin1 <= '1';
                    duty_a <= duty_marcha; duty_b <= duty_marcha;
                    stby <= '1';
                when "010" => -- Retroceder: ambas ruedas hacia atras.
                    ain2 <= '1'; bin2 <= '1';
                    duty_a <= duty_marcha; duty_b <= duty_marcha;
                    stby <= '1';
                when "011" => -- Izquierda: A detenida, B hacia delante.
                    bin1 <= '1';
                    duty_b <= duty_marcha;
                    stby <= '1';
                when "100" => -- Derecha: B detenida, A hacia delante.
                    ain1 <= '1';
                    duty_a <= duty_marcha;
                    stby <= '1';
                when others => null; -- 000 y combinaciones no usadas: parar.
            end case;
        end if;
    end process;
end architecture;
