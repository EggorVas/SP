#!/bin/bash

echo "
Привет! 
Меня зовут \"Repository connector\" и я буду твоим помошником с отображением настроенных репозиториев и с созданием нового.
Мой создатель (Васильев Егор, студент группы 739-1) позаботился о том, чтобы пользователям было удобно.

Кажется, тебя зовут... вспомнил! $USER! Приступим к работе?

"

while [ 1 ]; do
	echo "Здесь представлен список подключенных репозиториев:"
	for APT in `find /etc/apt/ -name \*.list`; do
		num=0
		grep "^deb" $APT | while read ENTRY ; do
			num=$(( $num + 1 ))
			NAME=`echo $ENTRY | cut -d " " -f3`
			HOST=`echo $ENTRY | cut -d/ -f3`
			if [ "ppa.launchpad.net" = "$HOST" ] || [ "ppa.launchpadcontent.net" = "$HOST" ]; then
				USER=`echo $ENTRY | cut -d/ -f4`
				PPA=`echo $ENTRY | cut -d/ -f5`
				echo $num. \'$NAME\' - PPA:$USER/$PPA
			else
				echo $num. \'$NAME\'
			fi
		done
	done
	
	echo -e "\nТакже имеются настроенные, но отключенные репозитории:"
	for APT in `find /etc/apt/ -name \*.list`; do
		num=0
		grep "^# deb" $APT | while read ENTRY ; do
			num=$(( $num + 1 ))
			NAME=`echo $ENTRY | cut -d " " -f4`
			HOST=`echo $ENTRY | cut -d/ -f3`
			if [ "ppa.launchpad.net" = "$HOST" ] || [ "ppa.launchpadcontent.net" = "$HOST" ]; then
				USER=`echo $ENTRY | cut -d/ -f4`
				PPA=`echo $ENTRY | cut -d/ -f5`
				echo $num. \'$NAME\' - PPA:$USER/$PPA
			else
				echo $num. \'$NAME\'
			fi
		done
	done
	
	
	echo -e "\n\nЖелаете проверить какой-нибудь репозиторий?\nВведите его название:"
	read INPUTNAME
	echo

	echo $INPUTNAME | for APT in `find /etc/apt/ -name \*.list`; do
		grep "^deb" $APT | while read ENTRY ; do
			NAME=`echo $ENTRY | cut -d " " -f3`
			PPA=`echo $ENTRY | cut -d/ -f5`
			if [ "$INPUTNAME" = "$NAME" ] || [ "$INPUTNAME" = "$PPA" ]; then
				echo $ENTRY
				break
			fi
		done >> tmp.txt
	done
	

	num=`wc -l < tmp.txt`
	echo -e "Было найдено $num объекта(ов)\n"
	
	if [ $num -eq 0 ]; then
	
		echo -e "Желаете добавить репозиторий? (y/n)"
		read INPUT
		case $INPUT in
			y|Y|н|Н)
			echo -e "\nВы хотите добавить пользовательский репозиторий PPA:user/ppa-name? (y/n)"
			read INPUT
			case $INPUT in
				y|Y|н|Н)
				echo -e "\nВведите строку записи: ПОЛЬЗОВАТЕЛЬ/НАЗВАНИЕ"
				echo -e "Пример: jonathonf/ffmpeg-4\n"
				read INPUT
				echo -ne '\n' | add-apt-repository ppa:$INPUT
				;;
				
				n|N|т|Т)
				echo -e "\nВведите полную строку записи репозитория: deb URL НАЗВАНИЕ КАТЕГОРИЯ"
				echo -e "Пример: deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse\n"
				read INPUT
				echo -ne '\n' | add-apt-repository $INPUT
				;;
				
				*)
				echo -e "\nНе понимаю, что вы ввели, но пусть будет 'Нет'"
				echo "Введите полную строку записи репозитория: deb URL НАЗВАНИЕ КАТЕГОРИЯ"
				echo -e "Пример: deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse\n"
				read INPUT
				echo -ne '\n' | add-apt-repository $INPUT
				;;
			esac
			;;
			
			n|N|т|Т)
			echo
			;;
			
			*)
			echo "Не понимаю, что вы ввели, но пусть будет 'Нет'"
			;;
		esac
		
	else
	
		cat tmp.txt | while read ENTRY ; do
			echo "Название: `echo $ENTRY | cut -d ' ' -f3`"
			echo "Сервер: `echo $ENTRY | cut -d/ -f3`"
			echo "Полный URL: `echo $ENTRY | cut -d " " -f2`"
			if [ "`echo $ENTRY | cut -d " " -f1`" = "deb" ]; then
				echo "Репозиторий содержит deb-пакеты"
			else
				echo "Репозиторий содержит исходные пакеты"
			fi
			echo "Категория: `echo $ENTRY | cut -d " " -f4,5,6,7`"
			
			HOST=`echo $ENTRY | cut -d/ -f3`
			if [ "ppa.launchpad.net" = "$HOST" ] || [ "ppa.launchpadcontent.net" = "$HOST" ]; then
				USER=`echo $ENTRY | cut -d/ -f4`
				PPA=`echo $ENTRY | cut -d/ -f5`
				echo "Репозиторий является пользовательским - PPA: $USER/$PPA"
			fi
			echo
		done
		
	fi
	
	rm tmp.txt
	echo -e "\n\n"
	
	
	echo -e "\nХотите запустить программу заново? (y/n)"
	read INPUT
	case $INPUT in
			y|Y|н|Н)
			echo -e "\n\n"
			;;
			
			n|N|т|Т)
			break
			;;
			
			*)
			echo "Не понимаю, что вы ввели, но пусть будет 'Нет'"
			break
			;;
		esac
done

echo "Программа заканчивает свою работу: процесс самоуничтожения за... вер... шооооооо..."