library ieee;
use ieee.std_logic_1164.all;

-- KEY0 inicia con una pulsacion nueva. KEY1 detiene mientras esta pulsado.
entity botones_navegacion is
    port (
        clk : in std_logic;
        key0_n, key1_n : in std_logic;
        inicio : out std_logic := '0';
        detener : out std_logic
    );
end entity;

architecture rtl of botones_navegacion is
    signal key0_1, key0_2, key0_anterior : std_logic := '0';
    signal key1_1, key1_2 : std_logic := '0';
begin
    -- Inicialmente detener=1 hasta sincronizar KEY1 suelto.
    detener <= not key1_2;
    process(clk)
    begin
        if rising_edge(clk) then
            key0_1 <= key0_n;
            key0_2 <= key0_1;
            key1_1 <= key1_n;
            key1_2 <= key1_1;
            key0_anterior <= key0_2;
            inicio <= '0';
            if key0_anterior = '1' and key0_2 = '0' and key1_2 = '1' then
                inicio <= '1';
            end if;
        end if;
    end process;
end architecture;
