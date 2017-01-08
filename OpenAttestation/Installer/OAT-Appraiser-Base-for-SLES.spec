Name: OAT-Appraiser-Base
Summary: [OAT Crossbow] Host Integrity at Startup Installation of Appraiser Server
Version: 1.0.1 
Release: 2%{?dist}
License: DoD
Group: Department of Defense
Vendor: Department of Defense
Source: OAT-Appraiser-Base.tar.gz
BuildRoot: /var/tmp/%{name}-%{PACKAGE_VERSION}

%description
Host Integrity at Startup (OAT) is a project that explores how software and processes on standard desktop computers can be measured to detect and report important and specific changes which highlight potential compromise of the host platform. OAT provides the first examples of effective Measurement and Attestation on the path toward trusted platforms.

%package OATapp
Summary: The OAT Appraiser Base Install 
Group: Department of Defense
#we use mysql for OAT Appraiser, and php is needed for the web portal
#openjdk 1.6 is not available anymore from the latest distro
#Requires: mysql, php5, php5-mysql, apache2, apache2-mod_php5, java-1_6_0-openjdk, openssl
Requires: mysql, php5, php5-mysql, apache2, apache2-mod_php5,openssl
%description OATapp
The Host Integrity at Startup Installation 
of the OAT Appraiser Server Base Install
%prep
%setup -n %{name}
rm -rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT/
cp -R $RPM_BUILD_DIR/%{name} $RPM_BUILD_ROOT

%post OATapp
echo -ne "Making OAT Appraiser\n"

#######Install script###########################################################
service mysql start
#TOMCAT_INSTALL_DIR=/usr/lib
#TOMCAT_INSTALL_DIR=$TOMCAT_DIR
#TOMCAT_DIR_COFNIG_TYPE=${TOMCAT_INSTALL_DIR//\//\\/}
##TOMCAT_NAME=apache-tomcat-6.0.35
#TOMCAT_NAME=apache-tomcat-6.0.29
#echo $TOMCAT_INSTALL_DIR > ~/rpm.log
#echo $TOMCAT_DIR_COFNIG_TYPE >> ~/rpm.log
TOMCAT_INSTALL_DIR=/usr/lib
TOMCAT_NAME=apache-tomcat-6.0.29

if [ -d /var/lib/oat-appraiser ]
then
        rm -rf /var/lib/oat-appraiser
        mkdir /var/lib/oat-appraiser
        mkdir /var/lib/oat-appraiser/CaCerts
        mkdir /var/lib/oat-appraiser/ClientFiles
        mkdir /var/lib/oat-appraiser/Certificate
else
        mkdir /var/lib/oat-appraiser
        mkdir /var/lib/oat-appraiser/CaCerts
        mkdir /var/lib/oat-appraiser/ClientFiles
        mkdir /var/lib/oat-appraiser/Certificate
fi


if [ -d /etc/oat-appraiser ]
then
        rm -rf /etc/oat-appraiser
        mkdir /etc/oat-appraiser
else
        mkdir /etc/oat-appraiser
fi

