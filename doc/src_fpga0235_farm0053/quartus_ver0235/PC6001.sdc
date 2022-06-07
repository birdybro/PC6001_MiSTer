#
create_clock -name CLK50M0 -period 20 [get_ports CLK50M0]
create_clock -name CLK50M1 -period 20 [get_ports CLK50M1]

create_generated_clock -name CLK114M -source [get_ports CLK50M0] \
  -divide_by  55 -multiply_by 126 "U_CLKGEN|U_PLL114M|altpll_component|auto_generated|pll1|clk[0]"

create_generated_clock -name CLK14M -source [get_ports CLK50M0] \
  -divide_by 220 -multiply_by  63 "U_CLKGEN|U_PLL114M|altpll_component|auto_generated|pll1|clk[1]"

create_generated_clock -name CLK16M -source [get_ports CLK50M1] \
  -divide_by  72 -multiply_by  23 "U_CLKGEN|U_PLL16M100M|altpll_component|auto_generated|pll1|clk[0]"

create_generated_clock -name CLK50M -source [get_ports CLK50M1] \
                                  "U_CLKGEN|U_PLL16M100M|altpll_component|auto_generated|pll1|clk[1]"

create_generated_clock -name CLK100M -source [get_ports CLK50M1] \
  -divide_by  12 -multiply_by  23 "U_CLKGEN|U_PLL16M100M|altpll_component|auto_generated|pll1|clk[2]"

create_generated_clock -name CLK100M_DI -source [get_ports CLK50M1] \
  -divide_by  12 -multiply_by  23 "U_CLKGEN|U_PLL16M100M|altpll_component|auto_generated|pll1|clk[3]" -phase 270
create_generated_clock -name CLK25M \
  -source "U_CLKGEN|U_PLL114M|altpll_component|auto_generated|pll1|clk[0]" \
  -divide_by  91 -multiply_by  20 "U_CLKGEN|U_PLL25M_P6|altpll_component|auto_generated|pll1|clk[0]"

create_generated_clock -name CLK25M2 \
  -source "U_CLKGEN|U_PLL114M|altpll_component|auto_generated|pll1|clk[0]" \
  -divide_by 114 -multiply_by  25 "U_CLKGEN|U_PLL25M_MK2|altpll_component|auto_generated|pll1|clk[0]"

create_generated_clock -name CLK4M -source "U_CLKGEN|U_PLL16M100M|altpll_component|auto_generated|pll1|clk[0]" \
  -divide_by   4                 "U_CLKGEN|clk4mcnt[1]"


create_generated_clock -name SDRAM_CLK \
-source "U_CLKGEN|U_PLL16M100M|altpll_component|auto_generated|pll1|clk[2]" [get_ports DRAM_CLK]

set_clock_uncertainty -from CLK50M0 -to CLK50M0 0.2
set_clock_uncertainty -from CLK50M1 -to CLK50M1 0.2
set_clock_uncertainty -from CLK14M  -to CLK14M  0.2
set_clock_uncertainty -from CLK114M -to CLK114M 0.2
set_clock_uncertainty -from CLK16M  -to CLK16M  0.2
set_clock_uncertainty -from CLK100M -to CLK100M 0.2
set_clock_uncertainty -from CLK50M  -to CLK50M  0.2
set_clock_uncertainty -from CLK25M  -to CLK25M  0.2
set_clock_uncertainty -from CLK25M2 -to CLK25M2 0.2
set_clock_uncertainty -from CLK4M   -to CLK4M   0.2
set_clock_uncertainty -from CLK16M  -to CLK4M   0.2
set_clock_uncertainty -from CLK4M   -to CLK16M  0.2
set_clock_uncertainty -from CLK100M_DI -to CLK100M_DI 0.2

set_clock_uncertainty -from CLK100M    -to SDRAM_CLK  0.2
set_clock_uncertainty -from SDRAM_CLK  -to CLK100M    0.2
set_clock_uncertainty -from SDRAM_CLK  -to CLK100M_DI 0.2

#
set_false_path -from [get_clocks CLK14M]  -to [get_clocks CLK16M]
set_false_path -from [get_clocks CLK14M]  -to [get_clocks CLK100M]
set_false_path -from [get_clocks CLK14M]  -to [get_clocks CLK100M_DI]
set_false_path -from [get_clocks CLK14M]  -to [get_clocks CLK50M]
set_false_path -from [get_clocks CLK14M]  -to [get_clocks CLK25M]
set_false_path -from [get_clocks CLK14M]  -to [get_clocks CLK25M2]
set_false_path -from [get_clocks CLK14M]  -to [get_clocks CLK4M]

