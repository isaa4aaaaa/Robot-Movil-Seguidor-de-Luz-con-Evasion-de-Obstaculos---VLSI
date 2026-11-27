library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Primera integracion: no incluye Escape, Meta ni detector de atasco.
entity navegacion_basica is
    generic (RELOJ_HZ : positive := 50000000);
    port (
        clk, inicio, detener : in std_logic;
        luz : in std_logic_vector(3 downto 0); -- frente, derecha, atras, izquierda
        frente_cm, derecha_cm, izquierda_cm : in std_logic_vector(8 downto 0);
        validos, nuevos : in std_logic_vector(3 downto 0);
        orden : out std_logic_vector(2 downto 0);
        permiso : out std_logic;
        duty_marcha : out std_logic_vector(7 downto 0);
        leds : out std_logic_vector(5 downto 0)
    );
end entity;

architecture rtl of navegacion_basica is
    constant LIMITE_CM : natural := 10;
    constant PAUSA : positive := RELOJ_HZ / 5;       -- 200 ms
    constant GIRO_MIN : positive := RELOJ_HZ * 2 / 5; -- 400 ms
    constant GIRO_MAX : positive := RELOJ_HZ * 2;    -- 2 s
    constant CADUCIDAD : positive := RELOJ_HZ * 4 / 5; -- 800 ms
    type estado_t is (espera, buscar, seguir, evadir, girar);
    signal estado : estado_t := espera;
    signal tiempo : natural range 0 to GIRO_MAX := 0;
    type edades_t is array (0 to 3) of natural range 0 to CADUCIDAD;
    signal edad : edades_t := (others => CADUCIDAD);
    signal datos_ok, frente_libre, derecha_libre, izquierda_libre : std_logic;
    signal giro_izquierda : std_logic := '0';
    signal lado_libre : std_logic;

    -- Elegir lado: una luz lateral unica tiene prioridad si ese lado esta libre.
    -- En Evadir no se usa luz; se elige el mayor espacio, derecha en empate.
    function elegir_izquierda(l : std_logic_vector(3 downto 0);
        d,i : std_logic_vector(8 downto 0); usar_luz : boolean) return std_logic is
    begin
        if unsigned(i) <= LIMITE_CM then return '0'; end if;
        if unsigned(d) <= LIMITE_CM then return '1'; end if;
        if usar_luz then
            if l(3)='1' and l(1)='0' then return '1'; end if;
            if l(1)='1' and l(3)='0' then return '0'; end if;
        end if;
        if unsigned(i) > unsigned(d) then return '1'; end if;
        return '0';
    end function;
begin
    duty_marcha <= x"80";
    frente_libre <= '1' when unsigned(frente_cm) > LIMITE_CM else '0';
    derecha_libre <= '1' when unsigned(derecha_cm) > LIMITE_CM else '0';
    izquierda_libre <= '1' when unsigned(izquierda_cm) > LIMITE_CM else '0';
    lado_libre <= izquierda_libre when giro_izquierda='1' else derecha_libre;
    datos_ok <= '1' when validos="1111" and
        edad(0)<CADUCIDAD and edad(1)<CADUCIDAD and
        edad(2)<CADUCIDAD and edad(3)<CADUCIDAD else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            for k in 0 to 3 loop
                if nuevos(k)='1' then edad(k)<=0;
                elsif edad(k)<CADUCIDAD then edad(k)<=edad(k)+1;
                end if;
            end loop;
            if detener='1' or datos_ok='0' then
                estado<=espera;
                tiempo<=0;
            else
                case estado is
                    when espera =>
                        tiempo<=0;
                        if inicio='1' then
                            giro_izquierda<=elegir_izquierda(luz,derecha_cm,izquierda_cm,true);
                            estado<=buscar;
                        end if;
                    when buscar =>
                        tiempo<=0;
                        if frente_libre='0' then
                            estado<=evadir;
                        elsif luz(0)='1' then
                            estado<=seguir;
                        elsif derecha_libre='0' and izquierda_libre='0' then
                            estado<=espera;
                        else
                            giro_izquierda<=elegir_izquierda(luz,derecha_cm,izquierda_cm,true);
                        end if;
                    when seguir =>
                        tiempo<=0;
                        if frente_libre='0' then
                            estado<=evadir;
                        elsif luz(0)='0' then
                            giro_izquierda<=elegir_izquierda(luz,derecha_cm,izquierda_cm,true);
                            estado<=buscar;
                        end if;
                    when evadir =>
                        if tiempo=PAUSA-1 then
                            tiempo<=0;
                            if derecha_libre='0' and izquierda_libre='0' then
                                estado<=espera;
                            else
                                giro_izquierda<=elegir_izquierda(luz,derecha_cm,izquierda_cm,false);
                                estado<=girar;
                            end if;
                        else tiempo<=tiempo+1;
                        end if;
                    when girar =>
                        if lado_libre='0' then
                            estado<=espera; tiempo<=0;
                        elsif tiempo>=GIRO_MIN-1 and nuevos(0)='1' and frente_libre='1' then
                            estado<=buscar; tiempo<=0;
                        elsif tiempo=GIRO_MAX-1 then
                            estado<=espera; tiempo<=0;
                        else tiempo<=tiempo+1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    process(estado, detener, datos_ok, frente_libre, luz, giro_izquierda, lado_libre)
    begin
        orden<="000"; permiso<='0'; leds<=(others=>'0');
        leds(5)<=not datos_ok;
        case estado is
            when espera => leds(0)<='1';
            when buscar => leds(1)<='1';
            when seguir => leds(2)<='1';
            when evadir => leds(3)<='1';
            when girar => leds(4)<='1';
        end case;
        if detener='0' and datos_ok='1' then
            case estado is
                when seguir =>
                    if frente_libre='1' and luz(0)='1' then
                        orden<="001"; permiso<='1';
                    end if;
                when buscar | girar =>
                    if lado_libre='1' and
                        (estado=girar or (frente_libre='1' and luz(0)='0')) then
                        permiso<='1';
                        if giro_izquierda='1' then orden<="011";
                        else orden<="100";
                        end if;
                    end if;
                when others => null;
            end case;
        end if;
    end process;
end architecture;
