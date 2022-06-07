Port of a PC-6001 core to MiSTer FPGA

original PLL (need to review which are actually necessary):

```
pll114m.vhd = -- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE0 STRING "114.545456"
-- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE1 STRING "14.318182"

pll25m_p6.vhd = -- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE0 STRING "25.174946"

pll25m_mk2.vhd = -- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE0 STRING "25.119738"

pll16m100m.vhd = -- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE0 STRING "15.972222"
-- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE1 STRING "50.000000"
-- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE2 STRING "95.833336"
-- Retrieval info: PRIVATE: EFF_OUTPUT_FREQ_VALUE3 STRING "95.833336"
```
