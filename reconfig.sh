#!/bin/bash

chaine_abeille='//192.168.0.2/abeille /mnt/abeille cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0'
chaine_baobab='//192.168.0.2/baobab /mnt/baobab cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0'

#Création de l'utilisateur stagiaire avec son mot de passe
function user_add
{
sudo useradd stagiaire -m ; echo -e "stage\nstage" | sudo passwd stagiaire
sudo mkdir /home/stagiaire/Bureau
sudo chown -R stagiaire:stagiaire /home/stagiaire/Bureau
}

#Suppression de l'utilisateur stagiaire avec tous ses répetoires
function user_del
{
sudo userdel -r -f stagiaire
}

#Changement du nom de la machine
function chg_hostname
{
newname=$(date +%s | cut -c5-10)
sudo hostnamectl set-hostname "PC-$newname"
sudo hostnamectl
}


function salle_rep
{
# verifie si l'ip du poste est 192.168.100.X ou # 192.168.101.X
# et on monte le lecteur partagé en fonction de la salle Abeille ou Baobab
ip=$(sudo ifconfig enp0s3 | grep 'inet 192.168.' | awk '{print $2}' | cut -c9-11)
	if [ $ip = 100 ] ; then
	echo "c'est un PC de la salle ABEILLE"
	#on test si cela est déja fait sur le poste Abeille
	test_chaine=$(sudo grep "//192.168.0.2/abeille /mnt/abeille cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0" /etc/fstab)
		if [ "$chaine_abeille" = "$test_chaine" ] ; then
		echo "Le fichier fstab est déjà configuré !"
		else 
		echo "Paramètrage du fichier fstab "
		sudo bash -c 'echo "# Lecteur réseau : " >>/etc/fstab'
		sudo bash -c 'echo "//192.168.0.2/abeille /mnt/abeille cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0" >>/etc/fstab'
		sudo mkdir /mnt/abeille
		sudo mount -a
		fi
	elif [ $ip = 101 ] ; then
	echo "c'est un PC de la salle BAOBAB"
	#on test si cela est déja fait sur le poste Baobab
	test_chaine=$(sudo grep "//192.168.0.2/baobab /mnt/baobab cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0" /etc/fstab)
		if [ "$chaine_baobab" = "$test_chaine" ] ; then
		echo "Le fichier fstab est déjà configuré !"
		else 
		echo "Paramètrage du fichier fstab "
		sudo bash -c 'echo "# Lecteur réseau : " >>/etc/fstab'
		sudo bash -c 'echo "//192.168.0.2/baobab /mnt/baobab cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0" >>/etc/fstab'
		sudo mkdir /mnt/baobab
		sudo mount -a
		fi
	fi
}
# Création du raccroucis Abeille ou Baobab sur le bureau du stagiaire
function raccourcis
{
ip=$(sudo ifconfig enp0s3 | grep 'inet 192.168.' | awk '{print $2}' | cut -c9-11)
	if [ $ip = 100 ] ; then
	sudo ln -s /mnt/abeille /home/stagiaire/Bureau/
	echo "Raccourcis Bureau du dossier ABEILLE créé !"
	elif [ $ip = 101 ] ; then
	sudo ln -s /mnt/baobab /home/stagiaire/Bureau/
	echo "Raccourcis Bureau du dossier BAOBAB créé !"
	fi
}

echo "Quel est votre choix ?"
echo
echo "1) Installation de openssh-server "
echo "2) Installation de la clé publique du <<serveur-routeur>> "
echo "3) Ajouter l'utilisateur stagiaire "
echo "4) Supprimer l'utilisateur Stagiaire "
echo "5) Changement du NOM de le machine "
echo "6) Paramétrage du partage de dossier Abeille ou Baobab "
echo "7) Raccourcis sur le burau du stagiaire Abeille ou Baobab "
echo "8) Script Automatique étape 4/5/3/6/7"
echo "9) Quitter"
echo

read choix

case $choix in
	1)
	sudo apt-get install openssh-server
	;;
	2)
	mkdir -p ~/.ssh
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIlWbDa6an5Fqd89lNJBGRChTgwE9sq1yPAceudmTEcnEGcG1RnWjvZhzAHDeeITHupBXiA2CONT7OJc4yLPZ29rOIQXB+Ee3tI+HkezoqbPzPM0Y5z3fnLS9U+1/n3YpWdiyq4j0mFTvQfwbbH/adrNh216qefI6MeOm10v1hrWJg09RdcOJ7l9LXnWF2RppuDuccR9uuIQ/ouiNDlrJlnr3auyUDoYMhZv4AB01RcG5PfPtQudghAbxr9FbtZp+C5m3nMwGDucLMXz/x6RQLQOtWbYFhnnB80yOoou61/ayFSODBQqjU2fGncwRXUSiQZv1VhzT0pFlUsbEqSk1N root@debian-server" >> ~/.ssh/authorized_keys
	chmod -R go= ~/.ssh
	chown -R allouis:allouis ~/.ssh
	;;
	3)
	user_add
	;;
	4)
	user_del
	;;
	5)
	chg_hostname
	;;
	6)
	salle_rep
	;;
	7)
	raccourcis
	;;
	8)
	user_del
	chg_hostname
	user_add
	salle_rep
	raccourcis
	;;
	9)
	exit
	;;
esac
