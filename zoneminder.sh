#!/bin/bash
# Autor: Luiz Correia
# Site: https://luizcorreia.eti.br
# Data de criação: 18/08/2019
# Versão: 0.01
# Testado e homologado para a versão do CentOS7
#
# ZoneMinder é um sistema de CFTV (Circuito Fechado de televisão) Open Source, desenvolvido para sistemas 
# operacionais Linux. Ele é liberado sob os termos da GNU General Public License (GPL). Os usuários 
# controlam o ZoneMinder através de uma interface baseada na Web; também fornece LiveCD. O aplicativo
# pode usar câmeras padrão (por meio de uma placa de captura, USB, Firewire etc.) ou dispositivos de
# câmera baseados em IP. O software permite três modos de operação: monitoramento (sem gravação), 
# gravação após movimento detectado e gravação permanente.
#
# CCTV / CFTV = (Closed-Circuit Television - Circuito fechado de televisão);
# PTZ Pan/Tilt/Zoom (Uma câmera de rede PTZ oferece funcionalidade de vídeo em rede combinada com o recurso
# de movimento horizontal, vertical e de zoom - Pan = Panorâmica Horizontal - Tilt = Vertical | Zoom - Aproximar)
#
# Site Oficial do ZoneMinder: https://zoneminder.com/

# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=`date +%T`
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opões do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
# opção do caracter: | (piper) Conecta a saída padrão com a entrada padrão de outro comando
USUARIO=`id -u`
UBUNTU=`lsb_release -rs`
KERNEL=`uname -r | cut -d'.' -f1,2`
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Declarando as variaveis para criação da Base de Dados do ZoneMinder
USER="root"
PASSWORD="lcd@2019"
DATABASE="/usr/share/zoneminder/db/zm_create.sql"
GRANTALL="GRANT ALL PRIVILEGES ON zm.* TO 'zmuser'@'localhost' IDENTIFIED by 'zmpass';"
FLUSH="FLUSH PRIVILEGES;"
#

#
# Verificando se as dependêncais do ZoneMinder estão instaladas
echo -n "Verificando as dependências, aguarde... "
	yum install mariadb-server 
	systemctl enable mariadb
	systemctl start  mariadb.service
	mysql_secure_installation
#		
# Script de instalação do ZoneMinder no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo -e "Instalação do ZoneMinder no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do ZoneMinder acessar a URL: http://`hostname -I`/zm/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
#
echo -e "Adicionando o Repositório Do Zoneminder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	yum localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm  &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as listas do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	yum install update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	yum install upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o ZoneMinder, aguarde..."
echo
#
echo -e "Editando as Configurações do PHP, perssione <Enter> para continuar"
	# opção do comando: &>> (redirecionar a saída padrão)
	#[Date]
	#date.timezone = America/Sao_Paulo
	read
	vi /etc/php.ini
echo -e "Arquivo do PHP editado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	yum -y install zoneminder &>> $LOG
echo -e "ZoneMinder instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Banco de Dados do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), < (Redirecionador de Saída STDOUT)
	mysql -u $USER -p$PASSWORD < $DATABASE &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Desabilitanto o SELinux, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# SELINUX=disabled
	setenforce 0 &>> $LOG
	read
	vi /etc/selinux/config
echo -e "SELinux desabilitado com sucesso!!!, continuando com o script..."
sleep 5
#
echo -e "Configurando o servidor web, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/ &>> $LOG
	yum -y install mod_ssl &>> $LOG
echo -e "Serviço web configura com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Serviço do httpd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable httpd &>> $LOG
        systemctl start httpd &>> $LOG
echo -e "Serviço criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Serviço do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable zoneminder &>> $LOG
        systemctl start zoneminder &>> $LOG
echo -e "Serviço criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Configurando o firewall, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	firewall-cmd --permanent --zone=public --add-service=http &>> $LOG
     	firewall-cmd --permanent --zone=public --add-service=https &>> $LOG
     	firewall-cmd --permanent --zone=public --add-port=3702/udp &>> $LOG
     	firewall-cmd --reload &>> $LOG
echo -e "Firewall configurado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do ZoneMinder feita com Sucesso!!!"
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=`date +%T`
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1

