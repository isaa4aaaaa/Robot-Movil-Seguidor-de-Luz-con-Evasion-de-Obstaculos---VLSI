library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 50 MHz / (8 * 256) = 24 414.0625 Hz. Un solo reloj.
-- Duty 0..255 representa 0..255/256; 128 es exactamente 50 %.
entity pwm_doble_8bits is
    port (
        clk : in std_logic;
        habilitar : in std_logic;
        duty_a, duty_b : in std_logic_vector(7 downto 0);
        pwm_a, pwm_b : out std_logic := '0'
    );
end entity;

architecture rtl of pwm_doble_8bits is
    signal cuenta : unsigned(10 downto 0) := (others => '0');
    signal valor_a, valor_b : unsigned(7 downto 0) := (others => '0');
begin
    process(clk)
        variable a, b : unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            a := valor_a;
            b := valor_b;
            -- Cambiar duty solo al iniciar el periodo evita pulsos recortados.
            if cuenta = 0 then
                a := unsigned(duty_a);
                b := unsigned(duty_b);
                valor_a <= a;
                valor_b <= b;
            end if;
            cuenta <= cuenta + 1;
            pwm_a <= '0';
            pwm_b <= '0';
            if habilitar = '1' then
                if cuenta(10 downto 3) < a then pwm_a <= '1'; end if;
                if cuenta(10 downto 3) < b then pwm_b <= '1'; end if;
            end if;
        end if;
    end process;
end architecture;
