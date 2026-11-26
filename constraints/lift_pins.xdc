## 125 MHz Onboard Clock
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -name sys_clk -period 8.000 [get_ports clk]

## Slide Switches: SW0 = Reset, SW1 = Door Hold
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]

## Push Buttons: BTN0..BTN3 = Floor 0..3 Requests
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports {btn[0]}]
set_property -dict { PACKAGE_PIN D20 IOSTANDARD LVCMOS33 } [get_ports {btn[1]}]
set_property -dict { PACKAGE_PIN L20 IOSTANDARD LVCMOS33 } [get_ports {btn[2]}]
set_property -dict { PACKAGE_PIN L19 IOSTANDARD LVCMOS33 } [get_ports {btn[3]}]

## Green LEDs: Current Floor Position (LD0 = Ground .. LD3 = Floor 3)
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

## RGB LED LD4: Cabin & Door Status
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports led4_r]
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports led4_g]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 } [get_ports led4_b]

## RGB LED LD5: Travel Direction & Hold Alert
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports led5_r]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports led5_b]