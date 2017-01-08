#!/bin/bash

#########################################################
#       The script for test MTW API                     #
#########################################################

# Get OAT server name and create cert file
echo -n "Please enter the OAT server name[default:localhost]: "
read HOST_NAME
if [ "$HOST_NAME" = "" ];then
        HOST_NAME=localhost
fi
./oat_cert -h $HOST_NAME > /tmp/cert.log
if [ -z "`cat /tmp/cert.log`" ];then
	echo "The host $HOST_NAME can not connect, Exit..."
	exit 1
fi

if [ -f /tmp/Result ];then
        rm -f /tmp/Result
fi

echo "Auto test script is running, please waitting..."

echo "#The result about OEM" >> /tmp/Result
echo "******************Add OEM normal******************************************" >> /tmp/Result
# Add OEM successful (normal)
echo -n "Add OEM successful (normal)		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`  # Get OEM Name
OEM_DESC=`awk 'NR==12 {print $2;}' commandtool.data`  # Get Description
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        echo "Passed " >> /tmp/Result
else
        echo "Failed " >> /tmp/Result
fi

# Add OEM fail (normal)
echo -n "Add OEM fail (normal)			:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Add OEM with checking boundary value********************" >> /tmp/Result
# Add OEM with null string
echo -n "Add OEM with null string		:	" >> /tmp/Result
OEM_TMP=""
OEM_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add OEM with edge length string
echo -n "Add OEM with edge lenth string		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $5;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $5;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add OEM with over length string
echo -n "Add OEM with over length string		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $6;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $6;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Add OEM with checking special character******************" >> /tmp/Result
# Add OEM success with special char
echo -n "Add OEM success with special char	:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $7;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $7;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi
# Add OEM fail with special char
echo -n "Add OEM fail with special char			:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $8;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $8;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Edit OEM normal*****************************************" >> /tmp/Result
# Edit OEM successful (normal)
echo -n "Edit OEM successful (normal)		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $3;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
OEM_DESC=`awk 'NR==12 {print $3;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
else
	echo "Failed" >> /tmp/Result
fi

# Edit OEM fail (normal)
echo -n "Edit OEM fail (normal)			:	" >> /tmp/Result
OEM_TMP=OEMnone
OEM_DESC=`awk 'NR==12 {print $6;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Edit OEM with checking boundary value******************" >> /tmp/Result
# Edit OEM with null string
echo -n "Edit OEM with null string		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $3;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"\"}"`
./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Edit OEM with edge length string
echo -n "Edit OEM with edge length string		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $3;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $5;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Edit OEM with over length string
echo -n "Edit OEM with over length string		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $3;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $6;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Edit OEM with checking special character****************" >> /tmp/Result
# Edit OEM success with special char
echo -n "Edit OEM success with special char		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $3;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $7;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Edit OEM fail with special char
echo -n "Edit OEM fail with special char		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $3;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $8;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Delete OEM normal**************************************" >> /tmp/Result
# Delete OEM successful (normal)
echo -n "Delete OEM successful (normal)		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $4;}' commandtool.data`
OEM_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\",\"Description\":\"$OEM_DESC\"}"`
./oat_oem -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	INFO=`echo "{\"Name\":\"$OEM_TMP\"}"`
	./oat_oem -d -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
else
	echo "Failed" >> /tmp/Result
fi

# Delete OEM fail (normal)
echo -n "Delete non-existent OEM fail (normal)	:	" >> /tmp/Result
OEM_TMP=OEMnone
INFO=`echo "{\"Name\":\"$OEM_TMP\"}"`
./oat_oem -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Delete OEM with checking boundary value*****************" >> /tmp/Result
# Delete OEM with null string
echo -n "Delete OEM with null string		:	" >> /tmp/Result
OEM_TMP=""
INFO=`echo "{\"Name\":\"$OEM_TMP\"}"`
./oat_oem -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Delete OEM with edge length string
echo -n "Delete OEM with edge length string	:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $5;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\"}"`
./oat_oem -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Delete OEM with checking special character**************" >> /tmp/Result
# Delete OEM with special char
echo -n "Delete OEM with special char		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $7;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\"}"`
./oat_oem -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************View OEM************************************************" >> /tmp/Result
# View OEM
echo -n "View OEM				:	" >> /tmp/Result
./oat_view_oem -h $HOST_NAME > /tmp/res
VIEW=`awk -F "\"" '{print $2;}' /tmp/res`
if [ "$VIEW" = "oem" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "#The result about OS" >> /tmp/Result
echo "******************Add OS normal*******************************************" >> /tmp/Result
# Add OS successful (normal)
echo -n "Add OS successful (normal)		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Add OS fail (normal)
echo -n "Add OS fail (normal)			:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_os -a -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
		echo "Passed " >> /tmp/Result
	else
		echo "Failed " >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "******************Add OS with checking boundary value*********************" >> /tmp/Result
# Add OS with null string
echo -n "Add OS with null string			:	" >> /tmp/Result
OS_TMP=""
OS_VER=""
OS_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add OS with edge length string
echo -n "Add OS with edge length string		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $5;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $5;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $5;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add OS with over length string
echo -n "Add OS with over length string		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $6;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $6;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $6;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Add OS with checking special character******************" >> /tmp/Result
# Add OS success with special char
echo -n "Add OS success with special char		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $7;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $7;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $7;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi
# Add OS fail with special char
echo -n "Add OS fail with special char			:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $8;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $8;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $8;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

echo "******************Edit OS normal*****************************************" >> /tmp/Result
# Edit OS successful (normal)
echo -n "Edit OS successful (normal)		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $3;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $3;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
OS_DESC=`awk 'NR==12 {print $3;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_os -e -h $HOST_NAME $INFO > /tmp/res
        if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
                echo "Passed" >> /tmp/Result
        else
                echo "Failed" >> /tmp/Result
        fi
