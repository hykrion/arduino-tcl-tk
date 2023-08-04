# TODO
# -hacer que compruebe si tenemos datos sobre el nombre de la frecuencia que vamos mirando

package require Tk
package require inifile
package require tea5767_driver
 
package provide tea5767_gui 1.0

namespace eval tea5767_gui {
  variable radio
  variable ui
  
  array set radio {
    serialPortName PUERTO_SERIE
    serialPortSpeed 9600
    mute 0
    stereo 0
    volume 10
    dial 87.5
    dialLowFrequency  87.5
    dialHighFrequency 108
    dialStep  0.1
    hiloAlgorithm 1
    stationName ""
    stationsList {}
    stationsDict {}
    configFile  config.ini
  }
  
  array set ui {
    mute ""
    stereo ""
  }
  
  # ---------------------------------------------
  proc init {} {
    variable radio
    variable ui
    
    wm title . "TCL/TK - RADIO FM"
    wm iconname . "Radio"
    wm protocol . WM_DELETE_WINDOW [namespace current]::quit

    set ui(mainWindow) [ttk::notebook .ntb]
    
    init_images
    load_config
    init_tab_radio
    init_tab_config
    
    grid $ui(mainWindow)

    init_driver
    # Necesita un tiempo para responder
    after 3000
    scale_dial_changed $radio(dial) 0
    load_buttons_state
  }
  # ---------------------------------------------
  proc quit {} {
    tea5767_driver::quit
    save_config
    exit
  }
  # ---------------------------------------------
  proc init_driver {} {
    variable radio

    tea5767_driver::init $radio(serialPortName) $radio(serialPortSpeed)
  }
  # ---------------------------------------------
  proc init_images {} {
    image create photo imgMuteOff -file [file nativename tea5767_gui-1.0/img/mute-off.png]
    image create photo imgMuteOn -file [file nativename tea5767_gui-1.0/img/mute-on.png]
    image create photo imgStereoOn -file [file nativename tea5767_gui-1.0/img/stereo-on.png]
    image create photo imgStereoOff -file [file nativename tea5767_gui-1.0/img/stereo-off.png]
    image create photo imgDialUp -file [file nativename tea5767_gui-1.0/img/dial-up.png]
    image create photo imgDialDown -file [file nativename tea5767_gui-1.0/img/dial-down.png]
    image create photo imgAddStationStart -file [file nativename tea5767_gui-1.0/img/add-station-star.png]
    image create photo imgAddStation -file [file nativename tea5767_gui-1.0/img/add.png]
    image create photo imgRemoveStation -file [file nativename tea5767_gui-1.0/img/remove.png]
    image create photo imgLev0 -file [file nativename tea5767_gui-1.0/img/signal-strength-0.png]
    image create photo imgLev1 -file [file nativename tea5767_gui-1.0/img/signal-strength-1.png]
    image create photo imgLev2 -file [file nativename tea5767_gui-1.0/img/signal-strength-2.png]
    image create photo imgLev3 -file [file nativename tea5767_gui-1.0/img/signal-strength-3.png]
    image create photo imgLev4 -file [file nativename tea5767_gui-1.0/img/signal-strength-4.png]
  }
  # ---------------------------------------------
  proc init_tab_radio {} {
    variable ui
    variable radio
    
    set tab [ttk::frame $ui(mainWindow).tabRadio]
    set firstRow [ttk::frame $tab.frm1Row -padding {280 0 0 0}]
    set secondRow [ttk::frame $tab.frm2Row]
    set dialUpDown [ttk::frame $tab.frmDialButtons]
    set step [ttk::labelframe $tab.lblFrmStep -text Paso]
    set volume [ttk::frame $tab.frmVolume]

    # --------
    # firstRow
    # --------
    # NOTE  Parece que ttk::checkbutton no tiene la opción '-indicartoron'
    set w1 [ttk::button $firstRow.btnAddStation -image imgAddStationStart -command [namespace code {add_station}]]
    set w2 [checkbutton $firstRow.btnStereo -variable [namespace current]::radio(stereo) -image imgStereoOff -indicatoron 0]
    set w3 [checkbutton $firstRow.btnMute -variable [namespace current]::radio(mute) -image imgMuteOff -indicatoron 0]
    set w4 [button $firstRow.btnLevel -image imgLev0]
    set w5 [ttk::scale $firstRow.sclVolume -orient vertical -length 50 -from 100 -to 0 -variable [namespace current]::radio(volume) -command [namespace code {volume_changed}]]
    grid $w1 $w2 $w3 $w4 $w5
    
    set ui(stereo) $w2
    set ui(mute) $w3
    set ui(signalLevel) $w4

    # ---------
    # secondRow
    # ---------
    font create dialFont -family Helvetica -size 30 -weight bold
     
    set w [ttk::label $secondRow.lblStationName -textvariable [namespace current]::radio(stationName)]
    grid $w
    set w [ttk::label $secondRow.lblDial -textvariable [namespace current]::radio(dial) -font dialFont]
    grid $w $dialUpDown $step
    set w [ttk::scale $secondRow.sclDial -orient horizontal -length 300 -from $radio(dialLowFrequency)  -to $radio(dialHighFrequency) -command [namespace code {scale_dial_changed}] -variable [namespace current]::radio(dial)]
    grid $w
   
    set w [ttk::button $dialUpDown.btnDialUp -image imgDialUp -command [namespace code {scale_dial up}]]
    grid $w
    set w [ttk::button $dialUpDown.btnDialDown -image imgDialDown -command [namespace code {scale_dial down}]]
    grid $w
    
    set w [ttk::radiobutton $step.chk0 -text 0.1 -variable [namespace current]::radio(dialStep) -value 0.1]
    grid $w
    set w [ttk::radiobutton $step.chk1 -text 0.5 -variable [namespace current]::radio(dialStep) -value 0.5]
    grid $w

    grid $firstRow
    grid $secondRow
    
    $ui(mainWindow) add $tab -text Radio
    
    # bind
    bind $w2 <ButtonPress-1> [namespace code {flip_stereo %W}]
    bind $w3 <ButtonPress-1> [namespace code {flip_mute %W}]
    bind . <KeyPress-Right> [namespace code {scale_dial up}]
    bind . <KeyPress-Left> [namespace code {scale_dial down}]
    bind . <KeyPress-Up> [namespace code {volume up}]
    bind . <KeyPress-Down> [namespace code {volume down}]
  }
  # ---------------------------------------------
  proc init_tab_config {} {
    variable ui
    variable radio
    
    set tab [ttk::frame $ui(mainWindow).tabConfig]
    set hlsi [ttk::labelframe $tab.lblFrmAlgorithm -text HLSI]
    
    set w1 [ttk::label $tab.lblPortName -text "Puerto serie"]
    set w2 [ttk::entry $tab.entPortName -textvariable [namespace current]::radio(serialPortName)]
    grid $w1 $w2

    set w [ttk::radiobutton $hlsi.chk0 -text No -variable [namespace current]::radio(hiloAlgorithm) -value 0]
    grid $w
    set w [ttk::radiobutton $hlsi.chk1 -text Si -variable [namespace current]::radio(hiloAlgorithm) -value 1]
    grid $w

    grid $hlsi
    
    $ui(mainWindow) add $tab -text Config
  }
  # ---------------------------------------------
  proc load_buttons_state {} {
    variable radio
    variable ui
    
    if {$radio(mute) == 1} {
      set_mute $ui(mute) 1
    }
    if {$radio(stereo) == 1} {
      set_stereo $ui(stereo) 1
    }
    volume_changed $radio(volume)
  }
  # ---------------------------------------------
  proc flip_mute {w} {
    variable radio

    # La variable se actualiza ANTES de la llamada
    set_mute $w [expr !$radio(mute)]
  }
  # ---------------------------------------------
  proc set_mute {w mute} {
    set img imgMuteOff

    if {$mute == 1} {
      set img imgMuteOn
    }
    
    $w configure -image $img
    tea5767_driver::mute $mute
  }
  # ---------------------------------------------
  proc flip_stereo {w} {
    variable radio
    
    # La variable se actualiza ANTES de la llamada
    set_stereo $w [expr !$radio(stereo)]
  }
  # ---------------------------------------------
  proc set_stereo {w stereo} {
    set img imgStereoOff

    if {$stereo == 1} {
      set img imgStereoOn
    }

    $w configure -image $img
    tea5767_driver::high_fidelity $stereo
  }
  # ---------------------------------------------
  proc init_stereo_button {path} {
    variable radio
    
    set stereoImage imgStereoOff
    
    if {$radio(stereo) == 1} {
      set stereoImage imgStereoOn
    }
    
    return [checkbutton $path -image $stereoImage -indicatoron 0]
  }
  # ---------------------------------------------
  proc scale_dial_changed {value {deleteStationName 1}} {
    variable radio
    
    if {$deleteStationName} {
      set radio(stationName) ""
    }
    set frequency [format %.1f $value]
    set radio(dial) $frequency

    if {$radio(hiloAlgorithm)} {
      use_hilo_algorithm $frequency
    }
    tea5767_driver::set_frequency $frequency
    tea5767_driver::read_radio_data
    signal_level [tea5767_driver::get_signal_level]
  }
  # ---------------------------------------------
  proc scale_dial {upDown} {
    variable radio
    
    set radio(stationName) ""
    
    if {$upDown eq "up"} {
      set frequency [format %.1f [expr {$radio(dial) + $radio(dialStep)}]]
    } else {
      set frequency [format %.1f [expr {$radio(dial) - $radio(dialStep)}]]
    }
    
    if {$frequency >= $radio(dialLowFrequency) && $frequency <= $radio(dialHighFrequency)} {
      scale_dial_changed $frequency
    }
  }
  # ---------------------------------------------
  proc add_station {} {
    variable radio
    
    if {![winfo exists .topStations]} {
      tk::toplevel .topStations
      wm title .topStations "Emisoras favoritas"
       
      set radio(stationName) ""
      set w1 [ttk::label .topStations.lblStation -text "Emisora:"]
      set w2 [ttk::entry .topStations.entStation -textvariable [namespace current]::radio(stationName)]
      grid $w1 $w2
      focus $w2
      bind $w2 <Return> [namespace code {insert_station_to_favorites $radio(stationName)}]

      set buttonsFrm [ttk::frame .topStations.buttonsFrm]
      set w [ttk::button $buttonsFrm.btnAdd -image imgAddStation -command [namespace code {insert_station_to_favorites $radio(stationName)}]]
      grid $w
      set w [ttk::button $buttonsFrm.btnRemove -image imgRemoveStation -command [namespace code {delete_station_from_favorites}]]
      grid $w
      
      set w [listbox .topStations.lstboxStations -listvariable [namespace current]::radio(stationsList)]
      grid $w $buttonsFrm -sticky nw
      bind $w <<ListboxSelect>> [namespace code {select_station_from_list}]
    }
  }
  # ---------------------------------------------
  proc insert_station_to_favorites {stationName} {
    variable radio
    
    .topStations.lstboxStations insert 0 $stationName
    dict append radio(stationsDict) $stationName $radio(dial)
    set radio(stationName) $stationName
  }
  # ---------------------------------------------
  proc delete_station_from_favorites {} {
    variable radio
    
    set i [.topStations.lstboxStations curselection]

    if {[llength $i] == 1} {
      set name [lindex $radio(stationsList) $i]
      set radio(stationsDict) [dict remove $radio(stationsDict) $name]
      set radio(stationsList) [lreplace $radio(stationsList) $i $i]
      set radio(stationName) ""
    }
  }
  # ---------------------------------------------
  proc select_station_from_list {} {
    variable radio
    
    set i [.topStations.lstboxStations curselection]

    if {[llength $i] == 1} {
      set radio(stationName) [lindex $radio(stationsList) $i]
      set radio(dial) [dict get $radio(stationsDict) $radio(stationName)]

      scale_dial_changed $radio(dial) 0
    }
  }
  # ---------------------------------------------
  proc volume {upDown} {
    variable radio
    
    set vol [expr {int($radio(volume))}]

    if {$upDown eq "up" & $radio(volume) < 100} {
      set vol [expr {$vol + 1}]
    } elseif {$upDown eq "down" & $radio(volume) > 0} {
      set vol [expr {$vol - 1}]
    }
    volume_changed $vol
  }
  # ---------------------------------------------
  proc volume_changed {value} {
    set vol [format %.1f $value]
    set_volume $vol
  }
  # ---------------------------------------------
  proc set_volume {value} {
    variable radio
    
    set radio(volume) $value
    tea5767_driver::set_volume $value
  }
  # ---------------------------------------------
  proc load_config {} {
    variable radio
    
    create_config_if_not_exists
    set fd [::ini::open $radio(configFile)]
    
    # Configuración
    set configData [::ini::get $fd tea_config]
    
    foreach {k v} $configData {
      set radio($k) $v
    }
    load_last_station_info $radio(dial)
    
    ::ini::close $fd
  }
  # ---------------------------------------------
  proc create_config_if_not_exists {} {
    variable radio
    
    if {![file exists $radio(configFile)]} {
      set fd [open $radio(configFile) w+]
      close $fd
      
      save_config
    }
  }
  # ---------------------------------------------
  proc save_config {} {
    variable radio
    
    set fd [::ini::open $radio(configFile) w]
    
    # Configuración radio
    dict for {k v} [array get radio] {
      ::ini::set $fd tea_config $k $v
    }
    
    ::ini::commit $fd
    ::ini::close $fd
  }
  # ---------------------------------------------
  proc load_last_station_info {fre} {
    variable radio
    
    set lastStationDial $fre
    set lastStationName ""

    dict for {name dial} $radio(stationsDict) {
      if {$dial == $lastStationDial} {
        set radio(stationName) $name
        break
      }
    }
  }
  # ---------------------------------------------
  proc use_hilo_algorithm {fre} {
    tea5767_driver::use_hilo_algorithm $fre
  }
  # ---------------------------------------------
  # @brief  Dividimos los 15 niveles en 5
  # ---------------------------------------------
  proc signal_level {val} {
    variable ui
    
    set w $ui(signalLevel)

    if {$val < 1} {
      $w configure -image imgLev0
    } elseif {$val < 3} {
      $w configure -image imgLev1
    } elseif {$val < 6} {
      $w configure -image imgLev2
    } elseif {$val < 9} {
      $w configure -image imgLev3
    } elseif {$val < 12} {
      $w configure -image imgLev4
    }
  }
}