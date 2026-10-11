package provide OscThread 1.0

package require Thread

namespace eval OscThread {
  variable me
  
  # Hilo principal y plugins
  #
  # analysis: mediante los datos del ADC calcula
  #           el DHT y los valores: VM, Vm, Vavg,...
  array set me {
    main 0
    analysis 0
    analysisBusy 0
  }
  
  # ---------------------------------------------
  proc destroy {} {
    variable me
    
    if {$me(analysis) ne 0 && [thread::exists $me(analysis)]} {
      thread::release $me(analysis)
      set me(analysis) 0
    }
  }
  
  # ---------------------------------------------
  proc init {} {
    variable me
    
    set me(main) [thread::id]
    
    # Workers para cada plugin
    set me(analysis) [thread::create { thread::wait }]
    
    # Cargar objetos dentro de los intérpretes de los workers
    set baseDir [file dirname [info script]]
    
    [namespace current]::Init_dht $baseDir
  }
  
  # ---------------------------------------------
  proc process_adc_data {data} {
    variable me
    
    if {!$me(analysisBusy)} {
      set me(analysisBusy) 1
      thread::send -async $me(analysis) [list analysis_process $me(main) $data]
    }
  }
  
  # ---------------------------------------------
  proc set_blackman_window_low_high {low high} {
    variable me
    
    thread::send -async $me(analysis) [list set_blackman_window_low_high $low $high]
  }
  
  # ---------------------------------------------
  proc set_blackman_nuttall_window_low_high {low high} {
    variable me
    
    thread::send -async $me(analysis) [list set_blackman_nuttall_window_low_high $low $high]
  }
  
  # ---------------------------------------------
  proc set_none_window_low_high {low high} {
    variable me
    
    thread::send -async $me(analysis) [list set_none_window_low_high $low $high]
  }
  
  # ---------------------------------------------
  proc set_hamming_window_low_high {low high} {
    variable me
    
    thread::send -async $me(analysis) [list set_hamming_window_low_high $low $high]
  }
  
  # ---------------------------------------------
  proc set_hann_window_low_high {low high} {
    variable me
    
    thread::send -async $me(analysis) [list set_hann_window_low_high $low $high]
  }
  
  # ---------------------------------------------
  proc set_rectangular_window_low_high {low high} {
    variable me
    
    # NOTE  Se evalúa $::dht ANTES de de hacer el thread::send
    thread::send -async $me(analysis) [list set_rectangular_window_low_high $low $high]
  }
  
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  proc Analysis_error {msg} {
    variable me
    
    set me(analysisBusy) 0
    puts stderr "Error en análisis DHT: $msg"
  }
  
  # ---------------------------------------------
  proc Analysis_result {dhtResult measures} {
    variable me
    
    try {
       ::OSCAR::update_frequency_data $dhtResult
       ::OSCAR::update_v_measures $measures
    } finally {
       set me(analysisBusy) 0
    }
  }
  
  # ---------------------------------------------
  proc Init_dht {baseDir} {
    variable me
    
    set pluginFile [file join $baseDir DHT-1.1/DHT-1.1.tm]
    # freewrap
    #set dhtFile [file join $baseDir //zipfs:/app/tcl-arduino-hilos/DHT-1.1/DHT-1.1.tm]
    thread::send $me(analysis) [list source $pluginFile]
    
    # Crear objeto DHT dentro del worker
    thread::send $me(analysis) { set ::dht [DHT new] }
    
    # ---
    thread::send $me(analysis) {
      proc analysis_process {mainThread data} {
        try {
          lassign $data voltages adcData fs
          
          set measures [$::dht measures_process $voltages]
          set dhtResult [$::dht process $data]
          
          thread::send -async $mainThread [list ::OscThread::Analysis_result $dhtResult $measures]
        } on error {msg options} {
            thread::send -async $mainThread [list ::OscThread::Analysis_error $msg]
          }
        }
    }
    # ---
    thread::send $me(analysis) {
      proc set_blackman_window_low_high {low high} {
        $::dht set_blackman_window_low_high $low $high
      }
    }
    # ---
    thread::send $me(analysis) {
      proc set_blackman_nuttall_window_low_high {low high} {
        $::dht set_blackman_nuttall_window_low_high $low $high
      }
    }
    # ---
    thread::send $me(analysis) {
      proc set_hamming_window_low_high {low high} {
        $::dht set_hamming_window_low_high $low $high
      }
    }
    # ---
    thread::send $me(analysis) {
      proc set_hann_window_low_high {low high} {
        $::dht set_hann_window_low_high $low $high
      }
    }
    # ---
    thread::send $me(analysis) {
      proc set_none_window_low_high {low high} {
        $::dht set_none_window_low_high $low $high
      }
    }
    # ---
    thread::send $me(analysis) {
      proc set_rectangular_window_low_high {low high} {
        $::dht set_rectangular_window_low_high $low $high
      }
    }
  }
}