elif [ $EID -eq 0 ];then
	./oat_os -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi	
else
        echo "Failed" >> /tmp/Result
fi

# Edit OS fail (normal)
echo -n "Edit OS fail (normal)			:	" >> /tmp/Result
OS_TMP=OSnone
OS_VER=osv0
OS_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

echo "******************Edit OS with checking boundary value******************" >> /tmp/Result
# Edit OS with null string
echo -n "Edit OEM with null string		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $3;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $3;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"\"}"`
./oat_os -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

# Edit OS with edge length string
echo -n "Edit OEM with edge length string		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $3;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $3;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $5;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

# Edit OS with over length string
echo -n "Edit OS with over length string		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $3;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $3;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $6;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

echo "******************Edit OS with checking special character****************" >> /tmp/Result
# Edit OS success with special char
echo -n "Edit OS success with special char		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $3;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $3;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $7;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

# Edit OS fail with special char
echo -n "Edit OS fail with special char			:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $3;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $3;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $8;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

echo "******************Delete OS normal**************************************" >> /tmp/Result
# Delete OS successful (normal)
echo -n "Delete OS successful (normal)		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $4;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $4;}' commandtool.data`
OS_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\",\"Description\":\"$OS_DESC\"}"`
./oat_os -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\"}"`
        ./oat_os -d -h $HOST_NAME $INFO > /tmp/res
        if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
                echo "Passed" >> /tmp/Result
        else
                echo "Failed" >> /tmp/Result
        fi
else
        echo "Failed" >> /tmp/Result
fi

# Delete OS fail (normal)
echo -n "Delete non-existent OS fail (normal)	:	" >> /tmp/Result
OS_TMP=OEMnone
OS_VER=osv0
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\"}"`
./oat_os -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

echo "******************Delete OS with checking boundary value*****************" >> /tmp/Result
# Delete OS with null string
echo -n "Delete OS with null string		:	" >> /tmp/Result
OS_TMP=""
OS_VER=""
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\"}"`
./oat_os -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

# Delete OS with edge length string
echo -n "Delete OS with edge length string	:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $5;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $5;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\"}"`
./oat_os -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

echo "******************Delete OS with checking special character**************" >> /tmp/Result
# Delete OS with special char
echo -n "Delete OS with special char		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $7;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $7;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\"}"`
./oat_os -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

