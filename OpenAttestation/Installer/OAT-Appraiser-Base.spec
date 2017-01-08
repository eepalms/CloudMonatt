Name: OAT-Appraiser-Base
Summary: [OAT Crossbow] Host Integrity at Startup Installation of Appraiser Server
Version: 1.0.0 
Release: 2%{?dist}
License: DoD
Group: Department of Defense
Vendor: Department of Defense
Source0: OAT-Appraiser-Configure.tar.gz
BuildRoot: /var/tmp/OAT-Appraiser-Configure-%{PACKAGE_VERSION}

%description
Host Integrity at Startup (OAT) is a project that explores how software and processes on standard desktop computers can be measured to detect and report important and specific changes which highlight potential compromise of the host platform. OAT provides the first examples of effective Measurement and Attestation on the path toward trusted platforms.

%package OATapp
Summary: The OAT Appraiser Base Install 
Group: Department of Defense
#we use mysql for OAT Appraiser, and php is needed for the web portal
Requires: mysql, mysql-server, php, php-mysql
%description OATapp
The Host Integrity at Startup Installation 
of the OAT Appraiser Server Base Install
%prep
%setup -n OAT-Appraiser-Configure
rm -rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT/
cp -R $RPM_BUILD_DIR/OAT-Appraiser-Configure $RPM_BUILD_ROOT

%post OATapp
echo -n "Making OAT Appraiser\n"

#######Install script###########################################################

