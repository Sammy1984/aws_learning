#!/bin/bash

while [ -n "$1" ];do
	case "$1" in
		--region) region="$2"
			shift
			if grep -x $region region.conf
			then
				echo "Регион $region присутствует в списке"
			else
				echo "$region не найден"
				break
			fi ;;
		--os) os="$2"
			shift
			case "$os" in
				ubuntu) os="ubuntu_111"
					echo $os ;;
				al2) os="al2_111"

					echo $os ;;
				*) echo "$os не найдена"
				break ;;
			esac ;;

		*) 
		 echo "Нет такого параметра - $1"
		 break ;;
	esac
	shift
done