set_false_path -from [get_clocks CLK16M]  -to [get_clocks CLK14M]
set_false_path -from [get_clocks CLK16M]  -to [get_clocks CLK100M]
set_false_path -from [get_clocks CLK16M]  -to [get_clocks CLK100M_DI]
set_false_path -from [get_clocks CLK16M]  -to [get_clocks CLK50M]
set_false_path -from [get_clocks CLK16M]  -to [get_clocks CLK25M]
set_false_path -from [get_clocks CLK16M]  -to [get_clocks CLK25M2]
#set_false_path -from [get_clocks CLK16M]  -to [get_clocks CLK4M]

set_false_path -from [get_clocks CLK100M] -to [get_clocks CLK14M]
set_false_path -from [get_clocks CLK100M] -to [get_clocks CLK16M]
set_false_path -from [get_clocks CLK100M] -to [get_clocks CLK100M_DI]
set_false_path -from [get_clocks CLK100M] -to [get_clocks CLK50M]
set_false_path -from [get_clocks CLK100M] -to [get_clocks CLK25M]
set_false_path -from [get_clocks CLK100M] -to [get_clocks CLK25M2]
set_false_path -from [get_clocks CLK100M] -to [get_clocks CLK4M]

set_false_path -from [get_clocks CLK50M]  -to [get_clocks CLK14M]
set_false_path -from [get_clocks CLK50M]  -to [get_clocks CLK16M]
set_false_path -from [get_clocks CLK50M]  -to [get_clocks CLK100M]
set_false_path -from [get_clocks CLK50M]  -to [get_clocks CLK100M_DI]
set_false_path -from [get_clocks CLK50M]  -to [get_clocks CLK25M]
set_false_path -from [get_clocks CLK50M]  -to [get_clocks CLK25M2]
set_false_path -from [get_clocks CLK50M]  -to [get_clocks CLK4M]

set_false_path -from [get_clocks CLK25M]  -to [get_clocks CLK14M]
set_false_path -from [get_clocks CLK25M]  -to [get_clocks CLK16M]
set_false_path -from [get_clocks CLK25M]  -to [get_clocks CLK100M]
set_false_path -from [get_clocks CLK25M]  -to [get_clocks CLK100M_DI]
set_false_path -from [get_clocks CLK25M]  -to [get_clocks CLK25M2]
set_false_path -from [get_clocks CLK25M]  -to [get_clocks CLK50M]
set_false_path -from [get_clocks CLK25M]  -to [get_clocks CLK4M]

set_false_path -from [get_clocks CLK25M2]  -to [get_clocks CLK14M]
set_false_path -from [get_clocks CLK25M2]  -to [get_clocks CLK16M]
set_false_path -from [get_clocks CLK25M2]  -to [get_clocks CLK100M]
set_false_path -from [get_clocks CLK25M2]  -to [get_clocks CLK100M_DI]
set_false_path -from [get_clocks CLK25M2]  -to [get_clocks CLK25M]
set_false_path -from [get_clocks CLK25M2]  -to [get_clocks CLK50M]
set_false_path -from [get_clocks CLK25M2]  -to [get_clocks CLK4M]

set_false_path -from [get_clocks CLK4M]   -to [get_clocks CLK14M]
#set_false_path -from [get_clocks CLK4M]   -to [get_clocks CLK16M]
set_false_path -from [get_clocks CLK4M]   -to [get_clocks CLK100M]
set_false_path -from [get_clocks CLK4M]   -to [get_clocks CLK100M_DI]
set_false_path -from [get_clocks CLK4M]   -to [get_clocks CLK50M]
set_false_path -from [get_clocks CLK4M]   -to [get_clocks CLK25M]
set_false_path -from [get_clocks CLK4M]   -to [get_clocks CLK25M2]