service mysqld start
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
else
        mkdir /var/lib/oat-appraiser
        mkdir /var/lib/oat-appraiser/CaCerts
        mkdir /var/lib/oat-appraiser/ClientFiles
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
iloc="/OAT-Appraiser-Configure/"
p12file="$loc$ip12"
RAND1=$(dd if=/dev/urandom bs=1 count=1024)
RAND2=$(dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}')
RAND3=$(dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}')
randbits="$(echo "$( echo "`clock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass="${randbits:0:30}"
randbits2="$(echo "$( echo "`clock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass2="${randbits2:0:30}"
randbits3="$(echo "$( echo "`clock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )" | md5sum | md5sum )"
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


service mysqld stop
service tomcat6 stop 

sleep 10

#Configuring mysqld so we can set up database and hisAppraiser profile

#sed -i 's/--datadir="$datadir" --socket="$socketfile"/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/g' /etc/rc.d/init.d/mysqld

service mysqld start

#Sets up database and user
ISSKIPGRANTEXIT=`grep skip-grant-tables /etc/my.cnf`
if [ ! "$ISSKIPGRANTEXIT" ]; then
  sed -i 's/\[mysqld\]/\[mysqld\]\nskip-grant-tables/g' /etc/my.cnf
fi


mysql -u root --execute="CREATE DATABASE oat_db; FLUSH PRIVILEGES; GRANT ALL ON oat_db.* TO 'oatAppraiser'@'localhost' IDENTIFIED BY '$randpass3';"

service mysqld stop

#sed -i 's/--datadir="$datadir" --socket="$socketfile"/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/g' /etc/rc.d/init.d/mysqld


#setting up tomcat at $TOMCAT_INSTALL_DIR/
if [ $TOMCAT_NAME == apache-tomcat-6.0.29 ];then
rm -f $TOMCAT_INSTALL_DIR/apache-tomcat-6.0.29.tar.gz
mv /OAT-Appraiser-Configure/apache-tomcat-6.0.29.tar.gz $TOMCAT_INSTALL_DIR/.
fi

unzip /OAT-Appraiser-Configure/service.zip -d /OAT-Appraiser-Configure/
rm -f /OAT-Appraiser-Configure/service.zip

#mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME $TOMCAT_INSTALL_DIR/apache-tomcat-old
if [ $TOMCAT_NAME == apache-tomcat-6.0.29 ];then
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME
tar -zxf $TOMCAT_INSTALL_DIR/apache-tomcat-6.0.29.tar.gz -C $TOMCAT_INSTALL_DIR/
fi

rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/service
mv -f /OAT-Appraiser-Configure/service $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/service
#rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/Certificate
#mkdir $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/Certificate
rm -rf /var/lib/oat-appraiser/Certificate
mkdir /var/lib/oat-appraiser/Certificate
unzip /OAT-Appraiser-Configure/setupProperties.zip -d /OAT-Appraiser-Configure/
mv /OAT-Appraiser-Configure/setup.properties /etc/oat-appraiser/

rm -R -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/*

#chkconfig --del NetworkManager
chkconfig network on
chkconfig httpd --add
chkconfig httpd on
service httpd start
chkconfig mysqld on
service mysqld start

#running OAT database full setup
#rm -rf /OAT-Appraiser-Configure/MySQLdrop.txt
#unzip /OAT-Appraiser-Configure/MySQLdrop.zip -d /OAT-Appraiser-Configure/
#mysql -u root < /OAT-Appraiser-Configure/MySQLdrop.txt
rm -rf /OAT-Appraiser-Configure/OAT_Server_Install
unzip /OAT-Appraiser-Configure/OAT_Server_Install.zip -d /OAT-Appraiser-Configure/
rm -rf /tmp/OAT_Server_Install
mv -f /OAT-Appraiser-Configure/OAT_Server_Install /tmp/OAT_Server_Install
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
mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisWebServices/WEB-INF/classes/OpenAttestation.properties /etc/oat-appraiser/
sed -i "s/<server.domain>/$(hostname)/g" /etc/oat-appraiser/OpenAttestation.properties
sed -i "s/^truststore_path.*$/truststore_path=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g" /etc/oat-appraiser/OpenAttestation.properties

sed -i "s/^TrustStore.*$/TrustStore=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g"  /etc/oat-appraiser/OpenAttestation.properties
#placing OAT web portal in correct folder to be seen by tomcat6
rm -rf /OAT-Appraiser-Configure/OAT
unzip /OAT-Appraiser-Configure/OAT.zip -d /OAT-Appraiser-Configure/
rm -rf /var/www/html/OAT
mv -f /OAT-Appraiser-Configure/OAT /var/www/html/OAT

#setting all files in the OAT portal to be compiant to selinux
/sbin/restorecon -R '/var/www/html/OAT'

#setting the user and password in the OAT appraiser that will be used to access the mysql database.
sed -i 's/user = "root"/user = "oatAppraiser"/g' /var/www/html/OAT/includes/dbconnect.php
sed -i "s/pass = \"newpwd\"/pass = \"$randpass3\"/g" /var/www/html/OAT/includes/dbconnect.php

#setting up OAT database to talk with the web portal correctly
rm -f /OAT-Appraiser-Configure/oatSetup.txt
unzip /OAT-Appraiser-Configure/oatSetup.zip -d /OAT-Appraiser-Configure/
mysql -u root --database=oat_db < /OAT-Appraiser-Configure/oatSetup.txt


#  This is setting the OAT mysql user to the password given to the Appraiser
#mysql -u root --database=mysql --execute="UPDATE user SET password=PASSWORD('newpwd') WHERE user='hisAppraiser';"
service mysqld stop

#sets configuration of mysql back to normal
#sed -i 's/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/--datadir="$datadir" --socket="$socketfile"/g' /etc/rc.d/init.d/mysqld
ISSKIPGRANTEXIT=`grep nskip-grant-tables /etc/my.cnf`
if [  "$ISSKIPGRANTEXIT" ]; then
  sed -i 's/\[mysqld\]\nskip-grant-tables/\[mysqld\]g' /etc/my.cnf
fi


service mysqld start


#this code sets up the certificate attached to this computers hostname
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
cp $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/service/tomcat6 /etc/rc.d/init.d/
sed -i  "s/killproc \$PROC/daemon \$CATALINA_BIN stop/g" /etc/rc.d/init.d/tomcat6
chkconfig tomcat6 --add
chkconfig tomcat6 on

rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2.war

# TOAT IS THE BEGINNING OF THE PCA PORTION
#rm -rf /OAT-Appraiser-Configure/OAT_PrivacyCA_Install
#unzip /OAT-Appraiser-Configure/OAT_PrivacyCA_Install.zip -d /OAT-Appraiser-Configure/
#rm -rf /tmp/OAT_PrivacyCA_Install
#mv /OAT-Appraiser-Configure/OAT_PrivacyCA_Install /tmp/OAT_PrivacyCA_Install

chmod 777 /tmp
sleep 10
#catalina.sh 
sed -i "/^#CATALINA_BIN/d" /etc/init.d/tomcat6
sed -i "s/^CATALINA_BIN/#CATALINA_BIN/g" /etc/init.d/tomcat6
sed -i "/^#CATALINA_BIN/i\\CATALINA_BIN=\'$TOMCAT_INSTALL_DIR/$TOMCAT_NAME/bin/catalina.sh 1> /dev/null\';" /etc/init.d/tomcat6

service tomcat6 start

# TOAT FOR LOOP IS NEEDED TO MAKE SURE THAT TOMCAT6 IS STARTED WELL BEFORE THE .WAR FILE IS MOVED
for((i = 1; i < 60; i++))
do

        rm -f ./serviceLog

        service tomcat6 status | grep "is running" >> ./serviceLog

        if [ -s ./serviceLog ]; then

        echo tomcat6 has started!
        rm -f ./serviceLog
	sleep 10
        break
        fi

        sleep 1

        echo If this file is present after install then starting tomcat6 timed-out >> serviceLog

done

#moves the war file to webapps folder to unpack it
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2.war
cp /OAT-Appraiser-Configure/HisPrivacyCAWebServices2.war $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/

# This for loop makes the rpm wait until the .war file has unpacked before attempting to access the files that will be created
for((i = 1; i < 60; i++))
do

        rm -f ./warLog
	if [ -e /var/lib/oat-appraiser -a -e /var/lib/oat-appraiser/ClientFiles/OATprovisioner.properties ]; then
#        if [ -e $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2 -a -e $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/OATprovisioner.properties ]; then
          

        echo the Privacy CA was unpacked!
        rm -f ./warLog
        sleep 5
        break
        fi

        sleep 1

        echo If this file is present after install then unpacking the Privacy CA war file timed-out >> warLog

done

#this is a script to re-run certificate creation using new p12 files after installation
rm -rf /OAT-Appraiser-Configure/clientInstallRefresh.sh
rm -rf /OAT-Appraiser-Configure/linuxClientInstallRefresh.sh
cur_dir=$(pwd)
unzip /OAT-Appraiser-Configure/clientInstallRefresh.zip -d /OAT-Appraiser-Configure/
unzip /OAT-Appraiser-Configure/linuxClientInstallRefresh.zip -d /OAT-Appraiser-Configure/
cd /OAT-Appraiser-Configure/
sed -i "s/\/usr\/lib\/apache-tomcat-6.0.29/$TOMCAT_DIR_COFNIG_TYPE\/$TOMCAT_NAME/g" clientInstallRefresh.sh
sed -i "s/\/usr\/lib\/apache-tomcat-6.0.29/$TOMCAT_DIR_COFNIG_TYPE\/$TOMCAT_NAME/g" linuxClientInstallRefresh.sh

mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/lib /var/lib/oat-appraiser/ClientFiles/
mv $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/TPMModule.properties /var/lib/oat-appraiser/ClientFiles/
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/
rm -rf $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/CaCerts
rm -rf clientInstallRefresh.zip
rm -rf linuxClientInstallRefresh.zip

zip -9 linuxClientInstallRefresh.zip linuxClientInstallRefresh.sh
zip -9 clientInstallRefresh.zip    clientInstallRefresh.sh
cp -rf linuxClientInstallRefresh.zip /tmp
cd $cur_dir

rm -rf /OAT-Appraiser-Configure/installers
#unzip /OAT-Appraiser-Configure/ClientInstall.zip -d /OAT-Appraiser-Configure/
unzip /OAT-Appraiser-Configure/ClientInstallForLinux.zip -d /OAT-Appraiser-Configure/

sleep 5

mv /OAT-Appraiser-Configure/ClientInstallForLinux.zip /OAT-Appraiser-Configure/ClientInstallForLinuxOld.zip

rm -rf /OAT-Appraiser-Configure/ClientInstallForLinux

cp -r -f /OAT-Appraiser-Configure/linuxOatInstall /OAT-Appraiser-Configure/ClientInstallForLinux


cp -rf   /OAT-Appraiser-Configure/OAT_Standalone.jar /OAT-Appraiser-Configure/ClientInstallForLinux/
cp -rf   /OAT-Appraiser-Configure/lib  /OAT-Appraiser-Configure/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/PrivacyCA.cer /OAT-Appraiser-Configure/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/TrustStore.jks /OAT-Appraiser-Configure/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/OATprovisioner.properties /OAT-Appraiser-Configure/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/OAT.properties /OAT-Appraiser-Configure/ClientInstallForLinux/
sed -i '/ClientPath/s/C:.*/\/OAT/' /OAT-Appraiser-Configure/ClientInstallForLinux/OATprovisioner.properties
#cp -r -f $TOMCAT_INSTALL_DIR/$TOMCAT_NAME/webapps/HisPrivacyCAWebServices2/ClientFiles/OAT.properties /OAT-Appraiser-Configure/ClientInstallForLinux/
sed -i 's/NIARL_TPM_Module\.exe/NIARL_TPM_Module/g' /OAT-Appraiser-Configure/ClientInstallForLinux/OAT.properties
sed -i 's/HIS07\.jpg/OAT07\.jpg/g' /OAT-Appraiser-Configure/ClientInstallForLinux/OAT.properties
cd /OAT-Appraiser-Configure/; zip -9 -r ClientInstallForLinux.zip ClientInstallForLinux

#places the client installation folder up for tomcat6 to display
cp -f /OAT-Appraiser-Configure/ClientInstallForLinux.zip /var/www/html/


#creates the web page that allows access for the download of the client files folder
echo "<html>" >> /var/www/html/ClientInstaller.html
echo "<body>" >> /var/www/html/ClientInstaller.html
#echo "<h1><a href=\"ClientInstall.zip\">Client Installation Files</a
#></h1>" >> /var/www/html/ClientInstaller.html
echo "<h1><a href=\"ClientInstallForLinux.zip\">Client Installation Files For Linux</a
></h1>" >> /var/www/html/ClientInstaller.html
echo "</body>" >> /var/www/html/ClientInstaller.html
echo "</html>" >> /var/www/html/ClientInstaller.html

chmod 755 /var/www/html/Client*


#closes some known security holes in tomcat6
sed -i "s/AllowOverride None/AllowOverride All/" /etc/httpd/conf/httpd.conf
echo "TraceEnable Off" >> /etc/httpd/conf/httpd.conf
sed -i "s/ServerTokens OS/ServerTokens Prod/" /etc/httpd/conf/httpd.conf
sed -i "s/Options Indexes/Options/" /etc/httpd/conf/httpd.conf
sed -i "s/expose_php = On/expose_php = Off/" /etc/php.ini

rm -f /etc/httpd/conf.d/welcome.conf
echo "" >> /etc/httpd/conf.d/welcome.conf

/sbin/restorecon -R '/var/www/html/OAT'

service tomcat6 restart
#######################################################################
printf "done\n"

%postun OATapp
#HAPCrpmremoval.sh script**********************************************
TOMCAT_INSTALL_DIR2=/usr/lib
TOMCAT_NAME2=apache-tomcat-6.0.29

if [ $TOMCAT_DIR -a  -d $TOMCAT_DIR ];then
  if [[ ${TOMCAT_DIR:$((${#TOMCAT_DIR}-1)):1} == / ]];then
    TOMCAT_DIR_TMP=${TOMCAT_DIR:0:$((${#TOMCAT_DIR}-1))}
  else
    TOMCAT_DIR_TMP=$TOMCAT_DIR
  fi

  TOMCAT_INSTALL_DIR2=${TOMCAT_DIR_TMP%/*}
  TOMCAT_NAME2=${TOMCAT_DIR_TMP##*/}
fi

sed -i "/<\/Service>/d" $TOMCAT_INSTALL_DIR2/$TOMCAT_NAME2/conf/server.xml
sed -i "/<\/Server>/i\\  <\/Service>"  $TOMCAT_INSTALL_DIR2/$TOMCAT_NAME2/conf/server.xml
rm -rf /OAT-Appraiser-Configure/
#stop tomcat service and remove apache-tomcat
kill -9 `ps -ef | grep tomcat | grep -v grep | awk '{print $2}'`
if [ -d $TOMCAT_INSTALL_DIR2/apache-tomcat-6.0.29 ];then
rm -f -r $TOMCAT_INSTALL_DIR2/apache-tomcat-6.0.29.tar.gz
rm -rf $TOMCAT_INSTALL_DIR2/apache-tomcat-6.0.29
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
rm -f -r /var/www/html/OAT

#OAT_PrivacyCA
#rm -f -r /tmp/OAT_PrivacyCA_Install
#rm -f -r /var/www/html/ClientInstall.zip
rm -f -r /var/www/html/ClientInstallForLinux.zip
rm -f -r /var/www/html/ClientInstaller.html

#removes both the OAT mysql database and the hisAppraiser mysql user

service mysqld stop
#sed -i 's/--datadir="$datadir" --socket="$socketfile"/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/g' /etc/rc.d/init.d/mysqld

service mysqld start
mysql -u root --execute="FLUSH PRIVILEGES; DROP DATABASE IF EXISTS oat_db; DELETE FROM mysql.user WHERE User='oatAppraiser' and Host='localhost';"

printf "OAT database removed\n"

service mysqld stop

#sed -i 's/--datadir="$datadir" --skip-grant-tables --socket="$socketfile"/--datadir="$datadir" --socket="$socketfile"/g' /etc/rc.d/init.d/mysqld

service mysqld start


#**********************************************************************

%clean
rm -rf $RPM_BUILD_ROOT


%files OATapp
/OAT-Appraiser-Configure/apache-tomcat-6.0.29.tar.gz
/OAT-Appraiser-Configure/clientInstallRefresh.zip
/OAT-Appraiser-Configure/linuxClientInstallRefresh.zip
/OAT-Appraiser-Configure/ClientInstallForLinux.zip
/OAT-Appraiser-Configure/HisPrivacyCAWebServices2.war
/OAT-Appraiser-Configure/OAT_Server_Install.zip
/OAT-Appraiser-Configure/oatSetup.zip
/OAT-Appraiser-Configure/OAT.zip
/OAT-Appraiser-Configure/MySQLdrop.zip
/OAT-Appraiser-Configure/service.zip
/OAT-Appraiser-Configure/setupProperties.zip
/OAT-Appraiser-Configure/OAT.sh
/OAT-Appraiser-Configure/OAT_Standalone.jar
/OAT-Appraiser-Configure/lib
/OAT-Appraiser-Configure/log4j.properties
