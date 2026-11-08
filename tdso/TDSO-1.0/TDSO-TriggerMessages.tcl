# Catálogo adicional del trigger, integrado en msgcat sin alterar los
# antiguos msgs/*.msg. Se ejecuta dentro de namespace eval OSCAR.
foreach {locale entries} {
  ca {
    trigger_mode {Mode} trigger_pretrigger {Predisparador (%) }
    trigger_auto {Automàtic} trigger_normal {Normal} trigger_single {Únic}
    trigger_arm {Rearmar}
    trigger_status_auto {Auto: lliure} trigger_status_wait {Esperant flanc}
    trigger_status_triggered {Flanc detectat} trigger_status_hold {Únic: retingut}
  }
  de {
    trigger_mode {Modus} trigger_pretrigger {Vortrigger (%) }
    trigger_auto {Auto} trigger_normal {Normal} trigger_single {Einzel}
    trigger_arm {Neu scharf schalten}
    trigger_status_auto {Auto: Freilauf} trigger_status_wait {Warte auf Flanke}
    trigger_status_triggered {Flanke erkannt} trigger_status_hold {Einzel: gehalten}
  }
  en {
    trigger_mode {Mode} trigger_pretrigger {Pretrigger (%) }
    trigger_auto {Auto} trigger_normal {Normal} trigger_single {Single}
    trigger_arm {Rearm}
    trigger_status_auto {Auto: free-run} trigger_status_wait {Waiting for edge}
    trigger_status_triggered {Edge detected} trigger_status_hold {Single: held}
  }
  es {
    trigger_mode {Modo} trigger_pretrigger {Pretrigger (%) }
    trigger_auto {Auto} trigger_normal {Normal} trigger_single {Single}
    trigger_arm {Rearmar}
    trigger_status_auto {Auto: libre} trigger_status_wait {Esperando flanco}
    trigger_status_triggered {Flanco detectado} trigger_status_hold {Single: retenido}
  }
  eu {
    trigger_mode {Modua} trigger_pretrigger {Aurredisparoa (%) }
    trigger_auto {Automatikoa} trigger_normal {Normala} trigger_single {Bakarra}
    trigger_arm {Berrarmatu}
    trigger_status_auto {Auto: askea} trigger_status_wait {Ertzaren zain}
    trigger_status_triggered {Ertza hauteman da} trigger_status_hold {Bakarra: eutsita}
  }
  fr {
    trigger_mode {Mode} trigger_pretrigger {Pré-déclenchement (%) }
    trigger_auto {Auto} trigger_normal {Normal} trigger_single {Unique}
    trigger_arm {Réarmer}
    trigger_status_auto {Auto : libre} trigger_status_wait {Attente du front}
    trigger_status_triggered {Front détecté} trigger_status_hold {Unique : figé}
  }
  gl {
    trigger_mode {Modo} trigger_pretrigger {Predisparo (%) }
    trigger_auto {Automático} trigger_normal {Normal} trigger_single {Único}
    trigger_arm {Rearmar}
    trigger_status_auto {Auto: libre} trigger_status_wait {Agardando flanco}
    trigger_status_triggered {Flanco detectado} trigger_status_hold {Único: retido}
  }
  it {
    trigger_mode {Modalità} trigger_pretrigger {Pre-trigger (%) }
    trigger_auto {Auto} trigger_normal {Normale} trigger_single {Singolo}
    trigger_arm {Riarmare}
    trigger_status_auto {Auto: libero} trigger_status_wait {In attesa del fronte}
    trigger_status_triggered {Fronte rilevato} trigger_status_hold {Singolo: bloccato}
  }
  ja {
    trigger_mode {モード} trigger_pretrigger {プリトリガー (%) }
    trigger_auto {自動} trigger_normal {ノーマル} trigger_single {シングル}
    trigger_arm {再アーム}
    trigger_status_auto {自動：フリーラン} trigger_status_wait {エッジ待機中}
    trigger_status_triggered {エッジ検出} trigger_status_hold {シングル：保持中}
  }
  pt {
    trigger_mode {Modo} trigger_pretrigger {Pré-disparo (%) }
    trigger_auto {Auto} trigger_normal {Normal} trigger_single {Único}
    trigger_arm {Rearmar}
    trigger_status_auto {Auto: livre} trigger_status_wait {À espera de flanco}
    trigger_status_triggered {Flanco detetado} trigger_status_hold {Único: retido}
  }
  zh_cn {
    trigger_mode {模式} trigger_pretrigger {预触发 (%) }
    trigger_auto {自动} trigger_normal {普通} trigger_single {单次}
    trigger_arm {重新触发}
    trigger_status_auto {自动：自由运行} trigger_status_wait {等待边沿}
    trigger_status_triggered {检测到边沿} trigger_status_hold {单次：保持}
  }
} {
  foreach {key value} $entries {
    ::msgcat::mcset $locale $key [string trim $value]
  }
}
