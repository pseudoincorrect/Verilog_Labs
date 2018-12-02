library verilog;
use verilog.vl_types.all;
entity sound_node is
    generic(
        Eta             : vl_logic_vector(0 to 17) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi1);
        Rho             : vl_logic_vector(0 to 17) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi0, Hi1, Hi1, Hi0, Hi0, Hi1, Hi1, Hi0, Hi1);
        Eta_frac        : vl_logic_vector(0 to 17) := (Hi0, Hi0, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi1, Hi1);
        STATE_IDLE      : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        STATE_PROC_1    : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        STATE_PROC_2    : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        STATE_PROC_3    : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        STATE_PROC_4    : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        STATE_PROC_5    : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        STATE_PROC_6    : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        STATE_PROC_7    : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        start           : in     vl_logic_vector(17 downto 0);
        stimu           : in     vl_logic_vector(17 downto 0);
        u_in_left       : in     vl_logic_vector(17 downto 0);
        u_in_right      : in     vl_logic_vector(17 downto 0);
        u_in_bottom     : in     vl_logic_vector(17 downto 0);
        u_in_top        : in     vl_logic_vector(17 downto 0);
        u_out           : out    vl_logic_vector(17 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Eta : constant is 1;
    attribute mti_svvh_generic_type of Rho : constant is 1;
    attribute mti_svvh_generic_type of Eta_frac : constant is 1;
    attribute mti_svvh_generic_type of STATE_IDLE : constant is 1;
    attribute mti_svvh_generic_type of STATE_PROC_1 : constant is 1;
    attribute mti_svvh_generic_type of STATE_PROC_2 : constant is 1;
    attribute mti_svvh_generic_type of STATE_PROC_3 : constant is 1;
    attribute mti_svvh_generic_type of STATE_PROC_4 : constant is 1;
    attribute mti_svvh_generic_type of STATE_PROC_5 : constant is 1;
    attribute mti_svvh_generic_type of STATE_PROC_6 : constant is 1;
    attribute mti_svvh_generic_type of STATE_PROC_7 : constant is 1;
end sound_node;