if [ $TOMCAT_DIR -a  -d $TOMCAT_DIR ];then
  if [[ ${TOMCAT_DIR:$((${#TOMCAT_DIR}-1)):1} == / ]];then
    TOMCAT_DIR_TMP=${TOMCAT_DIR:0:$((${#TOMCAT_DIR}-1))}
  else
    TOMCAT_DIR_TMP=$TOMCAT_DIR
  fi

  TOMCAT_INSTALL_DIR=${TOMCAT_DIR_TMP%/*}
  TOMCAT_NAME=${TOMCAT_DIR_TMP##*/}
fi
TOMCAT_DIR_COFNIG_TYPE=${TOMCAT_INSTALL_DIR//\//\\/}
echo $TOMCAT_INSTALL_DIR > ~/rpm.log
echo $TOMCAT_DIR_COFNIG_TYPE >> ~/rpm.log

###Random generation /dev/urandom is good but just in case...
# Creating randoms for the p12 files and setting up truststore and keystore
ip12="internal.p12"
ipassfile="internal.pass"
idomfile="internal.domain"
iloc="/%{name}/"
p12file="$loc$ip12"
RAND1=$(dd if=/dev/urandom bs=1 count=1024)
RAND2=$(dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}')
RAND3=$(dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}')
randbits="$(echo "$( echo "`hwclock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass="${randbits:0:30}"
randbits2="$(echo "$( echo "`hwclock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass2="${randbits2:0:30}"
randbits3="$(echo "$( echo "`hwclock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`hwclock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass3="${randbits3:0:30}"
p12pass="$randpass"
mysqlPass="$randpass2"
keystore="keystore.jks"
truststore="TrustStore.jks"
if [ "`ls $iloc | grep $ip12`" ] && [ "`ls $iloc | grep $ipassfile`" ] ; then
  p12pass="`cat $loc$ipassfile`"
fi
if [ "`ls $iloc | grep $idomfile`" ] ; then
  domain="`cat $loc$idomfile`"
fi

#ls -al /tomcat6
service mysql stop
service tomcat6 stop 

sleep 10

#Configuring mysql so we can set up database and hisAppraiser profile
ISENGINE=`grep "default-storage-engine=INNODB" /etc/my.cnf`
if [ ! "$ISENGINE" ]; then
  sed -i 's/\[mysqld\]/\[mysqld\]\ndefault-storage-engine=INNODB/g' /etc/my.cnf
fi

#sed -i 's/--datadir="$datadir" --socket="$socketfile"/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/g' /etc/rc.d/init.d/mysql

service mysql start

#Sets up database and user
ISSKIPGRANTEXIT=`grep skip-grant-tables /etc/my.cnf`
if [ ! "$ISSKIPGRANTEXIT" ]; then
  sed -i 's/\[mysqld\]/\[mysqld\]\nskip-grant-tables/g' /etc/my.cnf
fi


mysql -u root --execute="CREATE DATABASE oat_db; FLUSH PRIVILEGES; GRANT ALL ON oat_db.* TO 'oatAppraiser'@'localhost' IDENTIFIED BY '$randpass3';"

service mysql stop

#sed -i 's/--datadir="$datadir" --socket="$socketfile"/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/g' /etc/rc.d/init.d/mysql


#setting up tomcat at $TOMCAT_INSTALL_DIR/
if [ $TOMCAT_NAME == apache-tomcat-6.0.29 ];then
rm -f $TOMCAT_INSTALL_DIR/apache-tomcat-6.0.29.tar.gz
mv /%{name}/apache-tomcat-6.0.29.tar.gz $TOMCAT_INSTALL_DIR/.
fi
unzip /%{name}/service.zip -d /%{name}/
rm -f /%{name}/service.zip
cp /%{name}/tomcat6 /etc/init.d/
#mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME $TOMCAT_INSTALL_DIR/apache-tomcat-old
if [ $TOMCAT_NAME == apache-tomcat-6.0.29 ];then
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME
tar -zxf $TOMCAT_INSTALL_DIR/apache-tomcat-6.0.29.tar.gz -C $TOMCAT_INSTALL_DIR/
fi

rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/service
mv -f /%{name}/service $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/service
#rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/Certificate
#mkdir $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/Certificate
unzip /%{name}/setupProperties.zip -d /%{name}/
mv /%{name}/setup.properties /etc/oat-appraiser/

rm -R -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/*

#chkconfig --del NetworkManager
chkconfig apache2 on
chkconfig mysql on
service mysql start

#running OAT database full setup
#rm -rf /%{name}/MySQLdrop.txt
#unzip /%{name}/MySQLdrop.zip -d /%{name}/
#mysql -u root < /%{name}/MySQLdrop.txt
rm -rf /%{name}/OAT_Server_Install
unzip /%{name}/OAT_Server_Install.zip -d /%{name}/
rm -rf /tmp/OAT_Server_Install
mv -f /%{name}/OAT_Server_Install /tmp/OAT_Server_Install
mysql -u root --execute="DROP DATABASE IF EXISTS oat_db;"
mysql -u root < /tmp/OAT_Server_Install/oat_db.MySQL
mysql -u root < /tmp/OAT_Server_Install/init.sql
#setting up access control in tomcat context.xml
#sed -i "/<\/Context>/i\\   <Resource name=\"jdbc\/oat\" auth=\"Container\" type=\"javax.sql.DataSource\"\n    username=\"oatAppraiser\" password=\"$randpass3\" driverClassName=\"com.mysql.jdbc.Driver\"\n    url=\"jdbc:mysql:\/\/localhost:3306\/oat_db\"\/>" $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/conf/context.xml

sed -i "/<\/Context>/i\\   <Resource name=\"jdbc\/oat\" auth=\"Container\" type=\"com.mchange.v2.c3p0.ComboPooledDataSource\" user=\"oatAppraiser\" password=\"$randpass3\"\n  driverClass=\"com.mysql.jdbc.Driver\" factory=\"org.apache.naming.factory.BeanFactory\" maxIdleTime=\"300\" idleConnectionTestPeriod=\"150\" jdbcUrl=\"jdbc:mysql:\/\/localhost:3306\/oat_db\"\/>" $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/conf/context.xml

#setting up port 8443 in tomcat server.xml
sed -i "s/ <\/Service>/<Connector port=\"8443\" minSpareThreads=\"5\" maxSpareThreads=\"75\" enableLookups=\"false\" disableUploadTimeout=\"true\" acceptCount=\"100\" maxThreads=\"200\" scheme=\"https\" secure=\"true\" SSLEnabled=\"true\" clientAuth=\"want\" sslProtocol=\"TLS\" ciphers=\"TLS_ECDH_anon_WITH_AES_256_CBC_SHA, TLS_ECDH_anon_WITH_AES_128_CBC_SHA, TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA, TLS_ECDH_RSA_WITH_AES_256_CBC_SHA, TLS_ECDH_RSA_WITH_AES_128_CBC_SHA, TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA, TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA, TLS_DHE_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA\" keystoreFile=\"\/var\/lib\/oat-appraiser\/Certificate\/keystore.jks\" keystorePass=\"$p12pass\" truststoreFile=\"\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks\" truststorePass=\"password\" \/><\/Service>/g" $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/conf/server.xml




cp -R /tmp/OAT_Server_Install/HisWebServices $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/
#
#if [ -e $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/OpenAttestationAdminConsole.war ];then
#  rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/OpenAttestationAdminConsole.war
#fi
#
#if [ -e $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/OpenAttestationManifestWebServices.war ];then
#  rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/OpenAttestationManifestWebServices.war
#fi
#
#if [ -e $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/OpenAttestationWebServices.war ];then
#  rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/OpenAttestationWebServices.war
#fi

cp  /tmp/OAT_Server_Install/WLMService.war $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/
cp  /tmp/OAT_Server_Install/AttestationService.war $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/
unzip $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/WLMService.war -d $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/WLMService
unzip $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/AttestationService.war -d $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/AttestationService
#delete the OpenAttestation war package
rm -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/WLMService.war
rm -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/AttestationService.war
mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/AttestationService/WEB-INF/classes/OpenAttestationWebServices.properties /etc/oat-appraiser/OpenAttestationWebServices.properties
#configuring hibernateHis for OAT appraiser setup
cp /tmp/OAT_Server_Install/hibernateOat.cfg.xml /tmp/
sed -i 's/<property name="connection.username">root<\/property>/<property name="connection.username">oatAppraiser<\/property>/' /tmp/hibernateOat.cfg.xml
sed -i "s/<property name=\"connection.password\">oat-password<\/property>/<property name=\"connection.password\">$randpass3<\/property>/" /tmp/hibernateOat.cfg.xml
cp /tmp/hibernateOat.cfg.xml $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisWebServices/WEB-INF/classes/
cp /tmp/OAT_Server_Install/OAT.properties /etc/oat-appraiser/ 
mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisWebServices/WEB-INF/classes/OpenAttestation.properties /etc/oat-appraiser/OpenAttestation.properties
sed -i "s/<server.domain>/$(hostname)/g" /etc/oat-appraiser/OpenAttestation.properties

sed -i "s/^truststore_path.*$/truststore_path=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g" /etc/oat-appraiser/OpenAttestation.properties

sed -i "s/^TrustStore.*$/TrustStore=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g"  /etc/oat-appraiser/OpenAttestation.properties
#placing OAT web portal in correct folder to be seen by tomcat6
rm -rf /%{name}/OAT
unzip /%{name}/OAT.zip -d /%{name}/
rm -rf /srv/www/htdocs/OAT
mv -f /%{name}/OAT /srv/www/htdocs/OAT

#setting all files in the OAT portal to be compiant to selinux
#/sbin/restorecon -R '/srv/www/htdocsOAT'

#setting the user and password in the OAT appraiser that will be used to access the mysql database.
sed -i 's/user = "root"/user = "oatAppraiser"/g' /srv/www/htdocs/OAT/includes/dbconnect.php
sed -i "s/pass = \"newpwd\"/pass = \"$randpass3\"/g" /srv/www/htdocs/OAT/includes/dbconnect.php

#setting up OAT database to talk with the web portal correctly
rm -f /%{name}/oatSetup.txt
unzip /%{name}/oatSetup.zip -d /%{name}/
mysql -u root --database=oat_db < /%{name}/oatSetup.txt


#  This is setting the OAT mysql user to the password given to the Appraiser
#mysql -u root --database=mysql --execute="UPDATE user SET password=PASSWORD('newpwd') WHERE user='hisAppraiser';"
service mysql stop

#sets configuration of mysql back to normal
#sed -i 's/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/--datadir="$datadir" --socket="$socketfile"/g' /etc/rc.d/init.d/mysql
ISSKIPGRANTEXIT=`grep nskip-grant-tables /etc/my.cnf`
if [  "$ISSKIPGRANTEXIT" ]; then
  sed -i 's/skip-grant-tables//g' /etc/my.cnf
fi


service mysql start


#this code sets up the certificate attached to this computers hostname
#cd $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/Certificate/
cd /var/lib/oat-appraiser/Certificate/
echo "127.0.0.1       `hostname`" >> /etc/hosts
if [ "`echo $p12pass | grep $randpass`" ] ; then
  openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout hostname.pem -out hostname.cer -subj "/C=US/O=U.S. Government/OU=DoD/CN=`hostname`"
  openssl pkcs12 -export -in hostname.cer -inkey hostname.pem -out $p12file -passout pass:$p12pass
fi

keytool -importkeystore -srckeystore $p12file -destkeystore $keystore -srcstoretype pkcs12 -srcstorepass $p12pass -deststoretype jks -deststorepass $p12pass -noprompt

myalias=`keytool -list -v -keystore $keystore -storepass $p12pass | grep -B2 'PrivateKeyEntry' | grep 'Alias name:'`

keytool -changealias -alias ${myalias#*:} -destalias tomcat -v -keystore $keystore -storepass $p12pass

rm -f $truststore
keytool -import -keystore $truststore -storepass password -file hostname.cer -noprompt

#sets up the tomcat6 service
chmod -R 755 $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/service/*

rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2.war

# TOAT IS THE BEGINNING OF THE PCA PORTION
#rm -rf /%{name}/OAT_PrivacyCA_Install
#unzip /%{name}/OAT_PrivacyCA_Install.zip -d /%{name}/
#rm -rf /tmp/OAT_PrivacyCA_Install
#mv /%{name}/OAT_PrivacyCA_Install /tmp/OAT_PrivacyCA_Install

chmod 777 /tmp
sleep 10
#catalina.sh 
service tomcat6 start

# TOAT FOR LOOP IS NEEDED TO MAKE SURE THAT TOMCAT6 IS STARTED WELL BEFORE THE .WAR FILE IS MOVED
for((i = 1; i < 60; i++))
do
	if [ -e ./serviceLog ];then
        	rm -f ./serviceLog
	fi
        service tomcat6 status | grep "is running" >> ./serviceLog

        if [ -s ./serviceLog ]; then

        echo "tomcat6 has started!"
        rm -f ./serviceLog
	sleep 10
        break
        fi

        sleep 1

        echo "If this file is present after install then starting tomcat6 timed-out" >> serviceLog

done

#moves the war file to webapps folder to unpack it
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2.war
cp /%{name}/HisPrivacyCAWebServices2.war $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/
# This for loop makes the rpm wait until the .war file has unpacked before attempting to access the files that will be created
for((i = 1; i < 60; i++))
do

        rm -f ./warLog

        if [ -e /var/lib/oat-appraiser -a -e /var/lib/oat-appraiser/ClientFiles/OATprovisioner.properties ]; then
#        if [ -e $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2 -a -e $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/OATprovisioner.properties ]; then
          

        echo "the Privacy CA was unpacked!"
        rm -f ./warLog
        sleep 5
        break
        fi

        sleep 1

        echo If this file is present after install then unpacking the Privacy CA war file timed-out >> warLog

done
#this is a script to re-run certificate creation using new p12 files after installation
rm -rf /%{name}/clientInstallRefresh.sh
rm -rf /%{name}/linuxClientInstallRefresh.sh
cur_dir=$(pwd)
unzip /%{name}/clientInstallRefresh.zip -d /%{name}/
unzip /%{name}/linuxClientInstallRefresh.zip -d /%{name}/
cd /%{name}/
sed -i "s/\/usr\/lib\/apache-tomcat-6.0.29/$TOMCAT_DIR_COFNIG_TYPE\/$TOMCAT_NAME/g" clientInstallRefresh.sh
sed -i "s/\/usr\/lib\/apache-tomcat-6.0.29/$TOMCAT_DIR_COFNIG_TYPE\/$TOMCAT_NAME/g" linuxClientInstallRefresh.sh

rm -rf clientInstallRefresh.zip
rm -rf linuxClientInstallRefresh.zip

mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/lib /var/lib/oat-appraiser/ClientFiles/
mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/TPMModule.properties /var/lib/oat-appraiser/ClientFiles/
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/CaCerts
zip -9 linuxClientInstallRefresh.zip linuxClientInstallRefresh.sh
zip -9 clientInstallRefresh.zip    clientInstallRefresh.sh
#test Q
cp -rf linuxClientInstallRefresh.zip /tmp
cd $cur_dir

rm -rf /%{name}/installers
#unzip /%{name}/ClientInstall.zip -d /%{name}/
unzip /%{name}/ClientInstallForLinux.zip -d /%{name}/

sleep 5

# zky: similar from here
#rm -f /%{name}/ClientInstallOld.zip
#mv /%{name}/ClientInstall.zip /%{name}/ClientInstallOld.zip

#rm -rf /%{name}/ClientInstall
#mkdir /%{name}/ClientInstall

#This code grabs all of the needed files from the privacy CA folder and packages them into a Client Installation folder
#cp -r -f /%{name}/installers /%{name}/ClientInstall

#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/endorsement.p12 /%{name}/ClientInstall/installers/hisInstall/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/lib /%{name}/ClientInstall/installers/hisInstall/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/TPMModule.properties /%{name}/ClientInstall/installers/hisInstall/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/exe /%{name}/ClientInstall/installers/hisInstall/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/PrivacyCA.cer /%{name}/ClientInstall/installers/hisInstall/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/TrustStore.jks /%{name}/ClientInstall/installers/hisInstall/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/OATprovisioner.properties /%{name}/ClientInstall/installers/hisInstall/
##DWC added two following lines for Chris
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/install.bat /%{name}/ClientInstall/installers/hisInstall/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/OAT.properties /%{name}/ClientInstall/installers/hisInstall/
#
##privacy.jar for windows
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/lib/PrivacyCA.jar /%{name}/ClientInstall/installers/hisInstall/lib


#cd /%{name}/; zip -9 -r ClientInstall.zip ClientInstall


#places the client installation folder up for tomcat6 to display
#cp -f /%{name}/ClientInstall.zip /srv/www/htdocs/

#zky: for linux, do similar things
rm -f /%{name}/ClientInstallForLinuxOld.zip
mv /%{name}/ClientInstallForLinux.zip /%{name}/ClientInstallForLinuxOld.zip

rm -rf /%{name}/ClientInstallForLinux

cp -r -f /%{name}/linuxOatInstall /%{name}/ClientInstallForLinux

#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/endorsement.p12 /%{name}/ClientInstallForLinux/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/PrivacyCA.cer /%{name}/ClientInstallForLinux/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/TrustStore.jks /%{name}/ClientInstallForLinux/
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/OATprovisioner.properties /%{name}/ClientInstallForLinux/

cp -rf   /OAT-Appraiser-Base/OAT_Standalone.jar /OAT-Appraiser-Base/ClientInstallForLinux/
cp -rf   /OAT-Appraiser-Base/lib  /OAT-Appraiser-Base/ClientInstallForLinux/

cp -r -f /var/lib/oat-appraiser/ClientFiles/PrivacyCA.cer /%{name}/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/TrustStore.jks /%{name}/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/OATprovisioner.properties /%{name}/ClientInstallForLinux/

#remove credential information here
sed -i '/TpmEndorsmentP12/d' /%{name}/ClientInstallForLinux/OATprovisioner.properties
sed -i '/EndorsementP12Pass/d' /%{name}/ClientInstallForLinux/OATprovisioner.properties
#end remove

cp -r -f /var/lib/oat-appraiser/ClientFiles/OAT.properties /%{name}/ClientInstallForLinux/
sed -i '/ClientPath/s/C:.*/\/OAT/' /%{name}/ClientInstallForLinux/OATprovisioner.properties
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/OAT.properties /%{name}/ClientInstallForLinux/
sed -i 's/NIARL_TPM_Module\.exe/NIARL_TPM_Module/g' /%{name}/ClientInstallForLinux/OAT.properties
sed -i 's/HIS07\.jpg/OAT07\.jpg/g' /%{name}/ClientInstallForLinux/OAT.properties
cd /%{name}/; zip -9 -r ClientInstallForLinux.zip ClientInstallForLinux

#Test
cp -f /%{name}/ClientInstallForLinux.zip /tmp/
#


#places the client installation folder up for tomcat6 to display
cp -f /%{name}/ClientInstallForLinux.zip /srv/www/htdocs


#creates the web page that allows access for the download of the client files folder
echo "<html>" >> /srv/www/htdocs/ClientInstaller.html
echo "<body>" >> /srv/www/htdocs/ClientInstaller.html
#echo "<h1><a href=\"ClientInstall.zip\">Client Installation Files</a
#></h1>" >> /srv/www/htdocs/ClientInstaller.html
echo "<h1><a href=\"ClientInstallForLinux.zip\">Client Installation Files For Linux</a
></h1>" >> /srv/www/htdocs/ClientInstaller.html
echo "</body>" >> /srv/www/htdocs/ClientInstaller.html
echo "</html>" >> /srv/www/htdocs/ClientInstaller.html

chmod 755 /srv/www/htdocs/Client*


#closes some known security holes in tomcat6
sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/httpd.conf
sed -i "s/ServerTokens OS/ServerTokens Prod/" /etc/apache2/httpd.conf
sed -i "s/Options Indexes/Options/" /etc/apache2/httpd.conf
sed -i "s/expose_php = On/expose_php = Off/" /etc/php5/cli/php.ini

#rm -f /etc/apache2.d/welcome.conf
#echo "" >> /etc/apache2.d/welcome.conf

#/sbin/restorecon -R '/srv/www/htdocs/OAT'
service apache2 restart

#######################################################################
printf "done\n"

%postun OATapp
#HAPCrpmremoval.sh script**********************************************
TOMCAT_INSTALL_DIR2=/usr/lib
TOMCAT_NAME2=apache-tomcat-6.0.29
service tomcat6 stop
if [ $TOMCAT_DIR -a  -d $TOMCAT_DIR ];then
  if [[ ${TOMCAT_DIR:$((${#TOMCAT_DIR}-1)):1} == / ]];then
    TOMCAT_DIR_TMP=${TOMCAT_DIR:0:$((${#TOMCAT_DIR}-1))}
  else
    TOMCAT_DIR_TMP=$TOMCAT_DIR
  fi

  TOMCAT_INSTALL_DIR2=${TOMCAT_DIR_TMP%/*}
  TOMCAT_NAME2=${TOMCAT_DIR_TMP##*/}
fi
chkconfig tomcat6 --del

sed -i "/<\/Service>/d" $TOMCAT_INSTALL_DIR2/$TOMCAT_NAME2/conf/server.xml
sed -i "/<\/Server>/i\\  <\/Service>"  $TOMCAT_INSTALL_DIR2/$TOMCAT_NAME2/conf/server.xml
rm -rf /%{name}/
#stop tomcat service and remove apache-tomcat
kill -9 `ps -ef | grep tomcat | grep -v grep | awk '{print $2}'`
if [ $TOMCAT_NAME2 == apache-tomcat-6.0.29 ];then
rm -f -r $TOMCAT_INSTALL_DIR2/apache-tomcat-6.0.29.tar.gz
rm -rf  $TOMCAT_INSTALL_DIR2/apache-tomcat-6.0.29
fi

if [ -d /etc/oat-appraiser ]
then
rm -rf /etc/oat-appraiser
fi

if [ -d /var/lib/oat-appraiser ]
then
rm -rf /var/lib/oat-appraiser
fi

#OAT_Server
rm -f -r /tmp/OAT_Server_Install
rm -f -r /srv/www/htdocs/OAT

#OAT_PrivacyCA
#rm -f -r /tmp/OAT_PrivacyCA_Install
#rm -f -r /srv/www/htdocs/ClientInstall.zip
rm -f -r /srv/www/htdocs/ClientInstallForLinux.zip
rm -f -r /srv/www/htdocs/ClientInstaller.html

#removes both the OAT mysql database and the hisAppraiser mysql user

service mysql stop
#sed -i 's/--datadir="$datadir" --socket="$socketfile"/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/g' /etc/rc.d/init.d/mysql

service mysql start
mysql -u root --execute="FLUSH PRIVILEGES; DROP DATABASE IF EXISTS oat_db; DELETE FROM mysql.user WHERE User='oatAppraiser' and Host='localhost';"


service mysql stop

#sed -i 's/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/--datadir="$datadir" --socket="$socketfile"/g' /etc/rc.d/init.d/mysql

service mysql start

echo  -ne "OAT database removed\n"
echo -ne "package remove clean\n"
#**********************************************************************

%clean
rm -rf $RPM_BUILD_ROOT


%files OATapp
/%{name}/apache-tomcat-6.0.29.tar.gz
/%{name}/clientInstallRefresh.zip
/%{name}/linuxClientInstallRefresh.zip
#/%{name}/ClientInstall.zip
/%{name}/ClientInstallForLinux.zip
/%{name}/tomcat6
/%{name}/HisPrivacyCAWebServices2.war
/%{name}/OAT_Server_Install.zip
/%{name}/oatSetup.zip
/%{name}/OAT.zip
/%{name}/MySQLdrop.zip
/%{name}/service.zip
/%{name}/setupProperties.zip
/%{name}/OAT.sh
/%{name}/OAT_Standalone.jar
/%{name}/log4j.properties
/%{name}/lib/

