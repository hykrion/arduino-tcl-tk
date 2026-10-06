package provide OscThread 1.0

package require Thread

namespace eval OscThread {
  variable me
  variable resultCallback {}
  
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
  proc init {sampleSize {dhtSize ""}} {
    variable me
    
    set me(main) [thread::id]
    
    # Workers para cada plugin
    set me(analysis) [thread::create { thread::wait }]
    
    # Cargar objetos dentro de los intérpretes de los workers
    set baseDir [file dirname [info script]]
    
    [namespace current]::Init_dht $baseDir $sampleSize $dhtSize
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
  proc set_result_callback {callback} {
    variable resultCallback
    
    set resultCallback $callback
  }

  # ---------------------------------------------
  proc set_window {type low high} {
    variable me

    thread::send -async $me(analysis) [list set_window $type $low $high]
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
      [namespace current]::Send_result $dhtResult $measures
    } finally {
       set me(analysisBusy) 0
    }
  }
  
  # ---------------------------------------------
  proc Init_dht {baseDir dhtSampleSize {dhtSize ""}} {
    variable me
    
    set pluginFile [file join $baseDir DHT-1.1/DHT-1.1.tm]
    # freewrap
    #set pluginFile [file join $baseDir //zipfs:/app/exe/DHT-1.1/DHT-1.1.tm]
    thread::send $me(analysis) [list source $pluginFile]
    
    # Crear objeto DHT dentro del worker
    set dhtObj [thread::send $me(analysis) [list DHT new $dhtSampleSize $dhtSize]]
    thread::send $me(analysis) [list set ::dht $dhtObj]
    
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
      proc set_window {type low high} {
        $::dht set_window $type $low $high
      }
    }
  }
  
  # ---------------------------------------------
  proc Send_result {dhtResult measures} {
    variable resultCallback

    if {$resultCallback ne ""} {
      {*}$resultCallback $dhtResult $measures
    }
  }
}
