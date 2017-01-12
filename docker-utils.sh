dockerip()
{
    docker inspect "$1" | jq -r ".[0].NetworkSettings.Networks.bridge.IPAddress"
}

dockerips()
{
	for container in `docker ps --format "{{.Names}}"`; do
		docker inspect "$container" | jq -r ".[0].NetworkSettings.Networks.bridge.IPAddress"|tr '\n' ' '
		echo " $container"
	done
}

dockerhosts()
{
	searchstring="# DOCKERHOSTS"
	filehost="/etc/hosts";
	if [ ! -f $filehost ]; then
		touch $filehost
	fi
	hosts=$(<$filehost)
	if [[ $hosts == *$searchstring* ]]; then
  		newhosts=$(
  		printf "${hosts%$searchstring*}"
  		echo "# DOCKERHOSTS"
  		dockerips
  		)
	else
		newhosts=$(
			cat $filehost
			echo "# DOCKERHOSTS"
			dockerips
		)
	fi
	sudo sh -c "echo '$newhosts' > $filehost"
}