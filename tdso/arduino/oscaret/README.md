# Trigger firmware de OSCARET

ATmega328P a 16 MHz y CA3306 de 6 bits. Cargar `oscaret.ino` junto con
`oscar.cpp`, `oscar.h` y `capture.h`. La aplicación requiere este firmware
para utilizar las nuevas capacidades de trigger.

## Protocolo

Comandos ASCII terminados en salto de línea, a 115200 baudios:

| Comando | Efecto |
| --- | --- |
| `l0` | Desactivar trigger; adquisición libre, estado inicial. |
| `l1` … `l63` | Activar trigger al nivel indicado del ADC de 6 bits. |
| `t1` | Flanco ascendente, predeterminado. No activa el trigger. |
| `t0` | Flanco descendente. No activa el trigger. |
| `f0` … `f7` | Seleccionar la frecuencia solicitada, como antes. |
| `s0/s1`, `x0/x1`, `a0/a1` | Sensibilidad y acoplamiento, como antes. |

Los niveles o flancos mal formados se ignoran. `l32` corresponde aproximadamente
al nivel 128 de la GUI. El driver convierte los niveles 0…255 a 0…63 redondeando
al código más cercano; los niveles positivos se limitan a 1…63 para reservar
el cero a la desactivación. La resolución sigue siendo de cuatro unidades de
la GUI por código del ADC. Un flanco descendente desde un valor superior a 63
no puede existir: `l63` con `t0` permanece esperando hasta recibir un comando.

La trama mantiene la cabecera `A5 5A C3 3C` y 1024 bytes de muestras 0…63.
Con trigger, la muestra 0 es la inmediatamente anterior al cruce y la muestra
1 alcanza o supera el nivel en subida, o lo alcanza o baja de él en bajada.
Las 1022 muestras restantes mantienen exactamente el mismo intervalo.
No se transmiten capturas sin cruce ni capturas parciales.

## Frecuencia y tiempos

| Modo | Trigger desactivado | Trigger activado |
| --- | --- | --- |
| f0 | 5,333 Msps | 1 Msps |
| f1 | 2 Msps | 1 Msps |
| f2 | 1 Msps | 1 Msps |
| f3 | 500 ksps | 500 ksps |
| f4 | 250 ksps | 250 ksps |
| f5 | 125 ksps | 125 ksps |
| f6 | 50 ksps | 50 ksps |
| f7 | 25 ksps | 25 ksps |

El firmware limita tanto el reloj del CA3306 como las lecturas del puerto.
Conserva el modo solicitado y lo recupera al recibir `l0`. El driver informa
de la frecuencia efectiva y el controlador actualiza la escala temporal;
el selector conserva la base solicitada.

`capture.h` equilibra los caminos del ensamblador: 16, 32, 64, 128, 320 o
640 ciclos entre lecturas, incluido el cruce. La recepción UART cancela la
espera o captura en curso y permite procesar cambios de configuración sin
necesitar una señal. La ISR serie recibe el byte cuando se restaura SREG.
Durante la transmisión se conserva el comportamiento serie de Arduino.

El modo libre rápido lee ahora 1024 muestras reales a tres ciclos por muestra
y elimina los bits ajenos al ADC después de capturar. El modo libre de
250 ksps utiliza 64 ciclos; anteriormente el retardo producía 62 ciclos.
La función rápida lleva `noinline`: GCC no cuenta correctamente la expansión
de `.rept 1024` al calcular los saltos del llamador si LTO inserta el bloque
en él. Mantenerla separada evita el error de enlace `R_AVR_13_PCREL` sin
alterar el intervalo entre muestras.

La integración mantiene la Factory y usa las capacidades del driver. Normal
y Single con posición de trigger cero utilizan firmware; Auto, pretrigger
distinto de cero y espectro siguen la política de OSCAR y desactivan el trigger
firmware. Single y rearme se gestionan en el controlador de la aplicación.

## Verificación

Desde la raíz del proyecto, con el core Arduino AVR, Tcl y Node instalados:

```powershell
./tests/build_oscaret.ps1
node tests/oscaret_capture_cycles.cjs "$env:TEMP/oscaret-trigger-build/oscaret.disassembly.txt"
tclsh tests/oscaret_trigger.test
tclsh tests/oscar_trigger.test
tclsh tests/signal_pipeline.test
```

El script de compilación activa LTO, como Arduino AVR. Para comprobar también
la variante sin LTO, utilizar `./tests/build_oscaret.ps1 -NoLto`.

El script de ciclos ejecuta las instrucciones del ELF desensamblado y verifica
los intervalos, los dos flancos, la igualdad al nivel, la ausencia de cruce,
la cancelación por UART y las ocho velocidades libres. La referencia de
instrucciones es el [manual AVR de Microchip](https://ww1.microchip.com/downloads/en/DeviceDoc/AVR-InstructionSet-Manual-DS40002198.pdf).

Estas pruebas no sustituyen la comprobación física del CA3306: verificar con
una señal conocida la fase del reloj, la estabilidad de los datos del puerto
y los flancos en ambos sentidos. No se ha cargado el firmware en una placa
durante esta implementación.
