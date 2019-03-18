#!/bin/bash
#PUERTOS CON SUS SERVICIOS MÁS COMUNES
#20:FTP-Data 	21:FTP 22:SSH	23:TELNET 	25:SMTP 	80:HTTP 
#143:IMAP	161:SNMP 	443:HTTPS 	445:MS-DS	465:SMTPS
#1080:PROXY	1433:MS SQL	3128:SQUID	3306:MYSQL	8080:Web_cache	

#REFERENCIA: http://web.mit.edu/rhel-doc/4/RH-DOCS/rhel-sg-es-4/ch-ports.html

#TIPO_COMUNICACION :	0 = TCṔ				1 = UDP
#HOST	:		0 = Se debe definir los host	1 = Sólo se escaneara un host
#PORT	:		0 = Deshabilitado		1 = Habilitado
#			INICIA DECLARACIÓN DE VARIABLES				#
DEFAULT_PORTS=(20 21 23 25 80 143 161 443 445 465 1080 1433 3128 3306 8080)
TIPO_COMUNICACION=0
#Se definen los valores del usuario (si especifican con getops)
PORT="N"
HOST="N"
#OPCIONES:
# -h HOST : Especifica un único host.
# -p PORT : Especifica un único puerto

function FUN_MODO_USO {
	echo "Hubo un error al ejecutar el script..."
	echo "Ejemplo de uso:	./script OPCIONES [VALORES]"
	echo "OPCIONES:"
	echo "		-h HOST : Especifica un único host."
	echo "		-p PORT : Especifica un único puerto."
	exit 1
}

function FUN_PROBAR_CONEXION {
	#Esta funcion intenta conectarse a un puerto atraves de una IP.
	ip=$1
	port=$2
	echo "		Probando $ip $port..."
	nc -zvn $ip $port
}

function FUN_HOST_MULTI_PORT  {
	#Prueba de un host especifico hacia varios puertos
	#ARG1	: Dirección IP de Host a revisar
	host=$1
	inicio=0
	fin=0
	puertos=()
	echo "Probando puertos del host: $host"
	echo "Se probarán los siguientes puertos: "
	echo "		${DEFAULT_PORTS[@]}"
	read -p "¿Desea ingresar nuevos valores? (s/N): " band
	if [ ${band^^} == 'S' ]; then
		read -p "¿Desea que sea por rango? (s/N): " band
		if [ ${band^^} == 'S' ]; then
			read -p "Valor inicial: " inicio
			read -p "Valor final: " fin
			puertos=( $(seq $inicio $fin) )
		else
			echo "Favor de indicar los puertos, presione 0 al terminar"
			puerto=1
			while [ $puerto -ne 0 ]; do
				read -p "Puerto: " puerto
				[[ puerto -ne 0 ]] && { puertos+=( $puerto ); }
			done
			
		fi
	else
		puertos=${DEFAULT_PORTS[@]}
	fi 
	for puerto in ${puertos[@]}; do
		FUN_PROBAR_CONEXION $host $puerto
	done
	exit 0
}

function FUN_PORT_MULTI_HOST {
	#Prueba de un puerto especifico hacia varios host
	#ARG1	: Puerto a probar.
	puerto=$1
	hosts=()
	echo "Probando un puerto especifico hacia varios host..."
	echo "# # # # # # # # # #"
	echo "		Nota de creador:"
	echo "	Segmento de red		Host"
	echo "	192.168.1		10"
	echo "	172.16			0.10"
	echo "# # # # # # # # # #"
	read -p "Ingrese el segmento de red (x.x.x): " seg_red
	read -p "¿Desea que sea que los host sean por rango? (s/N): " band
	if [ ${band^^} == 'S' ]; then
		read -p "Valor inicial: " inicio
		read -p "Valor final: " fin
		hosts=( $(seq $inicio $fin) )
	else
		echo "Favor de indicar la dirección de host, ecriba 'END' al terminar"
		host='START'
		while [ $host != 'END' ]; do
			read -p "host: " host
			[[ $host != 'END' ]] && { hosts+=( $host ); }
		done
	fi
	for host in ${hosts[@]};do
		FUN_PROBAR_CONEXION $seg_red.$host $puerto
	done
	exit 0
}

function FUN_MULTI_HOST_MULTI_PORT {
	#Prueba varios puertos de varios host
	echo "Iniciando prueba de varios puertos a varios host"
	echo "Próximamente...."
	exit 0
}
while getopts ":h:p:" OPT; do
	case $OPT in
		h)
			HOST=$OPTARG
			;;
		p)
			PORT=$OPTARG
			;;
		\?)
			echo "Opción invalida $OPTARG"
			FUN_MODO_USO			
			;;
		:)
			echo "Opción $OPTARG requiere un valor."
			FUN_MODO_USO
			;;
	esac
done
#Se especifico el host
if [ $HOST != 'N' ] && [ $PORT == 'N' ]; then
	FUN_HOST_MULTI_PORT $HOST
fi
#Se especifico el puerto
if [ $HOST == 'N' ] && [ $PORT != 'N' ]; then
	FUN_PORT_MULTI_HOST $PORT
fi
#Se especificaron host y puerto
if [ $HOST != 'N' ] && [ $PORT != 'N' ]; then
	FUN_MULTI_HOST_MULTI_PORT $HOST $PORT
fi
FUN_MODO_USO
