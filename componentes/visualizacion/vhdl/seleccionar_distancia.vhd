library ieee;
use ieee.std_logic_1164.all;

-- SW1/SW0 eligen solo lo mostrado; no alteran los turnos de medida.
entity seleccionar_distancia is
    port (
        clk : in std_logic;
        selector : in std_logic_vector(1 downto 0);
        frente_cm, derecha_cm, atras_cm, izquierda_cm : in std_logic_vector(8 downto 0);
        validos : in std_logic_vector(3 downto 0);
        distancia_cm : out std_logic_vector(8 downto 0);
        valido : out std_logic
    );
end entity;

architecture rtl of seleccionar_distancia is
    signal selector_1, selector_2 : std_logic_vector(1 downto 0) := "00";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            selector_1 <= selector;
            selector_2 <= selector_1;
        end if;
    end process;

    process(selector_2, frente_cm, derecha_cm, atras_cm, izquierda_cm, validos)
    begin
        distancia_cm <= (others => '0');
        valido <= '0';
        case selector_2 is
            when "00" => distancia_cm <= frente_cm; valido <= validos(0);
            when "01" => distancia_cm <= derecha_cm; valido <= validos(1);
            when "10" => distancia_cm <= atras_cm; valido <= validos(2);
            when "11" => distancia_cm <= izquierda_cm; valido <= validos(3);
            when others => null;
        end case;
    end process;
end architecture;
