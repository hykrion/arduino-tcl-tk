variable COUPLING
variable PARAMETERS
variable RECORD_LENGTH
variable TIMEBASE
variable TRIG_MODE
variable TRIG_POS
variable TRIG_SLOPE
variable V_SEN

array set COUPLING {
  dc 0
  ac 1
  gnd 2
}

array set PARAMETERS {
  VSEN 0
  CPL 1
  VPOS1 2
  VPOS2 3
  RES1 4
  RES2 5
  RES3 6
  RES4 7
  TIME_BASE 8
  RES5 9
  RES6 10
  RES7 11
  TRIG_MODE 12
  TRIG_SLOPE 13
  TRIG_LEVEL1 14
  TRIG_LEVEL2 15
  TRIG_POS 16
  TRIG_SRC 17
  RES8 18
  MEASUREMENTS 19
  REC_LEN1 20
  REC_LEN2 21
  RES9 22
  RES10 23
  RES11 24
  RES12 25
  HPOS1 26
  HPOS2 27
  RES13 28
  RES14 29
}

array set REC_LEN {
  512 2
  1024 4
}

array set TIMEBASE {
  50s 7
  20s 8
  10s 9
  5s 10
  2s 11
  1s 12
  0.5s 13
  0.2s 14
  0.1s 15
  50ms 16
  20ms 17
  10ms 18
  5ms 19
  2ms 20
  1ms 21
  0.5ms 22
  0.2ms 23
  0.1ms 24
  50us 25
  20us 26
  10us 27
  5us 28
  2us 29
  1us 30
}

array set TRIG_MODE {
  auto 0
  normal 1
  single 2
}

array set TRIG_POS {  
  1/8 0
  1/4 1
  1/2 2
  3/4 3
  7/8 4
}

array set TRIG_SLOPE {
  neg 0
  pos 1
}

array set TRIG_SRC {
  int 0
  ext 2
}

array set V_SEN {
  20V 3
  10V 4
  5V 5
  2V 6
  1V 7
  0.5V 8
  0.2V 9
  0.1V 10
  50mV 11
  20mV 12
  10mV 13
  5mV 14
  2mV 15
}
