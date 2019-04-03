#!/bin/bash
#test
chaine_abeille='//192.168.0.2/abeille /mnt/abeille cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0'
chaine_baobab='//192.168.0.2/baobab /mnt/baobab cifs guest,_netdev,iocharset=utf8,uid=stagiaire 0 0'

#Création de l'utilisateur stagiaire avec son mot de passe
function user_add
{
sudo useradd stagiaire -m ; echo -e "stage\nstage" | sudo passwd stagiaire
sudo mkdir /home/stagiaire/Bureau
chown -R stagiaire:stagiaire /home/stagiaire/Bureau
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
ip=$(sudo ifconfig enp0s3 | grep 'inet 192.168.' | awk '{print $2}' | cut -c9-11)
	if [ $ip = 100 ] ; then
	echo "c'est un PC de la salle ABEILLE"
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
# Création du raccroucis sur le bureau du stagiaire
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
echo "1) Ajouter l'utilisateur stagiaire"
echo "2) Supprimer l'utilisateur Stagiaire"
echo "3) Changement du NOM"
echo "4) Paramétrage du partage de dossier"
echo "5) Raccourcis sur le burau Abeille ou Baobab ?"
echo "6) Script Automatique"
echo "7) Quitter"
echo

read choix

case $choix in
	1)
	user_add
	;;
	2)
	user_del
	;;
	3)
	chg_hostname
	;;
	4)
	salle_rep
	;;
	5)
	raccourcis
	;;
	6)
	user_del
	chg_hostname
	user_add
	salle_rep
	raccourcis
	;;
	7)
	exit
	;;
esac
