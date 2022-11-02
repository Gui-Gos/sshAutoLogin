#!/bin/bash
# Author   :    AlicFeng & GuiGos
# Email    :    a@samego.com / guillaue@guigos.com
# Github   :    https://github.com/Gui-Gos/sshAutoLogin

# set color variables for printf or echo
# example 'printf "${Green}"$VARIABLE" or text${ResetColor}\n"'
Black="\e[0;30m"
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
Blue="\e[0;34m"
Purple="\e[0;35m"
Cyan="\e[0;36m"
White="\e[0;37m"
Grey="\e[0;39m"
ResetColor="\e[0m"

server_list=()
Config_Dir=~/.ssha
# load include server list configure
if [ $Config_Dir ]; then
	# Determine whether the configuration folder exists
	if [ -d $Config_Dir ];then
		# Traversing each configuration
		for config_file in $Config_Dir/*;do 
			if [ "${config_file##*.}"x = "ini"x ]||[ "${config_file##*.}"x = "conf"x ];then
    				while read line_configure;do
                        eval $line_configure
					done < $config_file
                    server_list[${#server_list[*]}]="${Index} ${Name} ${Host} ${Port} ${User} ${PasswordOrKey}"
			else
				printf "your server configuration files are not in the correct format (.ini/.conf)" && exit 1
			fi
		done
	else
		printf  "Config_Dir nothing configure files" && exit 1
	fi
else
	printf "Please setting Config_Dir \nmkdir ~/.ssha" && exit 1
fi

# server length
server_list_length=${#server_list[*]}

# deleted folder
DeletedFolder=~/.ssha/.deleted
if [ -d $DeletedFolder ];then
    # re order and rename the servers list
    incr=0
        for ((i=0;i<${server_list_length};i++));do
        servers=(${server_list[$i]})
        serverIndex=$(($i+1))
        rm ~/.ssha/$incr*
        printf "Index=$incr\nName=${servers[1]}\nHost=${servers[2]}\nPort=${servers[3]}\nUser=${servers[4]}\nPasswordOrKey=${servers[5]}" > ~/.ssha/"$incr"_${servers[1]}.ini
        incr=$((incr + 1))
        done
    rmdir $DeletedFolder
fi


# list server
function list() {
    printf "\n${Blue}Index\tDescription\tHost\tPort\tUsername\tPassword|SecretKeyFile${ResetColor}\n"
    for ((i=0;i<${server_list_length};i++));do
        servers=(${server_list[$i]})
        serverIndex=$(($i+1))
        printf "${servers[0]}\t${servers[1]}\t${servers[2]}\t${servers[3]}\t${servers[4]}\t${servers[5]}" | toilet -f term -F border -t
    done
    exit 0
}

function usage() {
printf "\n${Red}USAGE:${ResetColor}\n"
printf "${Blue}ssha${ResetColor} [${Blue}-h${ResetColor}] [${Green}-l${ResetColor}] [${Green}-c${ResetColor}] [${Green}-d${ResetColor}] [${Green}-s <server alias>${ResetColor}]\n"
    exit 0
}

function login() {
    server=(${server_list[$1]})
    v5NZ8jBr2HoQYD=${server[5]}
    zodVApcRdLi4Kz=$(printf '%s' "$v5NZ8jBr2HoQYD" | base64 --decode)
    printf "${Blue}$USER${ResetColor} ${Green}logging${ResetColor} into the${Yellow}【${server[1]}】${ResetColor}server" | toilet -f term -F border
	command="
        expect {
                \"*assword\" {set timeout 6000; send \"$zodVApcRdLi4Kz\n\"; exp_continue ; sleep 3; }
                \"*passphrase\" {set timeout 6000; send \"$zodVApcRdLi4Kz\r\n\"; exp_continue ; sleep 3; }
                \"yes/no\" {send \"yes\n\"; exp_continue;}
                \"Last*\" {  send_user \"\nsuccessfully logined 【${server[1]}】\n\";}
        }
       interact
    ";
   pem=$zodVApcRdLi4Kz
   if [ -f "$pem" ]
   then
	expect -c "
		spawn ssh -p ${server[2]} -i $zodVApcRdLi4Kz ${server[3]}@${server[2]}
		${command}
	"
   else
	expect -c "
		spawn ssh -p ${server[3]} ${server[4]}@${server[2]}
		${command}
	"
   fi
    printf "${Blue}$USER${ResetColor} ${Red}logged out${ResetColor} the${Yellow}【${server[1]}】${ResetColor}server" | toilet -f term -F border
}

function create() {
printf "\n${Blue}Creating a new server:${ResetColor}\n"
#number=$(ls ~/.ssha | wc -l | tr -d '[:blank:]')
printf "${Yellow}Please type the '${Blue}Description${Yellow}' of this server:${ResetColor}\n"
read -r name
printf "${Yellow}Please type the '${Blue}Hostname|IP${Yellow}' of this server:${ResetColor}\n"
read -r host
printf "${Yellow}Please type the '${Blue}Port${Yellow}' of this server:${ResetColor}\n"
read -r port
printf "${Yellow}Please type the '${Blue}Username${Yellow}' of this server:${ResetColor}\n"
read -r user
printf "${Yellow}Please type the '${Blue}Password|SecretKeyFile${Yellow}' of this server:${ResetColor}\n"
read -r pass && v5NZ8jBr2HoQYD=$(printf '%s' "$pass" | base64) && unset pass

# Print all data for verification #
printf "\n${Blue}Please check the following informations:${ResetColor}\n"
printf "${Yellow}Name of server:${Green} $name ${ResetColor}\n"
printf "${Yellow}Hostname or IP:${Green} $host ${ResetColor}\n"
printf "${Yellow}Port:${Green} $port ${ResetColor}\n"
printf "${Yellow}Username:${Green} $user ${ResetColor}\n"
printf "${Yellow}Password/Key (hidden):${Green} $pass ${ResetColor}\n"

# Informations is correct ?! #
printf "\n${Blue}Informations is correct ?! (Y/N)${ResetColor}\n"
read info
if [[ "$info" =~ ^[yYoO] ]]; then
	printf "\n${Green}'OK' ${Blue}Added server $name to the list${ResetColor}\n"
	printf "Index=$server_list_length\nName=$name\nHost=$host\nPort=$port\nUser=$user\nPasswordOrKey=$v5NZ8jBr2HoQYD\n" | tee -a ~/.ssha/"$server_list_length"_"$name".conf
    printf "\n${Blue}Congratulations the server${Green} '"$name"' ${Blue}is well registered. ${ResetColor}Here is the current list of your servers:\n" | toilet -f term -F border
    ssha -l
    exit 0
elif [[ "$info" =~ ^[nN] ]]; then
	printf "\n${Green}'OK' ${Blue}Go to restart creation of server${ResetColor}\n"
	ssha -c
		else
            printf "\n${Red}'INPUT ERROR' ${Blue}Exit${ResetColor}\n"
	        exit 1
fi
}

function delete() {
# see list of servers
ssha -l
#number=$(ls ~/.ssha | wc -l | tr -d '[:blank:]')
printf "\n${Blue}Which server do you want to delete ? ${Yellow}(Enter the number)${ResetColor}\n"
read -r srvnb
if [[ ! $srvnb -lt $server_list_length ]]; then
printf "\n${Red}'INPUT ERROR' ${Blue}Exit${ResetColor}\n"
exit 1
else
printf "\n${Blue}You have selected the server ${Green}$srvnb${Blue}. Do you really want to delete this server ? (Y/N)${ResetColor}\n"
    read info
    if [[ "$info" =~ ^[yYoO] ]]; then
    printf "\n${Green}'OK' ${Blue}Delete server number ${Green}$srvnb${ResetColor}\n"
    rm ~/.ssha/$srvnb*
    mkdir $DeletedFolder
    exit 0
    elif [[ "$info" =~ ^[nN] ]]; then
        printf "\n${Green}'OK' ${Blue}Go restart delete server${ResetColor}\n"
        ssha -d
            else
                printf "\n${Red}'INPUT ERROR' ${Blue}Exit${ResetColor}\n"
                exit 1
    fi
fi
}

function test() {
echo ${server_list[@]}
echo "############################"
echo ${#server_list[*]}
echo "############################"
echo "$server_list_length"
#echo ${server_list[1]}
#printf "%s\n" "${server_list[@]}" > ~/.ssha/file.txt

    incr=0
    for ((i=0;i<${server_list_length};i++));do
        servers=(${server_list[$i]})
        serverIndex=$(($i+1))
        rm ~/.ssha/$incr*
        printf "Index=$incr\nName=${servers[1]}\nHost=${servers[2]}\nPort=${servers[3]}\nUser=${servers[4]}\nPasswordOrKey=${servers[5]}" > ~/.ssha/"$incr"_${servers[1]}.ini
        incr=$((incr + 1))
    done
    exit 0

}

while getopts hlcdts: ARGS
do
case $ARGS in
    h)
        usage
        ;;
    l)
        list
        ;;
    c)
        create
        ;;
    d)
        delete
        ;;
    t)
        test
        ;;
    s)
        login $OPTARG
        ;;
    *)  
        usage
        ;;
esac
done

