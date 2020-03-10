######################################################################################
#
#   La fonction "tunssh" permet de transférer le port d'un réseau distant,
#		vers le port d'un réseau local à travers une connexion SSH.
# 	Elle peut être appeler autant de fois que l'on souhaite (1 fois par port)
# 	Pour stopper le tunneling faire : tunssh --kill-all
#
######################################################################################
function tunssh(){ 
	
	######################################################################################
	#
	#           Initialisation des variables
	#
	######################################################################################
	
	# Verbose mode.
	verbose_mode=0
	
	# SSH Host.
	ssh_host=''

	# SSH User.
	ssh_user=''

	# SSH Port.
	ssh_port=''

	# Remote tunnel host.
	remote_tunnel_host=''

	# Local tunnel port.
	local_tunnel_port=''

	# Remote tunnel port.
	remote_tunnel_port=''
	
	######################################################################################
	#
	#           Gestion de l'aide via l'option -h
	#
	######################################################################################
	
	# Si le script est appelé avec loption -h, le script devra afficher un message sur la sortie derreur indiquant la liste des arguments quil attend.
	# getops ?
	usage="usage: tunssh [-h ssh_host] [-u ssh_user] [-p ssh_port] [-rth remote_tunnel_host] [-rtp remote_tunnel_port] [-ltp local_tunnel_port] [-v] [-ka|--kill-all]"
	
	# Pour chaque options listé 
	while test ${#} -gt 0
	do
				
	  # Switch args.
	  case $1 in
		  # SSH Host.
			-h)
				shift
				ssh_host=$1
			;;
			# SSH User.
			-u)
				shift
				ssh_user=$1
			;;
			# SSH Port.
			-p)
				shift
				ssh_port=$1
			;;
			# Remote tunnel host.
			-rth)
				shift
				remote_tunnel_host=$1
			;;
			# Remote tunnel port.
			-rtp)
				shift
				remote_tunnel_port=$1
			;;
			# Local tunnel port.
			-ltp)
				shift
				local_tunnel_port=$1
			;;
			# Kill all ssh command.
			-ka|--kill-all)
				echo "KILL ALL"
				pkill ssh
				return -1
			;;
			# Verbose.
			-v)
				verbose_mode=1
				echo "Mode verbose activé."
			;;
			#Usage.
			*)   
				if [[ $1 ]]
				then 
					echo "$1 n'est pas une option valide."
					echo "$usage"
					return -1 
				fi
			;;
		esac
		
		# Décallage des arguments.
		shift
		
	done


	######################################################################################
	#
	#           Gestion des valeurs par défaut
	#
	######################################################################################
	
	# Host SSH :
	if [[ ! $ssh_host ]]
	then
		echo -n "Entrer l'IP ou le nom de domaine du serveur auquel vous souhaitez vous connecter [localhost] : " 
		read ssh_host
		if [[ ! $ssh_host ]]
		then
			ssh_host='localhost'
		fi
	fi
	
	# User SSH :
	if [[ ! $ssh_user ]]
	then
		echo -n "Entrer le nom d'un l'utilisateur autorisé à se connecter en SSH à la machine distante [$USER] : " 
		read ssh_user
		if [[ ! $ssh_user ]]
		then
			ssh_user="$USER"
		fi
	fi
	
	# Port SSH :
	if [[ ! $ssh_port ]]
	then
		echo -n "Entrer le port d'écoute du serveur SSH de la machine distante [22] : " 
		read ssh_port
		if [[ ! $ssh_port ]]
		then
			ssh_port='22'
		fi
	fi
	
	# Local tunnel host :
	if [[ ! $remote_tunnel_host ]]
	then
		echo -n "Entrer l'IP ou le nom de domaine local de la machine sur le réseau distant depuis laquelle vous souhaitez ouvir un tunnel [localhost] : " 
		read remote_tunnel_host
		if [[ ! $remote_tunnel_host ]]
		then
			remote_tunnel_host='localhost'
		fi
	fi
	
	# Remote tunnel port :
	if [[ ! $remote_tunnel_port ]]
	then
		echo -n "Entrer le numéro de port distant que vous souhaitez transférer en local [80] : " 
		read remote_tunnel_port
		if [[ ! $remote_tunnel_port ]]
		then
			remote_tunnel_port='80'
		fi
	fi
	
	# Local tunnel port :
	if [[ ! $local_tunnel_port ]]
	then
		echo -n "Entrer le numéro de port local sur lequel vous souhaitez transférer le port distant [8080] : " 
		read local_tunnel_port
		if [[ ! $local_tunnel_port ]]
		then
			local_tunnel_port='8080'
		fi
	fi
	
	######################################################################################
	#
	#           Affichage des valeurs
	#
	######################################################################################
	
	# Si verbose mode actif.
	if [[ $verbose_mode == 1 ]]
	then
		# Affichage des valeurs de la commande SSH.
		echo "SSH host = $ssh_host"
		echo "SSH user = $ssh_user"
		echo "SSH port = $ssh_port"
		echo "Tunnel remote host = $remote_tunnel_host"
		echo "Tunnel remote port = $remote_tunnel_port"
		echo "Tunnel local port = $local_tunnel_port"
	fi

	
	######################################################################################
	#
	#           Tunnel SSH
	#
	######################################################################################
	
	# Création de la commande de tunnel SSH. (-fN = -f + -N)
	# -f : Go in background mode after connexion.
	# -N : No command to lauch in background mode.
	sshtun="ssh -fN -L $local_tunnel_port:$remote_tunnel_host:$remote_tunnel_port $ssh_user@$ssh_host -p $ssh_port"
	
	# Si verbose mode actif.
	if [[ $verbose_mode == 1 ]]
	then 
		# Affichage de la commande SSH.
		echo "Lancement de la commande SSH :"
		echo $sshtun
	fi
	
	# Initiation du tunnel SSH en mode background.
	eval $sshtun
	
	# Retour
	return -1
	
}
