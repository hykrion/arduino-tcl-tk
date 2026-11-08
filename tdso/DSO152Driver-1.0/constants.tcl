variable TIMEBASE
variable ADC_CLK_DIV

# ch32v00x_adc.h
#
# ADC_SampleTime_3Cycles    0
# ADC_SampleTime_9Cycles    1
# ADC_SampleTime_15Cycles   2
# ADC_SampleTime_30Cycles   3
# ADC_SampleTime_43Cycles   4
# ADC_SampleTime_57Cycles   5
# ADC_SampleTime_73Cycles   6
# ADC_SampleTime_241Cycles  7

array set TIMEBASE {
  42us     2
  60us   1
  80us     1
  123us    6
  164us    3
  340us    1
  1ms   4
  0.5ms   7
}

# ch32v00x_rcc.h
#
# RCC_PCLK2_Div2    0
# RCC_PCLK2_Div4    16384
# RCC_PCLK2_Div6    32768
# RCC_PCLK2_Div8    49152
# RCC_PCLK2_Div12   40960
# RCC_PCLK2_Div16   57344
# RCC_PCLK2_Div24   43008
# RCC_PCLK2_Div32   59392
# RCC_PCLK2_Div48   45056
# RCC_PCLK2_Div64   61440
# RCC_PCLK2_Div96   47104
# RCC_PCLK2_Div128  63488

array set ADC_CLK_DIV {
  42us     0
  60us   32768
  80us     40960
  123us    32768
  164us    43008
  340us    47104
  1ms   47104
  0.5ms   47104
}
