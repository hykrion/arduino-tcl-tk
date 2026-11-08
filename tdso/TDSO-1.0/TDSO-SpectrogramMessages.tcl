# Catalogo adicional. Se ejecuta dentro de namespace eval TDSO.
foreach {locale entries} {
  ca {
    waterfall_menu {Espectrograma…}
    waterfall_title {Espectrograma | TDSO}
    waterfall_note {Historial espectral · freqüència de 0 a Fs/2 · amplitud relativa (dB)}
    waterfall_pause {Pausa l’historial}
    waterfall_continue {Reprèn}
    waterfall_clear {Neteja l’historial}
    waterfall_frames {%d files · últim interval: %d ms}
  }
  de {
    waterfall_menu {Spektrogramm…}
    waterfall_title {Spektrogramm | TDSO}
    waterfall_note {Spektralverlauf · Frequenz 0 bis Fs/2 · relative Amplitude (dB)}
    waterfall_pause {Verlauf anhalten}
    waterfall_continue {Fortsetzen}
    waterfall_clear {Verlauf löschen}
    waterfall_frames {%d Zeilen · letztes Intervall: %d ms}
  }
  en {
    waterfall_menu {Spectrogram…}
    waterfall_title {Spectrogram | TDSO}
    waterfall_note {Spectral history · frequency 0 to Fs/2 · relative amplitude (dB)}
    waterfall_pause {Pause history}
    waterfall_continue {Resume history}
    waterfall_clear {Clear history}
    waterfall_frames {%d rows · last interval: %d ms}
  }
  es {
    waterfall_menu {Espectrograma…}
    waterfall_title {Espectrograma | TDSO}
    waterfall_note {Historial espectral · frecuencia de 0 a Fs/2 · amplitud relativa (dB)}
    waterfall_pause {Pausar historial}
    waterfall_continue {Reanudar historial}
    waterfall_clear {Limpiar historial}
    waterfall_frames {%d filas · último intervalo: %d ms}
  }
  eu {
    waterfall_menu {Espektrograma…}
    waterfall_title {Espektrograma | TDSO}
    waterfall_note {Espektroaren historia · 0–Fs/2 maiztasuna · anplitude erlatiboa (dB)}
    waterfall_pause {Pausatu historia}
    waterfall_continue {Jarraitu}
    waterfall_clear {Garbitu historia}
    waterfall_frames {%d errenkada · azken tartea: %d ms}
  }
  fr {
    waterfall_menu {Spectrogramme…}
    waterfall_title {Spectrogramme | TDSO}
    waterfall_note {Historique spectral · fréquence de 0 à Fs/2 · amplitude relative (dB)}
    waterfall_pause {Mettre en pause}
    waterfall_continue {Reprendre}
    waterfall_clear {Effacer l’historique}
    waterfall_frames {%d lignes · dernier intervalle : %d ms}
  }
  gl {
    waterfall_menu {Espectrograma…}
    waterfall_title {Espectrograma | TDSO}
    waterfall_note {Historial espectral · frecuencia de 0 a Fs/2 · amplitude relativa (dB)}
    waterfall_pause {Pausar historial}
    waterfall_continue {Continuar}
    waterfall_clear {Limpar historial}
    waterfall_frames {%d filas · último intervalo: %d ms}
  }
  it {
    waterfall_menu {Spettrogramma…}
    waterfall_title {Spettrogramma | TDSO}
    waterfall_note {Storico spettrale · frequenza 0–Fs/2 · ampiezza relativa (dB)}
    waterfall_pause {Metti in pausa}
    waterfall_continue {Riprendi}
    waterfall_clear {Cancella storico}
    waterfall_frames {%d righe · ultimo intervallo: %d ms}
  }
  ja {
    waterfall_menu {スペクトログラム…}
    waterfall_title {スペクトログラム | TDSO}
    waterfall_note {スペクトル履歴 · 周波数 0～Fs/2 · 相対振幅 (dB)}
    waterfall_pause {履歴を一時停止}
    waterfall_continue {再開}
    waterfall_clear {履歴を消去}
    waterfall_frames {%d 行 · 直近の間隔: %d ms}
  }
  pt {
    waterfall_menu {Espectrograma…}
    waterfall_title {Espectrograma | TDSO}
    waterfall_note {Histórico espectral · frequência 0–Fs/2 · amplitude relativa (dB)}
    waterfall_pause {Pausar histórico}
    waterfall_continue {Retomar}
    waterfall_clear {Limpar histórico}
    waterfall_frames {%d linhas · último intervalo: %d ms}
  }
  zh_cn {
    waterfall_menu {频谱瀑布图…}
    waterfall_title {频谱瀑布图 | TDSO}
    waterfall_note {频谱历史 · 频率 0–Fs/2 · 相对幅度 (dB)}
    waterfall_pause {暂停历史}
    waterfall_continue {继续}
    waterfall_clear {清除历史}
    waterfall_frames {%d 行 · 上次间隔: %d 毫秒}
  }
} {
  foreach {key value} $entries {
    ::msgcat::mcset $locale $key $value
  }
}
