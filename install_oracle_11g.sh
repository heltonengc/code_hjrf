#!/bin/bash

set -e

echo "###################################"
echo "# INSTALAÇÃO SILENCIOSA DO ORACLE #"
echo "###################################"
sleep 4s

echo "Checando conexão com a internet.."
sleep 3s
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "Online"
    sleep 3s
    clear
else
    echo "Offline! Verifique as conexoes de rede!"
    sleep 3s
    exit 1
fi

echo "Digite a senha de root"
read -s PASS_ROOT
echo "Digite a senha do Sys"
read -s PASS_SYS


echo "INCIANDO INSTALACAO DO BANCO DE DADOS.. Esta INSTALAÇÃO E HOMOLOGADA PARA ORACLE 11G!!!"
sleep 5s
clear

USER=oracle
/bin/egrep  -i "^${USER}:" /etc/passwd

if [ $? -eq 0 ]; then

   echo "Usuario $USER existe."

else 

   echo " ERRO! O Usuario $USER não existe. Verifique a instalação!"
   exit 1
fi

echo "Em caso de Erro, por favor, entre em contato com o administrador."
sleep 3s
clear

echo "Fazendo Donwload dos arquivos necessários.."
sleep 3s
clear
wget https://www.dropbox.com/s/0ouhm3bhtp0f4wt/linux.x64_11gR2_database_1of2.zip?dl=0 -O /opt/oracle/atualizacao/linux.x64_11gR2_database_1of2.zip
wget https://www.dropbox.com/s/4zwlxlyzrzt9ckf/linux.x64_11gR2_database_2of2.zip?dl=0 -O /opt/oracle/atualizacao/linux.x64_11gR2_database_2of2.zip
wget https://www.dropbox.com/s/oqrrbl1et9w9d19/Oracle.zip?dl=0 -O /opt/oracle/atualizacao/Oracle.zip
clear
echo "Descompactando arquivos.."
mkdir -p /opt/oracle/atualizacao 
sleep 2s
cd /opt/oracle/atualizacao
unzip '*.zip'
clear
read -p "Execute o arquivo preinstall.sh COMO ROOT em outro Terminal e ao finalizar pressione Enter!"

chmod 0700 Oracle_Install_Response_Velit.rsp
chmod 0700 Script_NOVO_Banco.sql
rm -rf *.zip
cd database

#Configura Memoria do Oracle
Mem="$(free -m | awk '/Mem\:/ { print $2 }')"
SGA="$(echo $Mem*40/100 | bc)"
sed -i -- "s/memoryLimit=1533/memoryLimit=$SGA/" /opt/oracle/atualizacao/Oracle_Install_Response_Velit.rsp

read -p "Executando instalador.. Ignore os erros listados como WARNING"
sleep 3s
clear

./runInstaller -silent -responseFile /opt/oracle/atualizacao/Oracle_Install_Response_Velit.rsp


#Cria TableSpace
echo "Criando TableSpace.."
sleep 2s
clear

echo "Digite o tamanho da tablespace! [APENAS O VALOR. EX: 10] "
read tablespace

echo "Criando TABLESPACE! AGUARDE! Será Exibido a informação de desconexão do SQLPLUS, ao finalizar!"
sleep 3s
echo "CREATE BIGFILE TABLESPACE DM DATAFILE '/opt/oracle/oradata/orcl/DM01.dbf' SIZE $tablespace G REUSE LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO DEFAULT NOCOMPRESS;" | sqlplus sys/$PASS_SYS as sysdba


echo "Digite o nome do DONO DO SCHEMA"
read OWNER

sed -i 's/VELIT/"$OWNER"/g'  /opt/oracle/atualizacao/Script_NOVO_Banco.sql

echo "@/opt/oracle/atualizacao/Script_NOVO_Banco.sql;" | sqlplus sys/$PASS_SYS as sysdba
echo $PASS_ROOT | sudo -S sed -i -- 's/db:N/db:Y/' /etc/oratab
echo $PASS_ROOT | sudo -S sed -i -- 's/ORACLE_DB="no"/ORACLE_DB="yes"/' /etc/sysconfig/oracle
echo $PASS_ROOT | sudo -S sed -i -- 's/LISTENER="no"/LISTENER="yes"/' /etc/sysconfig/oracle
clear

#CHECK DMP TO IMPORT
# cd /opt/oracle/atualizacao
# file=(`find ./ -maxdepth 1 -name "*.dmp"`)

# if [ ${#file[@]} -gt 0 ]; then
    
#     echo "Existem arquivos .DMP dentro da pasta atualizacao.. "
#     sleep 3s
#     ls -lh

#     echo "DIGITE O NOME DO SCHEMA PRINCIPAL >> VELIT OU DM?: "
#     read SCHEMA

#     echo "Digite o nome do arquivo .DMP pertencente ao schema DIC. Ex: banco_dic [NAO COLOCAR EXTENSAO]: "
#     read DIC
    
#     echo "Digite o nome do arquivo .DMP pertencente ao schema VELIT OU DM. Ex: banco_velit [NAO COLOCAR EXTENSAO]: "
#     read DV_S

#     echo -s -p "Digite a senha do banco de dados para o SCHEMA DIC informado: "
#     read SENHA_DIC
#     clear
    
#     echo -s -p "Digite a senha do banco de dados para o SCHEMA [$SCHEMA] informado: "
#     read SENHA
#     clear
    
#     impdp dic/$SENHA_DIC dumpfile=$DIC.dmp directory=DIR_SISTOT remap_schema=DIC:DIC
#     impdp $SCHEMA/$SENHA dumpfile=$DV_S.dmp directory=DIR_SISTOT remap_schema=$SCHEMA:$SCHEMA
#     echo "@/opt/oracle/product/11gR1/db/rdbms/admin/utlrp.sql" | sqlplus sys/$PASS_SYS as sysdba
#     quit

# fi

rm -rf database

echo "Concluído!"
sleep 2s
clear
echo "Reinicie o Servidor. Após Isso, cheque a conexao com o banco de dados, usando o PL SQL!"
sleep 3s
clear
rm -rf /opt/oracle/atualizacao/*
