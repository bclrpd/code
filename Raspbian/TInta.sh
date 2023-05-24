#!/bin/bash

function ventana_principal() {
  resultado=$(yad --form \
	--center \
    --title="Ventana Principal" \
    --text="<span foreground='blue'><b><big><big>DENSIDAD DE IMPRESION</big></big></b></span>" \ \
    --text-align=center \
    --width=200 \
    --height=100 \
    --button="<span foreground='gray'><b><big>Claro</big></b></span>":1 \
    --button="<span foreground='darkslategray'><b><big>Normal</big></b></span>":2 \
    --button="<span foreground='black'><b><big>Oscuro</big></b></span>":3 \
    --button="<span foreground='red'><b><big>CERRAR</big></b></span>":0)
    
  boton=$?
  case $boton in
	0)
      exit 0
      ;;
    1)
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x00\xfd\x00\x00\x93' > /dev/usb/lp0  #Claro
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x00\xfd\x00\x00\x93' > /dev/ttyUSB0  #Claro
		echo -e '\x1d\x40\x12\x54' > /dev/ttyUSB0  #printTest
		
		ventana_principal
      ;;
    2)
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x01\xfd\x00\x00\x92' > /dev/usb/lp0  #Normal
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x01\xfd\x00\x00\x92' > /dev/ttyUSB0  #Normal
		echo -e '\x1d\x40\x12\x54' > /dev/ttyUSB0  #printTest
		
		ventana_principal
      ;;
    3)
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x02\xfd\x00\x00\x91' > /dev/usb/lp0  #Oscuro
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x02\xfd\x00\x00\x91' > /dev/ttyUSB0  #Oscuro
		echo -e '\x1d\x40\x12\x54' > /dev/ttyUSB0  #printTest
		
		
		
		ventana_principal
      ;;
    *)
      echo "La ventana secundaria se ha cerrado sin seleccionar ningún botón."
      ;;
  esac
}

ventana_principal









#------------------------------------------------------------
#Sin Uso por el momento


function ventana_secundaria_1() {
  resultado=$(yad --form \
    --title="Ventana Secundaria" \
    --center \
    --width=200 \
    --height=100 \
    --text="<span foreground='blue'><b><big><big>2Connect</big></big></b></span>" \ \
    --text-align=center \
    --button="Claro":1 \
    --button="Normal":2 \
    --button="Oscuro":3 \
    --button="Atras":0)

  boton=$?

  case $boton in
	0)
      ventana_principal
      ;;
    1)
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x00\xfd\x00\x00\x93' > /dev/usb/lp0  #Claro
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x00\xfd\x00\x00\x93' > /dev/ttyUSB0  #Claro
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/ttyUSB0  #printTest
		
		ventana_secundaria_1
      ;;
    2)
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x01\xfd\x00\x00\x92' > /dev/usb/lp0  #Normal
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x01\xfd\x00\x00\x92' > /dev/ttyUSB0  #Normal
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/ttyUSB0  #printTest
		
		ventana_secundaria_1
      ;;
    3)
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x02\xfd\x00\x00\x91' > /dev/usb/lp0  #Oscuro
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		
		echo -e '\x1f\x28\x0f\x0c\x00\x1f\x73\x02\x00\x00\x00\x00\x02\xfd\x00\x00\x91' > /dev/ttyUSB0  #Oscuro
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/ttyUSB0  #printTest
		
		
		
		ventana_secundaria_1
      ;;
    *)
      echo "La ventana secundaria se ha cerrado sin seleccionar ningún botón."
      ;;
  esac
}


function ventana_secundaria_2() {
  resultado=$(yad --form \
    --title="Ventana Secundaria" \
    --center \
    --width=200 \
    --height=100 \
    --text="<span foreground='blue'><b><big><big>AOKIA</big></big></b></span>" \ \
    --text-align=center \
    --button="Claro":1 \
    --button="Oscuro":2 \
    --button="Atras":0)

  boton=$?

  case $boton in
	0)
      ventana_principal
      ;;
    1)
		echo -e '' > /dev/usb/lp0  #
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		ventana_secundaria_2
      ;;
    2)
		echo -e '' > /dev/usb/lp0  #
		sleep 1
		echo -e '\x1d\x40\x12\x54' > /dev/usb/lp0  #printTest
		ventana_secundaria_2
      ;;
    *)
      echo "La ventana secundaria 2 se ha cerrado sin seleccionar ningún botón."
      ;;
  esac
}


