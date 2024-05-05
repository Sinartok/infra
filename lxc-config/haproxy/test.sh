#!/bin/bash
name=$(cat /srv/haproxy/listsrv.txt | cut -d " " -f2)

echo "Quel projet voulez vous supprimer ? : "
echo ""
n=1
for names in $name;
    do 
    echo "$n) $names"
    let "n++"
    done
echo ""
read choix

nline=$(wc -l < /srv/haproxy/listsrv.txt)
for ((n=1; n<=$nline; n++));
    do  
    if [ $choix = $n ];
        then
            web=$(sed -n "${n}p" /srv/haproxy/listsrv.txt | cut -d " " -f2)
            db=$(sed -n "${n}p" /srv/haproxy/listsrv.txt | cut -d " " -f2 | cut -d "-" -f2)

            lxc delete $web --force
            lxc delete db-$db --force
            lxc network delete net-$web
            lxc network delete net-db-$db
        sed -i "${n}d" /srv/haproxy/listsrv.txt
    fi
done

# Ajout de la config haproxy
if [ ! -d "/srv/haproxy/haproximite" ]; then
    mkdir "/srv/haproxy/haproximite"
fi
cp /srv/haproxy/haproxy.cfg /srv/haproxy/haproximite/haproxy.cfg


for line in $(cat /srv/haproxy/listsrv.txt | cut -d " " -f2);
    do
        ip=$(cat /srv/haproxy/listsrv.txt | grep $line | cut -d " " -f3)
        printf "server $line $ip check\n" >> "/srv/haproxy/haproximite/haproxy.cfg"
    done


echo " " >> "/srv/haproxy/haproximite/haproxy.cfg" 
sleep 5

# crÃ©ation du docker
docker container rm haproxy --force
sleep 5
docker run -itd --name haproxy -v "/srv/haproxy/haproximite:/etc/haproxy" haproximite
