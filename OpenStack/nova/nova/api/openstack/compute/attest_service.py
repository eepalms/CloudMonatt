#!/usr/bin/python
#
#    This file is used to send attestation requests to the compute node periodically based on the customer's requests.
#    Every miniute it will check the database and update the customer's request. The unit of the time interval for the customer's requests should be miniute.
#    Execute ./oat_cert -h <Attestation Client> first to generate the <Attestation Client>_certfile.cer. Then put the <Attestation Client>_certfile.cer into the same directory as this script.
#    The actual command is: curl --cacert certfile.cer -H "Content-Type: application/json" -X POST -d '{"hosts":["nebula1"]}' "https://nebula1:8443/AttestationService/resources/PollHosts" -ssl3
#
#

import os
import time
import sys
import MySQLdb

OAT_SERVER='nebula1'
PORT='8443'
DELAY_TIME=10

# This is the command to execute the attestation service.
# curl --cacert certfile.cer -H "Content-Type: application/json" -X POST -d '{"hosts":["nebula1"], "property":["1"], "id":["abcdefab"]}' "https://nebula1:8443/AttestationService/resources/PollHosts" -ssl3

def execute_cmd(machine, vm, security_property):
    machine_info = '["' + machine + '"]'
    vm_info = '["' + vm + '"]'
    property_info = '["' + security_property + '"]'
    url_info = '"https://' + OAT_SERVER + ':' + PORT + '/AttestationService/resources/PollHosts" '
    cert_info = '/opt/stack/certfile.cer'

    cmd = 'curl ' + '--cacert ' + cert_info + ' -H "Content-Type: application/json" ' + '-X POST' + ' -d' + """ '{"hosts":""" + machine_info + ', "id":' + vm_info + ', "property":'+ property_info + "}' " + url_info + '-ssl3'
    result = os.popen(cmd)
    return result.read()


def attestation_service(uuid, security_property):

    db = MySQLdb.connect(host="localhost", port = 3306, user= "root", passwd="password", db="nova")
    cursor = db.cursor()
    cursor.execute("""SELECT protection, host, uuid FROM instances WHERE uuid=%s""", (uuid))
    results = cursor.fetchall()
    cursor.close()
    db.close()
    machine_id = results[0][1]

    # Initialize the attestation
    if security_property > 4:
        _property = str(security_property) + "1"
        execute_cmd(machine_id, uuid, _property)
        time.sleep(DELAY_TIME)


    while (True):
        db = MySQLdb.connect(host="localhost", port = 3306, user= "root", passwd="password", db="nova")
        cursor = db.cursor()
        cursor.execute("""SELECT protection, host, uuid FROM instances WHERE uuid=%s""", (uuid))
        results = cursor.fetchall()
        cursor.close()
        _protection = results[0][0][security_property-1]
        machine_id = results[0][1]

        if (_protection == "1"):
            output = execute_cmd(machine_id, uuid, str(security_property))
            attest_result = False
            for element in output.split('"'):
                if (element == 'trusted'):
                    attest_result = True
                    break
                if (element == 'untrusted'):
                    attest_result = False

            if attest_result == False:
                cursor = db.cursor()
                cursor.execute("""SELECT protection_results, uuid FROM instances WHERE uuid=%s""", (uuid))
                results = cursor.fetchall()
                cursor.close()

                old_protection_results = "0 0 0 0 0 0 0"
                if not results[0][0] == None:
                    old_protection_results = results[0][0]
                new_protection_results = old_protection_results.split()
                value = int(new_protection_results[security_property-1])
                new_protection_results[security_property-1] = str(value+1)
                new_protection_results_string = ' '.join(new_protection_results)

                cursor = db.cursor()
                cursor.execute("""UPDATE instances SET protection_results=%s WHERE uuid=%s""", (new_protection_results_string, uuid))
                db.commit()
                cursor.close()
                db.close()

            time.sleep(DELAY_TIME)
        else:
            # Initialize the attestation
            if security_property > 4:
                _property = str(security_property) + "2"
                execute_cmd(machine_id, uuid, _property)

            cursor = db.cursor()
            cursor.execute("""SELECT protection_results, uuid FROM instances WHERE uuid=%s""", (uuid))
            results = cursor.fetchall()
            cursor.close()
        
            old_protection_results = results[0][0]
            new_protection_results = old_protection_results.split()
            new_protection_results[security_property-1] = "0"
            new_protection_results_string = ' '.join(new_protection_results)

            cursor = db.cursor()
            cursor.execute("""UPDATE instances SET protection_results=%s WHERE uuid=%s""", (new_protection_results_string, uuid))
            db.commit()
            cursor.close()
            db.close()
            break