set_false_path -from [get_clocks CLK100M_DI]  -to [get_clocks CLK14M]
set_false_path -from [get_clocks CLK100M_DI]  -to [get_clocks CLK16M]
set_false_path -from [get_clocks CLK100M_DI]  -to [get_clocks CLK100M]
set_false_path -from [get_clocks CLK100M_DI]  -to [get_clocks CLK50M]
set_false_path -from [get_clocks CLK100M_DI]  -to [get_clocks CLK25M]
set_false_path -from [get_clocks CLK100M_DI]  -to [get_clocks CLK25M2]
set_false_path -from [get_clocks CLK100M_DI]  -to [get_clocks CLK4M]

#set_multicycle_path -end -setup -from SDRAM_CLK -to CLK100M_DI 2
#set_multicycle_path -end -hold  -from SDRAM_CLK -to CLK100M_DI 0

#
#set_output_delay -clock CLK14M -max 5 [all_outputs]
#set_output_delay -clock CLK16M -max 5 [all_outputs]
set_output_delay -clock CLK25M -max 5 [get_ports VGA_R*]
set_output_delay -clock CLK25M -max 5 [get_ports VGA_G*]
set_output_delay -clock CLK25M -max 5 [get_ports VGA_B*]
set_output_delay -clock CLK25M -max 5 [get_ports VGA_HS]
set_output_delay -clock CLK25M -max 5 [get_ports VGA_VS]
set_output_delay -clock CLK25M -min 0 [get_ports VGA_R*]
set_output_delay -clock CLK25M -min 0 [get_ports VGA_G*]
set_output_delay -clock CLK25M -min 0 [get_ports VGA_B*]
set_output_delay -clock CLK25M -min 0 [get_ports VGA_HS]
set_output_delay -clock CLK25M -min 0 [get_ports VGA_VS]

set_output_delay -clock CLK25M2 -max 5 [get_ports VGA_R*] -add_delay
set_output_delay -clock CLK25M2 -max 5 [get_ports VGA_G*] -add_delay
set_output_delay -clock CLK25M2 -max 5 [get_ports VGA_B*] -add_delay
set_output_delay -clock CLK25M2 -max 5 [get_ports VGA_HS] -add_delay
set_output_delay -clock CLK25M2 -max 5 [get_ports VGA_VS] -add_delay
set_output_delay -clock CLK25M2 -min 0 [get_ports VGA_R*] -add_delay
set_output_delay -clock CLK25M2 -min 0 [get_ports VGA_G*] -add_delay
set_output_delay -clock CLK25M2 -min 0 [get_ports VGA_B*] -add_delay
set_output_delay -clock CLK25M2 -min 0 [get_ports VGA_HS] -add_delay
set_output_delay -clock CLK25M2 -min 0 [get_ports VGA_VS] -add_delay

set_output_delay -clock SDRAM_CLK -max 1.0 [get_ports DRAM_A*]
set_output_delay -clock SDRAM_CLK -max 1.0 [get_ports DRAM_D*]
set_output_delay -clock SDRAM_CLK -max 1.0 [get_ports DRAM_CS_N]
set_output_delay -clock SDRAM_CLK -max 1.0 [get_ports DRAM_RAS_N]
set_output_delay -clock SDRAM_CLK -max 1.0 [get_ports DRAM_CAS_N]
set_output_delay -clock SDRAM_CLK -max 1.0 [get_ports DRAM_WE_N]
set_output_delay -clock SDRAM_CLK -max 1.0 [get_ports DRAM_CKE]

set_output_delay -clock SDRAM_CLK -min 0.0 [get_ports DRAM_A*]
set_output_delay -clock SDRAM_CLK -min 0.0 [get_ports DRAM_D*]
set_output_delay -clock SDRAM_CLK -min 0.0 [get_ports DRAM_CS_N]
set_output_delay -clock SDRAM_CLK -min 0.0 [get_ports DRAM_RAS_N]
set_output_delay -clock SDRAM_CLK -min 0.0 [get_ports DRAM_CAS_N]
set_output_delay -clock SDRAM_CLK -min 0.0 [get_ports DRAM_WE_N]
set_output_delay -clock SDRAM_CLK -min 0.0 [get_ports DRAM_CKE]


# wire delay(0.25ns) + SDRAM output delay(6ns) + wire delay(0.25ns)
set_input_delay -clock SDRAM_CLK -max 4.5 [get_ports DRAM_D*]

# wire delay(0ns) + SDRAM data hold(2.5ns) + wire delay(0 ns)
set_input_delay -clock SDRAM_CLK -min 0.5 [get_ports DRAM_D*]


