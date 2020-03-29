source /home/oracle/.bash_profile
ORACLE_HOME=/u01/app/oracle/11.2.0/dbhome_1
ORACLE_SID=orcl
RETENCAO=5
NOMEARQ="BKP-%d-%s-%T.BS"
BKPDIR=/u01/app/oracle/backup/rman
DIREXT=/$ORACLE_HOME/rman
$ORACLE_HOME/bin/rman log=$BKPDIR/bkprman.log <<EOF
connect target
backup as compressed backupset database format '$BKPDIR/$NOMEARQ';
sql 'alter system switch logfile';
delete noprompt obsolete recovery window of $RETENCAO days;
exit
EOF


find /u01/app/oracle/backup/rman -mtime 0 -exec cp {} /$ORACLE_HOME/rman \;  2>/home/oracle/rsyncrman.log

find $DIREXT  -mtime +2 -exec rm {} \;
find /$ORACLE_HOME/archives -mtime +3 -exec rm {} \;
