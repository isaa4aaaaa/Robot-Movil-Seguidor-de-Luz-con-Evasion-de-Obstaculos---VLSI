library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Un lector compartido. Orden: frente, derecha, atras, izquierda.
entity cuatro_hcsr04 is
    generic (
        RELOJ_HZ : positive := 50000000;
        CICLOS_TURNO : positive := 5000000
    );
    port (
        clk : in std_logic;
        echo : in std_logic_vector(3 downto 0);
        trig : out std_logic_vector(3 downto 0);
        frente_cm, derecha_cm, atras_cm, izquierda_cm : out std_logic_vector(8 downto 0);
        validos, nuevos : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity;

architecture rtl of cuatro_hcsr04 is
    type distancias_t is array (0 to 3) of std_logic_vector(8 downto 0);
    signal distancias : distancias_t := (others => (others => '0'));
    signal turno : natural range 0 to 3 := 0;
    signal tiempo : natural range 0 to CICLOS_TURNO - 1 := 0;
    signal en_curso : std_logic := '0';
    signal inicio, pulso, ocupado, listo, valido : std_logic := '0';
    signal echo_elegido : std_logic;
    signal cm : std_logic_vector(8 downto 0);
begin
    -- Deja margen para el plazo de 30 ms y para sincronizar el siguiente ECHO.
    assert CICLOS_TURNO >= RELOJ_HZ / 10
        report "Usar turnos de al menos 100 ms en esta prueba" severity failure;

    echo_elegido <= echo(turno);
    frente_cm <= distancias(0);
    derecha_cm <= distancias(1);
    atras_cm <= distancias(2);
    izquierda_cm <= distancias(3);

    process(turno, pulso)
    begin
        trig <= (others => '0');
        trig(turno) <= pulso;
    end process;

    lector : entity work.medir_hcsr04
        generic map (RELOJ_HZ => RELOJ_HZ)
        port map (clk => clk, inicio => inicio, echo => echo_elegido,
                  trig => pulso, ocupado => ocupado, listo => listo,
                  valido => valido, distancia_cm => cm);

    process(clk)
    begin
        if rising_edge(clk) then
            inicio <= '0';
            nuevos <= (others => '0');
            if tiempo = CICLOS_TURNO - 1 then
                tiempo <= 0;
                -- en_curso cubre tambien el ciclo entre solicitud y ocupado.
                if en_curso = '0' and ocupado = '0' then
                    inicio <= '1';
                    en_curso <= '1';
                end if;
            else
                tiempo <= tiempo + 1;
            end if;

            if listo = '1' and en_curso = '1' then
                distancias(turno) <= cm;
                validos(turno) <= valido;
                nuevos(turno) <= '1';
                en_curso <= '0';
                if turno = 3 then
                    turno <= 0;
                else
                    turno <= turno + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
