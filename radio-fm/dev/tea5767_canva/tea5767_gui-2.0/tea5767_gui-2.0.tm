package require Tk
package require inifile
package require tea5767_driver
package require volume
package require dial
 
package provide tea5767_gui 2.0

namespace eval tea5767_gui {
  variable radio
  variable ui
  
  array set radio {
    serialPortName x
    serialPortSpeed 9600
    mute 0
    stereo 0
    volume 10
    dial 87.5
    dialLowFrequency  87.5
    dialHighFrequency 108
    dialStep  0.1
    hlsi 1
    stationName ""
    stationsDict {}
    configFile  config.ini
  }
  
  array set ui {
    canvas ""
    mute ""
    stereo ""
    newStation ""
    treeIndex ""
    backgroundColor #545454
    triadic1 #79CC8E
    triadic2 #8E79CC
    triadic3 #CC8E79
    xDialTicks 75
    y0DialTicks 440
    y1DialTicks 460
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
    load_config
    int_main_canvas
    
    grid $ui(mainWindow)

    init_driver
    # Necesita un tiempo para responder
    after 3000
    scale_dial_changed $radio(dial) 0
    load_widgets_state
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
    # Canvas
    image create photo cnvRadio -file [file nativename tea5767_gui-2.0/img/caratula-1.png]
    image create photo cnvConfiguration -file [file nativename tea5767_gui-2.0/img/configuration.png]
    image create photo cnvStations -file [file nativename tea5767_gui-2.0/img/stations.png]
    
    # widgets
    image create photo imgShutdown -file [file nativename tea5767_gui-2.0/img/boton-apagado.png]
    image create photo imgBurger -file [file nativename tea5767_gui-2.0/img/boton-lista.png]
    image create photo imgMuteOff -file [file nativename tea5767_gui-2.0/img/mute-off.png]
    image create photo imgMuteOn -file [file nativename tea5767_gui-2.0/img/mute-on.png]
    image create photo imgStereoOn -file [file nativename tea5767_gui-2.0/img/stereo-on.png]
    image create photo imgStereoOff -file [file nativename tea5767_gui-2.0/img/stereo-off.png]
    image create photo imgBack -file [file nativename tea5767_gui-2.0/img/back.png]
    image create photo imgVolLow -file [file nativename tea5767_gui-2.0/img/vol-low.png]
    image create photo imgVolHigh -file [file nativename tea5767_gui-2.0/img/vol-high.png]
    image create photo imgLeftArrow -file [file nativename tea5767_gui-2.0/img/left-arrow.png]
    image create photo imgRightArrow -file [file nativename tea5767_gui-2.0/img/right-arrow.png]
    image create photo imgFMAntenna -file [file nativename tea5767_gui-2.0/img/fm-antenna.png]
    image create photo imgAddStation -file [file nativename tea5767_gui-2.0/img/add.png]
    image create photo imgRemoveStation -file [file nativename tea5767_gui-2.0/img/remove.png]
    image create photo imgPoint -file [file nativename tea5767_gui-2.0/img/point.png]
  }
  # ---------------------------------------------
  proc int_main_canvas {} {
    variable radio
    variable ui
    
    set cnv [canvas .canvas -width 380 -height 626]
    set ui(canvas) $cnv
        
    # Si no usamos 'anchor' la imagen se muestra centrada desde ese punto.
    # Con 'anchor' indica dónde queremos el punto superior-izq
    $cnv create image 0 0 -image cnvRadio -anchor nw

    # Fuentes
    font create fntOptions -family Helvetica -size 14 -weight bold
    font create fntDial -family Helvetica -size 64 -weight bold
    
    # Dial
    set frequencies [list $radio(dial) $radio(dialLowFrequency) $radio(dialHighFrequency)]
    set coordinates [list $ui(xDialTicks) $ui(y0DialTicks) $ui(y1DialTicks)]
    set colours [list $ui(triadic1) $ui(triadic2) $ui(triadic3)]   
    dial::init $cnv $frequencies $coordinates $colours
    set rightArrow [$cnv create image 335 280 -image imgRightArrow -anchor nw]
    set leftArrow [$cnv create image 20 280 -image imgLeftArrow -anchor nw]
    
    # Volumen
    set colours [list $ui(triadic1) $ui(triadic2) $ui(triadic3)]
    set coords {100 585 300 585}
    volume::init $cnv $radio(volume) $colours $coords
    set volLow [$cnv create image 15 570 -image imgVolLow -anchor nw]
    set volHigh [$cnv create image 350 570 -image imgVolHigh -anchor nw]
    $cnv bind $volLow <ButtonPress-1> [namespace code {volume down}]
    $cnv bind $volHigh <ButtonPress-1> [namespace code {volume up}]

    # Mute
    # NOTE
    # Resulta que ttk::button no tiene background...
    set btnMute [button $cnv.btnMute -image [get_mute_image]  -background $ui(backgroundColor) -activebackground $ui(backgroundColor) -relief flat]
    $cnv create window 15 440 -anchor nw -window $btnMute
    set ui(mute) $btnMute
    
    # dial digital
    $cnv create text 200 275 -fill white -text $radio(dial) -font fntDial -tags digitalDial
    $cnv create text 200 350 -fill white -text $radio(stationName) -tags stationName

    # Otros...
    set shutdown [$cnv create image 325 20 -image imgShutdown -anchor nw]
    set options [$cnv create image 20 25 -image imgBurger -anchor nw]
    set stations [$cnv create image 323 440 -image imgBurger -anchor nw]
    
    # bind
    #
    # ratón
    $cnv bind $rightArrow <ButtonPress-1> [namespace code {move_dial right}]
    $cnv bind $leftArrow <ButtonPress-1> [namespace code {move_dial left}]
    $cnv bind $shutdown <ButtonPress-1> [namespace code {quit}]
    $cnv bind $options <ButtonPress-1> [namespace code {config}]
    $cnv bind $stations <ButtonPress-1> [namespace code {stations}]
    bind $btnMute <ButtonPress-1> [namespace code {flip_mute %W}]
    
    # teclado
    bind . <KeyPress-Right> [namespace code {move_dial right}]
    bind . <KeyPress-Left> [namespace code {move_dial left}]
    bind . <KeyPress-Up> [namespace code {volume up}]
    bind . <KeyPress-Down> [namespace code {volume down}]
    
    # virtual
    event add <<Dial>> <Shift-F12>
    event add <<Volume>> <Shift-F11>
    bind . <<Dial>> [namespace code {handle_dial_event}]
    bind . <<Volume>> [namespace code {handle_volume_event}]
    
    grid $cnv
  }
  # ---------------------------------------------
  proc config {} {
    variable radio
    variable ui
    
    if {![winfo exists .topConfiguration]} {
      toplevel .topConfiguration
      wm title .topConfiguration "Configuración"
      
      # canvas
      set cnv [canvas .topConfiguration.canvas -width 380 -height 626]   
      $cnv create image 0 0 -image cnvConfiguration -anchor nw
      
      # back
      set back [$cnv create image 15 30 -image imgBack -anchor nw]

      # Puerto
      set lblPort [ttk::label $cnv.lblPort -text "Puerto" -background $ui(backgroundColor) -foreground white -font fntOptions]
      set entPort [ttk::entry $cnv.entPort -textvariable [namespace current]::radio(serialPortName)]
      $cnv create window 10 100 -anchor nw -window $lblPort
      $cnv create window 100 103 -anchor nw -window $entPort

      # Paso
      set lblStep [ttk::label $cnv.lblStep -text "Paso" -background $ui(backgroundColor) -foreground white -font fntOptions]
      set radBtnStep01 [radiobutton $cnv.radStep01 -text "0.1" -variable [namespace current]::radio(dialStep) -value 0.1 -background $ui(backgroundColor) -activebackground $ui(backgroundColor) -command [namespace code {update_dial_step}]]
      set radBtnStep05 [radiobutton $cnv.radStep05 -text "0.5" -variable [namespace current]::radio(dialStep) -value 0.5 -background $ui(backgroundColor) -activebackground $ui(backgroundColor) -command [namespace code {update_dial_step}]]    
      $cnv create window 10 150 -anchor nw -window $lblStep
      $cnv create window 100 150 -anchor nw -window $radBtnStep01
      $cnv create window 100 175 -anchor nw -window $radBtnStep05

      # Algoritmo HLSI
      set lblHLSI [ttk::label $cnv.lblHLSI -text "HLSI" -background $ui(backgroundColor) -foreground white -font fntOptions]
      set radBtnHLSIYes [radiobutton $cnv.radHLSIYes -text Si -variable [namespace current]::radio(hlsi) -value 1 -background $ui(backgroundColor) -activebackground $ui(backgroundColor)]
      set radBtnHLSINo [radiobutton $cnv.radHLSINo -text No -variable [namespace current]::radio(hlsi) -value 0 -background $ui(backgroundColor) -activebackground $ui(backgroundColor)]
      $cnv create window 10 200 -anchor nw -window $lblHLSI
      $cnv create window 100 220 -anchor nw -window $radBtnHLSIYes
      $cnv create window 100 245 -anchor nw -window $radBtnHLSINo
      
      # Calidad sonido
      set lblStereo [ttk::label $cnv.lblStereo -text "Sonido" -background $ui(backgroundColor) -foreground white -font fntOptions]
      set btnStereo [button $cnv.btnStereo -image [get_stereo_image]  -background $ui(backgroundColor) -activebackground $ui(backgroundColor) -relief flat]
      $cnv create window 10 270 -anchor nw -window $lblStereo
      $cnv create window 100 270 -anchor nw -window $btnStereo

      # bind
      $cnv bind $back <ButtonPress-1> [namespace code {close_dialog .topConfiguration}]
      bind $btnStereo <ButtonPress-1> [namespace code {flip_stereo %W}]
      
      # grid
      grid $cnv
    }
  }
  # ---------------------------------------------
  proc load_widgets_state {} {
    variable radio
    variable ui
    
    # Damos un valor inicial de volumen porque si
    # venimos de mute, al hacer unmute no sabe qué
    # valor de volumen tenía y se oye mal
    volume_changed $radio(volume)
    if {$radio(mute) == 1} {
      set_mute $ui(mute) 1
    }

    dict for {name dial} $radio(stationsDict) {
      if {$dial == $radio(dial)} {
        set radio(stationName) $name
        scale_dial_changed $dial 0
        break
      }
    }

    dial::set_step $radio(dialStep)
  }
  # ---------------------------------------------
  proc flip_mute {w} {
    variable radio
    
    set radio(mute) [expr !$radio(mute)]
    set_mute $w $radio(mute)
  }
  # ---------------------------------------------
  proc set_mute {w mute} {
    $w configure -image [get_mute_image]
    tea5767_driver::mute $mute
  }
  # ---------------------------------------------
  proc get_mute_image {} {
    variable radio
    
    set result imgMuteOff
    
    if {$radio(mute) == 1} {
      set result imgMuteOn
    }
    
    return $result
  }
  # ---------------------------------------------
  proc flip_stereo {w} {
    variable radio
    
    set stereo [expr !$radio(stereo)]
    set radio(stereo) $stereo
    set_stereo $w $stereo    
  }
  # ---------------------------------------------
  proc set_stereo {w stereo} {
    set img [get_stereo_image]
    $w configure -image $img
    tea5767_driver::high_fidelity $stereo
  }
  # ---------------------------------------------
  proc get_stereo_image {} {
    variable radio
    
    set result imgStereoOff
    
    if {$radio(stereo) == 1} {
      set result imgStereoOn
    }
    
    return $result
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
  proc scale_dial_changed {fre {deleteStationName 1}} {
    variable radio
    variable ui
    
    if {[dial::frequency_in_range $fre]} {
      if {$deleteStationName} {
        set radio(stationName) ""
      }
      set frequency [format %.1f $fre]
      set radio(dial) $frequency
      $ui(canvas) itemconfigure digitalDial -text $frequency
      $ui(canvas) itemconfigure stationName -text $radio(stationName)
      dial::set_frequency $frequency

      if {$radio(hlsi)} {
        use_hilo_algorithm $frequency
      }
      tea5767_driver::set_frequency $frequency
    }
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
  proc stations {} {
    variable ui
    variable radio
    
    if {![winfo exists .topStations]} {
      toplevel .topStations
      wm title .topStations "Emisoras"
      
      # canvas
      set cnv [canvas .topStations.canvas -width 380 -height 626]
      $cnv create image 0 0 -image cnvStations -anchor nw

      set back [$cnv create image 15 30 -image imgBack -anchor nw]
      
      # emisoras
      set lblStation [ttk::label $cnv.lblStation -text Emisora]
      $cnv create window 3 75 -anchor nw -window $lblStation
      set entStation [ttk::entry $cnv.entStation -textvariable [namespace current]::ui(newStation)]
      $cnv create window 60 75 -anchor nw -window $entStation
      set addStation [$cnv create image 320 76 -image imgAddStation -anchor nw]
      set removeStation [$cnv create image 350 76 -image imgRemoveStation -anchor nw]

      # treeview
      #
      # Resulta que no todos los temas soportan -fieldbackground...
      # https://stackoverflow.com/questions/43816930/how-to-fully-change-the-background-color-on-a-tkinter-ttk-treeview
      # clam sí que lo soporta y por eso lo estoy usando. Estos son los que hay disponibles
      #ttk::style theme names
      #winnative clam alt default classic vista xpnative
      # parece que los únicos que no lo soportan son: vista y xpnative
      ttk::style theme use default
      ttk::style configure Treeview -background $ui(backgroundColor) -fieldbackground $ui(backgroundColor) -foreground white -width 380 -borderwidth 0
      set lstStations [ttk::treeview .topStations.lstStations]
      set ui(lstStations) $lstStations
      $lstStations tag configure highlight -background #DCCDA2 -image imgPoint -foreground white
      dict for {name fre} $radio(stationsDict) {
        if {$fre == $radio(dial)} {
          $lstStations insert {} end -text $name -values $fre -tag highlight
        } else {
          $lstStations insert {} end -text $name -values $fre
        }
      }
      # Solo se puede seleccionar una emisora y el máximo que da el canvas son 24...
      $lstStations configure -selectmode browse -height 23
      $lstStations configure -columns "frequency"
      # TODO column name ??¿¿
      $lstStations column #0 -width 300
      #$lstStations heading #0 -image imgFMAntenna -anchor w
      $cnv create window 3 105 -anchor nw -window $lstStations

      # bind
      $cnv bind $back <ButtonPress-1> [namespace code {close_dialog .topStations}]
      # TODO
      # ¿por qué no puedo usar $ui(newStation) y sí $radio(dial) como parámetros?
      $cnv bind $addStation <ButtonPress-1> [namespace code "insert_station_to_favorites"]
      $cnv bind $removeStation <ButtonPress-1> [namespace code "delete_station_from_favorites"]
      bind $lstStations <<TreeviewSelect>> [namespace code {select_station_from_list}]

      grid $cnv
    }
  }
  # ---------------------------------------------
  proc insert_station_to_favorites {} {
    variable ui
    variable radio
    
    $ui(lstStations) insert {} end -text $ui(newStation) -values $radio(dial) -tag highlight
    set radio(stationsDict) [dict append radio(stationsDict) $ui(newStation) $radio(dial)]
    set radio(stationName) $ui(newStation)
    scale_dial_changed $radio(dial) 0
  }
  # ---------------------------------------------
  proc delete_station_from_favorites {} {
    variable ui
    variable radio
    
    if {$ui(treeIndex) ne ""} {
      set aDict [$ui(lstStations) item $ui(treeIndex)]
      set stationName [dict get $aDict -text]
      set frequency [dict get $aDict -values]
      set radio(stationsDict) [dict remove $radio(stationsDict) $stationName]
      $ui(lstStations) delete $ui(treeIndex)
      set radio(stationName) ""
      scale_dial_changed $frequency
    }
  }
  # ---------------------------------------------
  proc select_station_from_list {} {
    variable ui
    variable radio
    
    set treeIndex [$ui(lstStations) select]
    set ui(treeIndex) $treeIndex
    set aDict [$ui(lstStations) item $treeIndex]
    
    set stationName [dict get $aDict -text]
    set fre [dict get $aDict -values]
    
    $ui(lstStations) tag remove highlight
    $ui(lstStations) tag add highlight $treeIndex
    
    set radio(stationName) $stationName
    set radio(dial) $fre
    scale_dial_changed $radio(dial) 0
  }
  # ---------------------------------------------
  proc volume {upDown} {
    volume::step $upDown
    set vol [volume::get_volume]
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
  proc move_dial {side {deleteStationName 1}} {
    set fre [dial::step_frequency $side]
    
    scale_dial_changed $fre $deleteStationName
  }
  # ---------------------------------------------
  proc update_dial_step {} {
    variable radio
    
    dial::set_step $radio(dialStep)
  }
  # ---------------------------------------------
  proc handle_dial_event {} {    
    set frequency [dial::get_frequency]
    scale_dial_changed $frequency
  }
  # ---------------------------------------------
  proc handle_volume_event {} {    
    set vol [volume::get_volume]
    volume_changed $vol
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
    
    # Estaciones favoritas
    if {[::ini::exists $fd fav_stations]} {
      set radio(stationsDict) [dict create]
      set stations [::ini::get $fd fav_stations]
      
      foreach {k v} $stations {
        dict append radio(stationsDict) $k $v
      }
    }

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
    ::ini::set $fd tea_config dial $radio(dial)
    ::ini::set $fd tea_config mute $radio(mute)
    ::ini::set $fd tea_config stereo $radio(stereo)
    ::ini::set $fd tea_config hlsi $radio(hlsi)
    ::ini::set $fd tea_config volume $radio(volume)
    ::ini::set $fd tea_config dialStep $radio(dialStep)
    ::ini::set $fd tea_config serialPortName $radio(serialPortName)
    ::ini::set $fd tea_config serialPortSpeed $radio(serialPortSpeed)
    
    # Emisoras favoritas
    dict for {k v} $radio(stationsDict) {
      ::ini::set $fd fav_stations $k $v
    }
    
    ::ini::commit $fd
    ::ini::close $fd
  }
  # ---------------------------------------------
  proc use_hilo_algorithm {fre} {
    tea5767_driver::use_hilo_algorithm $fre
  }
  # ---------------------------------------------
  proc close_dialog {w} {
    destroy $w
  }
}