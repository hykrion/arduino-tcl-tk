# Advance the driver's asynchronous command queue deterministically in tests
# that assert command values. The transport timing test uses real timers.
proc drain_dso152_commands {} {
    while {$::DSO152Driver::commandTimer ne ""} {
        after cancel $::DSO152Driver::commandTimer
        ::DSO152Driver::Send_next_command
    }
}
