library verilog;
use verilog.vl_types.all;
entity mesh is
    generic(
        N_SIZE          : integer := 5
    );
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        start           : in     vl_logic_vector(17 downto 0);
        stimu           : in     vl_logic_vector(17 downto 0);
        mesh_out        : out    vl_logic_vector(17 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N_SIZE : constant is 1;
end mesh;
