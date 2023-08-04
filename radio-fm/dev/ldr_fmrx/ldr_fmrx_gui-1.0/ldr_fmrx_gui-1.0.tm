package require Tk
package require inifile
package require ldr_fmrx_driver
 
package provide ldr_fmrx_gui 1.0

namespace eval ldr_fmrx_gui {
  variable radio
  variable ui
  
  array set radio {
    serialPortName ""
    serialPortSpeed 38400
    mute 0
    stereo 0
    stationName ""
    stationsList {}
    stationsDict {}
    dial 87.5
    dialLowFrequency  87.5
    dialHighFrequency 108
    dialStep  0.1
    backlight 0
    configFile  config.ini
    buffer ""
  }
  
  # ---------------------------------------------
  proc init {} {
    variable radio
    variable ui
    
    wm title . "TCL/TK - RADIO FM"
    wm iconname . "Radio"
    wm protocol . WM_DELETE_WINDOW [namespace code {quit}]

    set ui(mainWindow) [ttk::notebook .ntb]
    
    init_images
    init_tab_radio
    init_tab_config
    
    grid $ui(mainWindow)

    load_config
    after 100
    init_driver
    after 100
    ldr_fmrx_driver::set_readable [namespace current]::parse_data
    after 100
    ldr_fmrx_driver::read_radio_data
  }
  # ---------------------------------------------
  proc quit {} {
    ldr_fmrx_driver::quit
    save_config
    exit
  }
  # ---------------------------------------------
  proc init_driver {} {
    variable radio

    ldr_fmrx_driver::init $radio(serialPortName) $radio(serialPortSpeed)
  }
  # ---------------------------------------------
  proc init_images {} {
    image create photo imgMuteOff -file [file nativename ldr_fmrx_gui-1.0/img/mute-off.png]
    image create photo imgMuteOn -file [file nativename ldr_fmrx_gui-1.0/img/mute-on.png]
    image create photo imgDialUp -file [file nativename ldr_fmrx_gui-1.0/img/dial-up.png]
    image create photo imgDialDown -file [file nativename ldr_fmrx_gui-1.0/img/dial-down.png]
    image create photo imgAddStationStart -file [file nativename ldr_fmrx_gui-1.0/img/add-station-star.png]
    image create photo imgAddStation -file [file nativename ldr_fmrx_gui-1.0/img/add.png]
    image create photo imgRemoveStation -file [file nativename ldr_fmrx_gui-1.0/img/remove.png]
  }
  # ---------------------------------------------
  proc init_tab_radio {} {
    variable ui
    variable radio
    
    set tab [ttk::frame $ui(mainWindow).tabRadio]
    set firstRow [ttk::frame $tab.frm1Row -padding {280 0 0 0}]
    set volumeUpDown [ttk::frame $tab.frmVolUpDown]
    set secondRow [ttk::frame $tab.frm2Row]
    set dialUpDown [ttk::frame $tab.frmDialButtons]
    set step [ttk::labelframe $tab.lblFrmStep -text Paso]

    # --------
    # firstRow
    # --------
    # NOTE  Parece que ttk::checkbutton no tiene la opción '-indicartoron'
    set w1 [ttk::button $firstRow.btnAddStation -image imgAddStationStart -command [namespace code {add_station}]]
    #set w2 [checkbutton $firstRow.btnMute -height 65 -image imgMuteOff -indicatoron 0]
    set w2 [checkbutton $firstRow.btnMute -image imgMuteOff -indicatoron 0]
    grid $w1 $w2 $volumeUpDown

    bind $w2 <ButtonPress-1> [namespace code {set_mute %W}]
    
    #set w [ttk::button $volumeUpDown.btnVolUp -text "+" -width 2 -command [namespace code {vol up}]]
    set w [ttk::button $volumeUpDown.btnVolUp -image imgDialUp -command [namespace code {vol up}]]
    grid $w
    #set w [ttk::button $volumeUpDown.btnVolDown -text "-" -width 2 -command [namespace code {vol down}]]
    set w [ttk::button $volumeUpDown.btnVolDown -image imgDialDown -command [namespace code {vol down}]]
    grid $w

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
  }
  # ---------------------------------------------
  proc init_tab_config {} {
    variable ui
    
    set tab [ttk::frame $ui(mainWindow).tabConfig]
    set backlight [ttk::labelframe $tab.lblFrmBacklight -text Backlight]
    
    set w1 [ttk::label $tab.lblPortName -text "Puerto serie"]
    set w2 [ttk::entry $tab.entPortName -textvariable [namespace current]::radio(serialPortName)]
    grid $w1 $w2
    
    set w [ttk::radiobutton $backlight.chk0 -text No -variable [namespace current]::radio(backlight) -value 0 -command [namespace code {set_backlight}]]
    grid $w
    set w [ttk::radiobutton $backlight.chk1 -text Si -variable [namespace current]::radio(backlight) -value 1 -command [namespace code {set_backlight}]]
    grid $w

    grid $backlight
    
    $ui(mainWindow) add $tab -text Config
  }
  # ---------------------------------------------
  proc set_mute {w} {
    variable radio
    
    set mute 0
    set img imgMuteOff

    if {$radio(mute) == 0} {
      set mute 1
      set img imgMuteOn
    }
    
    set radio(mute) $mute
    $w configure -image $img
    ldr_fmrx_driver::mute $mute
  }
  # ---------------------------------------------
  proc init_mute_icon {state} {
    variable radio
    
    
  }
  # ---------------------------------------------
  proc scale_dial_changed {value {deleteStationName 1}} {
    variable radio
    
    if {$deleteStationName} {
      set radio(stationName) ""
    }
    set frequency [format %.1f $value]
    set radio(dial) $frequency

    # Las frecuencias en el dispositivo van sin .
    set frequency [string map {. ""} $frequency]
    ldr_fmrx_driver::set_frequency $frequency
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
  proc vol {upDown} {
    ldr_fmrx_driver::vol $upDown
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
      set w [ttk::button $buttonsFrm.btnRemove -image imgAddStation -command [namespace code {insert_station_to_favorites $radio(stationName)}]]
      grid $w
      set w [ttk::button $buttonsFrm.btnAdd -image imgRemoveStation -command [namespace code {delete_station_from_favorites}]]
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
  proc set_backlight {} {
    variable radio
 
    ldr_fmrx_driver::backlight $radio(backlight)
  }
  # ---------------------------------------------
  proc load_config {} {
    variable radio
    
    #create_config_if_not_exists
    set fd [::ini::open $radio(configFile)]
    
    # Configuración
    set configData [::ini::get $fd radio_config]
    
    foreach {k v} $configData {
      set radio($k) $v
    }
    #load_last_station_info $radio(dial)
    
    # Estaciones favoritas
    if {[::ini::exists $fd fav_stations]} {
      set radio(stationsDict) [dict create]
      set stations [::ini::get $fd fav_stations]
      
      foreach {k v} $stations {
        dict append radio(stationsDict) $k $v
        lappend radio(stationsList) $k
      }
    }

    ::ini::close $fd
  }
  # ---------------------------------------------
  proc save_config {} {
    variable radio
    
    set fd [::ini::open $radio(configFile)]
    
    # Configuración radio
    ::ini::set $fd radio_config serialPortName $radio(serialPortName)
    ::ini::set $fd radio_config serialPortSpeed $radio(serialPortSpeed)
    ::ini::set $fd radio_config backlight $radio(backlight)
    
    # Emisoras favoritas
    dict for {k v} $radio(stationsDict) {
      ::ini::set $fd fav_stations $k $v
    }
    
    ::ini::commit $fd
    ::ini::close $fd
  }
  # ---------------------------------------------
  # TODO
  # -la info puede venir fraccionada... hay que usar un buffer
  proc parse_data {} {
    variable radio
    
    set radio(buffer) [string cat $radio(buffer) [ldr_fmrx_driver::receive]]
    # DEBUG
    #puts $radio(buffer)
    
    # Comprobar si tenemos info de la frecuencia actual, y del mute
    set index [string first PCB_NUMBE $radio(buffer)]
    
    if {$index != -1} {
      # Frecuencia
      regexp {FRE=(\d*)} $radio(buffer) x fre
      set fre [string cat [string range $fre 0 end-1] . [string range $fre end end]]
      # DEBUG
      #puts "Frecuencia actual: $fre"
      dict for {name frequency} $radio(stationsDict) {
        # DEBUG
        #puts "$name - $frequency"
        if {$frequency eq $fre} {
          set radio(stationName) $name
          set radio(dial) $frequency
          break
        }
      }
      # Mute
      set index [string first PLAY $radio(buffer)]
      set w .ntb.tabRadio.frm1Row.btnMute
      
      if {$index != -1} {
        set radio(mute) 0
        $w configure -image imgMuteOff
      } else {
        set radio(mute) 1
        $w configure -image imgMuteOn
        $w select
      }
      set radio(buffer) ""
      ldr_fmrx_driver::unset_readable
    }
  }
}