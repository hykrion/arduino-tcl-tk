# Traducciones de cursores espectrales para OSCAR (msgcat).
# Cargar dentro de namespace eval ::OSCAR.
foreach {locale entries} {
  es {
    spectral_cursor_reset {Borrar cursores}
    spectral_cursor_visible {Mostrar cursores}
    spectral_cursor_hint {C1: clic o arrastrar · C2: Mayús+clic o botón derecho · al medir se pausa el historial}
    spectral_cursor_empty {%s: sin seleccionar}
    spectral_cursor_dc {%s: componente continua no medida}
    spectral_cursor_readout {%s · %s · %s dBFS · hace %s s · bin %d}
    spectral_cursor_difference_pending {Δ: seleccione ambos cursores}
    spectral_cursor_difference {Δf %s · Δnivel %s dB · Δtiempo %s s}
    waterfall_gain_pending {Ganancia de ventana: esperando espectro}
    waterfall_gain {Ganancia coherente: %s (%s dB)}
    waterfall_bad_gain {Ganancia coherente no válida}
    waterfall_gain_uncalibrated {DHT sin calibración: niveles dBFS aproximados}
  }
  en {
    spectral_cursor_reset {Reset cursors}
    spectral_cursor_visible {Show cursors}
    spectral_cursor_hint {C1: click or drag · C2: Shift+click or right-click · selecting a cursor pauses history}
    spectral_cursor_empty {%s: not selected}
    spectral_cursor_dc {%s: DC component not measured}
    spectral_cursor_readout {%s · %s · %s dBFS · %s s ago · bin %d}
    spectral_cursor_difference_pending {Δ: select both cursors}
    spectral_cursor_difference {Δf %s · Δlevel %s dB · Δtime %s s}
    waterfall_gain_pending {Window gain: waiting for spectrum}
    waterfall_gain {Coherent gain: %s (%s dB)}
    waterfall_bad_gain {Invalid coherent gain}
    waterfall_gain_uncalibrated {DHT without calibration: approximate dBFS levels}
  }
  ca {
    spectral_cursor_reset {Esborra els cursors}
    spectral_cursor_visible {Mostra els cursors}
    spectral_cursor_hint {C1: clic o arrossegar · C2: Maj+clic o botó dret · en mesurar es pausa l’historial}
    spectral_cursor_empty {%s: sense seleccionar}
    spectral_cursor_dc {%s: component contínua no mesurada}
    spectral_cursor_readout {%s · %s · %s dBFS · fa %s s · bin %d}
    spectral_cursor_difference_pending {Δ: seleccioneu els dos cursors}
    spectral_cursor_difference {Δf %s · Δnivell %s dB · Δtemps %s s}
    waterfall_gain_pending {Guany de finestra: esperant espectre}
    waterfall_gain {Guany coherent: %s (%s dB)}
    waterfall_bad_gain {Guany coherent no vàlid}
    waterfall_gain_uncalibrated {DHT sense calibratge: nivells dBFS aproximats}
  }
  de {
    spectral_cursor_reset {Cursor zurücksetzen}
    spectral_cursor_visible {Cursor anzeigen}
    spectral_cursor_hint {C1: Klicken/Ziehen · C2: Umschalt+Klick oder Rechtsklick · Messung pausiert den Verlauf}
    spectral_cursor_empty {%s: nicht ausgewählt}
    spectral_cursor_dc {%s: Gleichanteil nicht gemessen}
    spectral_cursor_readout {%s · %s · %s dBFS · vor %s s · Bin %d}
    spectral_cursor_difference_pending {Δ: beide Cursor wählen}
    spectral_cursor_difference {Δf %s · ΔPegel %s dB · ΔZeit %s s}
    waterfall_gain_pending {Fensterverstärkung: warte auf Spektrum}
    waterfall_gain {Kohärente Verstärkung: %s (%s dB)}
    waterfall_bad_gain {Ungültige kohärente Verstärkung}
    waterfall_gain_uncalibrated {DHT ohne Kalibrierung: dBFS-Werte näherungsweise}
  }
  fr {
    spectral_cursor_reset {Effacer les curseurs}
    spectral_cursor_visible {Afficher les curseurs}
    spectral_cursor_hint {C1 : clic/glisser · C2 : Maj+clic ou clic droit · la mesure suspend l’historique}
    spectral_cursor_empty {%s : non sélectionné}
    spectral_cursor_dc {%s : composante continue non mesurée}
    spectral_cursor_readout {%s · %s · %s dBFS · il y a %s s · bin %d}
    spectral_cursor_difference_pending {Δ : sélectionnez les deux curseurs}
    spectral_cursor_difference {Δf %s · Δniveau %s dB · Δtemps %s s}
    waterfall_gain_pending {Gain de fenêtre : en attente du spectre}
    waterfall_gain {Gain cohérent : %s (%s dB)}
    waterfall_bad_gain {Gain cohérent invalide}
    waterfall_gain_uncalibrated {DHT non étalonnée : niveaux dBFS approximatifs}
  }
  gl {
    spectral_cursor_reset {Borrar cursores}
    spectral_cursor_visible {Mostrar cursores}
    spectral_cursor_hint {C1: clic ou arrastrar · C2: Maiús+clic ou botón dereito · ao medir páusase o historial}
    spectral_cursor_empty {%s: sen seleccionar}
    spectral_cursor_dc {%s: compoñente continua non medida}
    spectral_cursor_readout {%s · %s · %s dBFS · hai %s s · bin %d}
    spectral_cursor_difference_pending {Δ: seleccione os dous cursores}
    spectral_cursor_difference {Δf %s · Δnivel %s dB · Δtempo %s s}
    waterfall_gain_pending {Ganancia da xanela: agardando espectro}
    waterfall_gain {Ganancia coherente: %s (%s dB)}
    waterfall_bad_gain {Ganancia coherente non válida}
    waterfall_gain_uncalibrated {DHT sen calibración: niveis dBFS aproximados}
  }
  it {
    spectral_cursor_reset {Azzera cursori}
    spectral_cursor_visible {Mostra cursori}
    spectral_cursor_hint {C1: clic o trascina · C2: Maiusc+clic o tasto destro · la misura mette in pausa lo storico}
    spectral_cursor_empty {%s: non selezionato}
    spectral_cursor_dc {%s: componente continua non misurata}
    spectral_cursor_readout {%s · %s · %s dBFS · %s s fa · bin %d}
    spectral_cursor_difference_pending {Δ: seleziona entrambi i cursori}
    spectral_cursor_difference {Δf %s · Δlivello %s dB · Δtempo %s s}
    waterfall_gain_pending {Guadagno della finestra: in attesa dello spettro}
    waterfall_gain {Guadagno coerente: %s (%s dB)}
    waterfall_bad_gain {Guadagno coerente non valido}
    waterfall_gain_uncalibrated {DHT non calibrata: livelli dBFS approssimativi}
  }
  pt {
    spectral_cursor_reset {Limpar cursores}
    spectral_cursor_visible {Mostrar cursores}
    spectral_cursor_hint {C1: clique ou arraste · C2: Shift+clique ou botão direito · medir pausa o histórico}
    spectral_cursor_empty {%s: não selecionado}
    spectral_cursor_dc {%s: componente contínua não medida}
    spectral_cursor_readout {%s · %s · %s dBFS · há %s s · bin %d}
    spectral_cursor_difference_pending {Δ: selecione os dois cursores}
    spectral_cursor_difference {Δf %s · Δnível %s dB · Δtempo %s s}
    waterfall_gain_pending {Ganho da janela: a aguardar espectro}
    waterfall_gain {Ganho coerente: %s (%s dB)}
    waterfall_bad_gain {Ganho coerente inválido}
    waterfall_gain_uncalibrated {DHT sem calibração: níveis dBFS aproximados}
  }
  eu {
    spectral_cursor_reset {Garbitu kurtsoreak}
    spectral_cursor_visible {Erakutsi kurtsoreak}
    spectral_cursor_hint {C1: klik egin edo arrastatu · C2: Maius+klik edo eskuineko botoia · neurtzean historia pausatzen da}
    spectral_cursor_empty {%s: hautatu gabe}
    spectral_cursor_dc {%s: osagai jarraitua ez da neurtu}
    spectral_cursor_readout {%s · %s · %s dBFS · duela %s s · bin %d}
    spectral_cursor_difference_pending {Δ: hautatu bi kurtsoreak}
    spectral_cursor_difference {Δf %s · Δmaila %s dB · Δdenbora %s s}
    waterfall_gain_pending {Leihoaren irabazia: espektroaren zain}
    waterfall_gain {Irabazi koherentea: %s (%s dB)}
    waterfall_bad_gain {Irabazi koherente baliogabea}
    waterfall_gain_uncalibrated {DHT kalibratu gabe: gutxi gorabeherako dBFS mailak}
  }
  ja {
    spectral_cursor_reset {カーソルを消去}
    spectral_cursor_visible {カーソルを表示}
    spectral_cursor_hint {C1：クリック／ドラッグ · C2：Shift＋クリック／右クリック · 測定時は履歴を一時停止}
    spectral_cursor_empty {%s：未選択}
    spectral_cursor_dc {%s：直流成分は未測定}
    spectral_cursor_readout {%s · %s · %s dBFS · %s 秒前 · ビン %d}
    spectral_cursor_difference_pending {Δ：両方のカーソルを選択}
    spectral_cursor_difference {Δf %s · Δレベル %s dB · Δ時間 %s 秒}
    waterfall_gain_pending {窓のゲイン：スペクトル待機中}
    waterfall_gain {コヒーレントゲイン：%s (%s dB)}
    waterfall_bad_gain {コヒーレントゲインが無効}
    waterfall_gain_uncalibrated {DHTが未較正のためdBFS値は概算です}
  }
  zh_cn {
    spectral_cursor_reset {清除光标}
    spectral_cursor_visible {显示光标}
    spectral_cursor_hint {C1：单击或拖动 · C2：Shift+单击或右键 · 测量时暂停历史}
    spectral_cursor_empty {%s：未选择}
    spectral_cursor_dc {%s：未测量直流分量}
    spectral_cursor_readout {%s · %s · %s dBFS · %s 秒前 · 频点 %d}
    spectral_cursor_difference_pending {Δ：请选择两个光标}
    spectral_cursor_difference {Δf %s · Δ电平 %s dB · Δ时间 %s 秒}
    waterfall_gain_pending {窗增益：等待频谱数据}
    waterfall_gain {相干增益：%s（%s dB）}
    waterfall_bad_gain {相干增益无效}
    waterfall_gain_uncalibrated {DHT 未校准：dBFS 电平为近似值}
  }
} {
  foreach {key value} $entries {
    ::msgcat::mcset $locale $key $value
  }
}