echo "******************View OS************************************************" >> /tmp/Result
# View OS
echo -n "View OS				:	" >> /tmp/Result
./oat_view_os -h $HOST_NAME > /tmp/res
VIEW=`awk -F "\"" '{print $2;}' /tmp/res`
if [ "$VIEW" = "os" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi


echo "#The result about MLE" >> /tmp/Result
echo "******************Add MLE normal******************************************" >> /tmp/Result
# Add MLE successful (VMM)
echo -n "Add MLE successful (VMM)		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==8 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OsName\":\"$OS_TMP\",\"OsVersion\":\"$OS_VER\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"VMM\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add MLE fail (VMM)
echo -n "Add existed MLE fail (VMM)		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==8 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OsName\":\"$OS_TMP\",\"OsVersion\":\"$OS_VER\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"VMM\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add MLE successful (BIOS)
echo -n "Add MLE successful (BIOS)		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add MLE fail (BIOS)
echo -n "Add existed MLE fail (BIOS)		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add MLE fail with wrong mle type
OS_TMP=`awk 'NR==3 {print $3;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $3;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $3;}' commandtool.data`
MLE1_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE2_TMP=`awk 'NR==6 {print $2;}' commandtool.data`
MLE1_VER=`awk 'NR==7 {print $2;}' commandtool.data`
MLE2_VER=`awk 'NR==8 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO1=`echo "{\"Name\":\"$MLE2_TMP\",\"Version\":\"$MLE2_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"ODA\",\"Description\":\"$MLE_DESC\"}"`
INFO2=`echo "{\"Name\":\"$MLE1_TMP\",\"Version\":\"$MLE1_VER\",\"OsName\":\"$OS_TMP\",\"OsVersion\":\"$OS_VER\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"ODA\",\"Description\":\"Test\"}"`
echo -n "Add MLE fail (type is not BIOS)	:	" >> /tmp/Result
./oat_mle -a -h $HOST_NAME $INFO1 > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi
echo -n "Add MLE fail (type is not VMM)		:	" >> /tmp/Result
./oat_mle -a -h $HOST_NAME $INFO2 > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add MLE fail with non-existed OEM/OS
INFO1=`echo "{\"Name\":\"$MLE2_TMP\",\"Version\":\"$MLE2_VER\",\"OemName\":\"nexted1\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"ODA\",\"Description\":\"Test\"}"`
INFO2=`echo "{\"Name\":\"$MLE1_TMP\",\"Version\":\"$MLE1_VER\",\"OsName\":\"nexted2\",\"OsVersion\":\"$OS_VER\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"ODA\",\"Description\":\"Test\"}"`
echo -n "Add MLE fail with non-existed OEM	:	" >> /tmp/Result
./oat_mle -a -h $HOST_NAME $INFO1 > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi
echo -n "Add MLE fail with non-existed OS	:	" >> /tmp/Result
./oat_mle -a -h $HOST_NAME $INFO2 > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "*******************Add MLE with checking boundary value*************************" >> /tmp/Result
# Add MLE with checking boundary value
echo -n "Add MLE with null string		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"\",\"Version\":\"\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo -n "Add MLE with edge length string	:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $5;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $5;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo -n "Add MLE with over length string	:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $6;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $6;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo 
echo "*******************Add MLE with checking special character*************************" >> /tmp/Result
# Add MLE with checking special character
echo -n "Add MLE successful with special char	:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $7;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $7;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo -n "Add MLE fail with special char		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $8;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $8;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi


echo "*******************Edit MLE (Normal)********************************************" >> /tmp/Result
# Edit MLE successful (Normal)
echo -n "Edit MLE successful (normal)		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $3;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $3;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
MLE_DESC=`awk 'NR==12 {print $3;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
else
	echo echo "Failed" >> /tmp/Result
fi
	
echo -n "Edit MLE fail (normal)		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $4;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $4;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "*******************Edit MLE with checking boundary value***********************" >> /tmp/Result
# Edit existed MLE with null string
echo -n "Edit MLE with null string		:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $3;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $3;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"\"}"`
./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Edit existed MLE with edge string
echo -n "Edit MLE with edge length string	:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $3;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $3;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $5;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Edit existed MLE with over string
echo -n "Edit MLE with over length string	:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $3;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $3;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $6;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "*******************Edit MLE with checking special character***********************" >> /tmp/Result
# Edit MLE successful with special character
echo "Edit MLE successful with special char	:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $3;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $3;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $7;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Edit MLE fail with special character
echo "Edit MLE fail with special char		:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $3;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $3;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $8;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************Delete MLE Normal**********************************************" >> /tmp/Result
# Delete existent MLE successful
echo -n "Delete existent MLE successful		:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $4;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $4;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$MLE_DESC\"}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
else
	echo "Failed" >> /tmp/Result
fi

# Delete non-existent MLE fail
echo -n "Delete non-existent MLE fail		:	" >> /tmp/Result
MLE_TMP="MLEnone"
MLE_VER="mlev0"
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "*****************Delete MLE with checking boundary value********************" >> /tmp/Result
# Delete existed MLE with null string
echo -n "Delete existed MLE with null string	:	" >> /tmp/Result
MLE_TMP=""
MLE_VER=""
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Delete existed MLE with edge length string
echo -n "Delete MLE with edge length string	:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $5;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $5;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "*****************Delete MLE with checking special character*****************" >> /tmp/Result
# Delete existed MLE with special char
echo -n "Delete existed MLE with special char	:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $7;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $7;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "******************View/Search MLE********************************************" >> /tmp/Result
# View MLE (BIOS)
echo -n "View MLE (BIOS)			:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_view_mle -h $HOST_NAME $INFO > /tmp/res
grep "MLE_Type" /tmp/res > /dev/null
EID=$?
if [ $EID -eq 0 ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# View MLE (VMM)
echo -n "View MLE (VMM)			:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==8 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"osName\":\"$OS_TMP\",\"osVersion\":\"$OS_VER\"}"`
./oat_view_mle -h $HOST_NAME $INFO > /tmp/res
VIEW=`awk -F "\"" '{print $2;}' /tmp/res`
if [ "$VIEW" = "Attestation_Type" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Search MLE
echo -n "Search MLE (normal)			:	" >> /tmp/Result
./oat_mle_search -h $HOST_NAME '{MLE}' > /tmp/res
VIEW=`awk -F "\"" '{print $2;}' /tmp/res`
if [ "$VIEW" = "mleBean" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "#The result about PCR_WHITE_LIST" >> /tmp/Result
# Add a PCR successful
echo "******************Add PCR normal********************************************" >> /tmp/Result
echo -n "Add a PCR successful (normal)		:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $2;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Add a PCR fail which exists
echo -n "Add a PCR fail which exists		:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $2;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
		echo "Passed " >> /tmp/Result
	else
		echo "Failed " >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Add a PCR fail with non-exist MLE
echo -n "Add a PCR fail with non-exist MLE	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $2;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $4;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $4;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $4;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Add MLE with PCR
echo -n "Add MLE with PCR			:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $2;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $4;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $4;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"Test\",\"MLE_Manifests\":[{\"Name\":\"$PCR_NUM\",\"Value\":\"$PCR_VALUE\"}]}"`
./oat_mle -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "*******************Add PCR with checking boundary value**********************" >> /tmp/Result
# Add PCR with null string
echo -n "Add PCR with null string		:	" >> /tmp/Result
PCR_NUM=""
PCR_VALUE=`awk 'NR==10 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Add PCR with edge length string
echo -n "Add PCR with edge length string	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $5;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $5;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Add PCR with over length string
echo -n "Add PCR with over length string	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $6;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $6;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "*******************Add PCR with checking special character*******************" >> /tmp/Result
# Add PCR successful with special character
echo -n "Add PCR successful with special char	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $7;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $7;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`"  = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Add PCR fail with special character
echo -n "Add PCR fail with special char		:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $8;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $8;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`"  != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi
echo "******************Update PCR Normal****************************************" >> /tmp/Result
# Update existent PCR successful
echo -n "Update existent PCR successful		:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $3;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $3;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res
EID=$?
PCR_VALUE=`awk 'NR==10 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed " >> /tmp/Result
	else
		echo "Failed " >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed " >> /tmp/Result
	else
		echo "Failed " >> /tmp/Result
	fi
else
	echo "Failed " >> /tmp/Result
fi

# Update nonexistent PCR fail
echo -n "Update nonexistent PCR fail		:	" >> /tmp/Result
PCR_NUM=12
PCR_VALUE=`awk 'NR==10 {print $3;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Update all PCR which connect to one MLE record
echo -n "Update all PCR			:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $3;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $3;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
PCR2_NUM=`awk 'NR==9 {print $4;}' commandtool.data`
PCR2_VALUE=`awk 'NR==10 {print $4;}' commandtool.data`
INFO=`echo "{\"Name\":\"$MLE_TMP\",\"Version\":\"$MLE_VER\",\"OemName\":\"$OEM_TMP\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"Test\",\"MLE_Manifests\":[{\"Name\":\"$PCR_NUM\",\"Value\":\"$PCR_VALUE\"},{\"Name\":\"$PCR2_NUM\",\"Value\":\"$PCR2_VALUE\"}]}"`
./oat_mle -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "********************Update PCR with checking boundary value******************************" >> /tmp/Result
# Update PCR with null string
echo -n "Update PCR with null string		:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $3;}' commandtool.data`
PCR_VALUE=""
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Update PCR with edge length string
echo -n "Update PCR with edge length string	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $3;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $5;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Update PCR with over length string
echo -n "Update PCR with over length string	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $3;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $6;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "********************Update PCR with checking special character*********************" >> /tmp/Result
# Update PCR successful with special char
echo -n "Update PCR successful with special char:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $3;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $7;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Update PCR fail with special char
echo -n "Update PCR fail with special char	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $3;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $8;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "**********************Delete PCR Normal************************************************" >> /tmp/Result
# Delete PCR successful
echo -n "Delete PCR successful			:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $4;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $4;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_pcrwhitelist -d -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_pcrwhitelist -d -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
else
	echo "Failed" >> /tmp/Result
fi

# Delete PCR fail
echo -n "Delete PCR fail			:	" >> /tmp/Result
PCR_NUM=12222
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Delete PCR with MLE
echo -n "Delete PCR fail			:	" >> /tmp/Result
MLE_TMP=`awk 'NR==5 {print $3;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $3;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi


echo "**********************Delete PCR with checking boundary value***************************" >> /tmp/Result
# Delete PCR with null string
echo -n "Delete PCR with null string		:	" >> /tmp/Result
PCR_NUM=""
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Delete existed PCR with edge length string
echo -n "Delete PCR with edge length string	:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $5;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $5;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "**********************Delete PCR with checking special character**********************" >> /tmp/Result
# Delete PCR successful with special char
echo -n "Delete PCR successful with special char:	" >> /tmp/Result
PCR_NUM=`awk 'NR==9 {print $7;}' commandtool.data`
PCR_VALUE=`awk 'NR==10 {print $7;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"pcrDigest\":\"$PCR_VALUE\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -a -h $HOST_NAME $INFO
INFO=`echo "{\"pcrName\":\"$PCR_NUM\",\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_pcrwhitelist -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi


echo "#The result about HOST" >> /tmp/Result
echo "***********************Add Host Normal***************************************************" >> /tmp/Result
# Add Host successful
echo -n "Add Host successful			:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add Host fail (noraml)
echo -n "Add Host fail (normal)		:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_host -a -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_host -a -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
else
	echo "Failed" >> /tmp/Result
fi

# Add Host with nonexistent MLE
echo -n "Add Host with nonexistent MLE		:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $4;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $4;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $4;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $4;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result	
else
	echo "Failed" >> /tmp/Result
fi

echo "*********************Add Host with checking boundary value*****************************" >> /tmp/Result
# Add Host with null string
echo -n "Add Host with null string		:	" >> /tmp/Result
HOST_TMP=""
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add Host with edgelength string
echo -n "Add Host with edgelength string	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $5;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add Host with over length string
echo -n "Add Host with over length string	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $6;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "*********************Add Host with checking special character*****************************" >> /tmp/Result
# Add Host successful with special char
echo -n "Add Host successful with special char	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $7;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Add Host fail with special char
echo -n "Add Host fail with special char	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $8;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

echo "********************Edit Host Normal*************************************************" >> /tmp/Result
# Edit Host successful
echo -n "Edit Host successful			:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $3;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $3;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"$HOST_DESC\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_host -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_host -e -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed" >> /tmp/Result
	else
		echo "Failed" >> /tmp/Result
	fi
else
	echo "Failed" >> /tmp/Result
fi

# Edit Host fail
echo -n "Edit Host fail				:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $4;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $3;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.1\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "*********************Edit Host with checking boundary value******************************" >> /tmp/Result
# Edit HOST with null string
echo -n "Edit HOST with null string		:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $3;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.2\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"`
./oat_host -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

#Edit existed HOST with edge string
echo -n "Edit existed HOST with edge string	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $5;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.2\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"$HOST_DESC\"}"`
./oat_host -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Edit HOST with overlength string
echo -n "Edit HOST with overlength string	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $6;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.2\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"$HOST_DESC\"}"`
./oat_host -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "*********************Edit Host with checking special character*********************" >> /tmp/Result
# Edit HOST successful with special char
echo -n "Edit HOST successful with special char	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $7;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.2\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"$HOST_DESC\"}"`
./oat_host -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Edit HOST fail with special char
echo -n "Edit HOST fail with special char :       " >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $2;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $8;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.2\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"$HOST_DESC\"}"`
./oat_host -e -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "********************Delete Host Normal*****************************************" >> /tmp/Result
# Delete Host successful
echo -n "Delete Host successful			:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $4;}' commandtool.data`
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
VMM_TMP=`awk 'NR==7 {print $2;}' commandtool.data`
VMM_VER=`awk 'NR==8 {print $2;}' commandtool.data`
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
BIOS_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
BIOS_VER=`awk 'NR==6 {print $2;}' commandtool.data`
HOST_DESC=`awk 'NR==12 {print $2;}' commandtool.data`
INFO=`echo "{\"HostName\":\"$HOST_TMP\",\"IPAddress\":\"192.168.0.2\",\"Port\":\"8080\",\"BIOS_Name\":\"$BIOS_TMP\",\"BIOS_Version\":\"$BIOS_VER\",\"BIOS_Oem\":\"$OEM_TMP\",\"VMM_Name\":\"$VMM_TMP\",\"VMM_Version\":\"$VMM_VER\",\"VMM_OSName\":\"$OS_TMP\",\"VMM_OSVersion\":\"$OS_VER\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"$HOST_DESC\"}"`
./oat_host -a -h $HOST_NAME $INFO > /tmp/res
grep "error_message" /tmp/res > /dev/null
EID=$?
INFO=`echo "{\"hostName\":\"$HOST_TMP\"}"`
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	./oat_host -d -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed " >> /tmp/Result
	else
		echo "Failed " >> /tmp/Result
	fi
elif [ $EID -eq 0 ];then
	./oat_host -d -h $HOST_NAME $INFO > /tmp/res
	if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
		echo "Passed " >> /tmp/Result
	else
		echo "Failed " >> /tmp/Result
	fi
else
	echo "Failed " >> /tmp/Result
fi

# Delete Host fail
echo -n "Delete Host fail			:	" >> /tmp/Result
HOST_TMP=HOSTnone
INFO=`echo "{\"hostName\":\"$HOST_TMP\"}"`
./oat_host -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "********************Delete HOST with checking boundary value********************" >> /tmp/Result
# Delete HOST with null string
echo -n "Delete HOST with null string		:	" >> /tmp/Result
INFO=`echo "{\"hostName\":\"\"}"`
./oat_host -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

# Delete HOST with edge length string
echo -n "Delete HOST with edge length string	:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $5;}' commandtool.data`
INFO=`echo "{\"hostName\":\"$HOST_TMP\"}"`
./oat_host -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "********************Delete HOST with checking special character*****************" >> /tmp/Result
# Delete HOST with special char
echo -n "Delete HOST with special char		:	" >> /tmp/Result
HOST_TMP=`awk 'NR==11 {print $7;}' commandtool.data`
INFO=`echo "{\"hostName\":\"$HOST_TMP\"}"`
./oat_host -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" = "True" ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi

echo "********************Search HOST*************************************************" >> /tmp/Result
# Search HOST
echo -n "Search HOST				:	" >> /tmp/Result
./oat_host -s -h $HOST_NAME '{HOST}' > /tmp/res
grep "hostBean" /tmp/res > /dev/null
EID=$?
#VIEW=`awk -F "\"" '{print $2;}' /tmp/res`
if [ $EID -eq 0 ];then
	echo "Passed " >> /tmp/Result
else
	echo "Failed " >> /tmp/Result
fi


echo "********************Delete Data which is connected to other data****************" >> /tmp/Result

#Delete OS with connected MLE
echo -n "Delete OS with connected MLE		:	" >> /tmp/Result
OS_TMP=`awk 'NR==3 {print $2;}' commandtool.data`
OS_VER=`awk 'NR==4 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OS_TMP\",\"Version\":\"$OS_VER\"}"`
./oat_os -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

#Delete OEM with connected MLE
echo -n "Delete OEM with connected MLE		:	" >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
INFO=`echo "{\"Name\":\"$OEM_TMP\"}"`
./oat_oem -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk '$1 ~/True/' /tmp/res`" != "True" ];then
	echo "Passed" >> /tmp/Result
else
	echo "Failed" >> /tmp/Result
fi

# Delete MLE with connected HOST
echo -n "Delete MLE with connected HOST         :       " >> /tmp/Result
OEM_TMP=`awk 'NR==2 {print $2;}' commandtool.data`
MLE_TMP=`awk 'NR==5 {print $2;}' commandtool.data`
MLE_VER=`awk 'NR==6 {print $2;}' commandtool.data`
INFO=`echo "{\"mleName\":\"$MLE_TMP\",\"mleVersion\":\"$MLE_VER\",\"oemName\":\"$OEM_TMP\"}"`
./oat_mle -d -h $HOST_NAME $INFO > /tmp/res
if [ "`awk 'NR==3 $1 ~/True/' /tmp/res`" != "True" ];then
        echo "Passed" >> /tmp/Result
else
        echo "Failed" >> /tmp/Result
fi

#run over
echo "Run over, please check the result in file \"/tmp/Result\""
