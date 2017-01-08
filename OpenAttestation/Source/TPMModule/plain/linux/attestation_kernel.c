#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <openssl/md5.h>
#include <errno.h>
#include <libvirt/libvirt.h>

#define FILE_LOCATION "/root/tpm-emulator/PCR_VALUE"
#define IMAGE_LOCATION "/opt/stack/data/nova/instances/"

// Compile: gcc -o attestation_kernel attestation_kernel.c -lcrypto -lssl

char file_address[256];
FILE *image_file;
char cmd_line[256];
int bin[30];

static int convert_name(char *uuid, char *name) {
    virConnectPtr conn = NULL;
    virDomainPtr dom = NULL;

    conn = virConnectOpenReadOnly(NULL);
    if (conn == NULL) {
        fprintf(stderr, "Failed to connect to hypervisor\n");
        goto error;
    }

    dom = virDomainLookupByUUIDString(conn, uuid);
    if (dom == NULL) {
        fprintf(stderr, "Failed to find Domain %s\n", uuid);
        goto error;
    }

    strcpy(name, virDomainGetName(dom));
    return 0;
error:
    if (dom != NULL)
        virDomainFree(dom);
    if (conn != NULL)
        virConnectClose(conn);
    return -1;
}

int monitor_integrity(char *uuid) {
    char cursor;

    strcpy(file_address, IMAGE_LOCATION);
    strcat(file_address, uuid);
    strcat(file_address, "/kernel");

    image_file = fopen(file_address, "rb");
    assert(image_file);

    MD5_CTX mdContext;
    int bytes;
    char image_value[1024];
    unsigned char hash_value[MD5_DIGEST_LENGTH];
    char per_value;

    MD5_Init(&mdContext);
    while ((bytes = fread(image_value, 1, 1024, image_file))!=0)
        MD5_Update(&mdContext, image_value, bytes);

    fclose(image_file);
    MD5_Final(hash_value, &mdContext);

    image_file = fopen(FILE_LOCATION, "r+");
    assert(image_file);

    int i = 0;
    while (i<= 1) {
        cursor = fgetc(image_file);
        if (cursor == ':')
            i++;
    }
    int j;
    for (j=0; j<MD5_DIGEST_LENGTH; j++) {
        sprintf(&per_value, "%02x", hash_value[j]);
        fputc(per_value, image_file);
        if ((j%2) == 1)
            fputc(' ', image_file);
    }
    fclose(image_file);
    return 0;
}


int monitor_availability(char *uuid) {

    char instance_name[256];
    int ret1 = convert_name(uuid, instance_name);

    char cursor;
    int i;
    char *ret;
    ssize_t read;
    size_t len = 0;
    if (ret1 == 0) {
        strcpy(cmd_line, "xentop -f -d1 -bi2 | awk '$1 == \"");
        strcat(cmd_line, instance_name);
        strcat(cmd_line, "\" { print $4 }'");
        image_file = popen(cmd_line, "r");
        fgets(ret, 20, image_file);
        fgets(ret, 20, image_file);
        pclose(image_file);

        image_file = fopen(FILE_LOCATION, "r+");
        i = 0;
        while (i<= 2) {
            cursor = fgetc(image_file);
            if (cursor == ':')
                i++;
        }

        if (ret[1] == '.') {
            fputc('0', image_file);
            fputc(ret[0], image_file);
        }
        else if (ret[2] == '.') {
            fputc(ret[0], image_file);
            fputc(ret[1], image_file);
        }
        else {
            fputc('9', image_file);
            fputc('9', image_file);
        }

        fclose(image_file);
    }
    
    return 0;
}

int monitor_confidentiality(char *uuid) {

    char instance_name[256];
    int ret1 = convert_name(uuid, instance_name);

    int index;
    int sum = 0;
    char cursor;
    int i;
    char *ret;
    ssize_t read;
    size_t len = 0;
    char *line = NULL;
    if (ret1 == 0) {
        image_file = popen("xentrace -D -e 0x2f000 -T 1 temp_res", "r");
        pclose(image_file);
        strcpy(cmd_line, "cat temp_res | xentrace_format formats | grep switch_infprev | grep ");
        strcat(cmd_line, instance_name);
        image_file = popen(cmd_line, "r");

        while ((read = getline(&line, &len, image_file)) != -1) {
            if (line=strstr(line, "runtime")) {
                ret = strtok(line, "=");
                ret = strtok(NULL, "=");
                ret = strtok(ret, "]");
                
                index = atoi(ret)/1000000;
                if (index >= 30)
                    index = 29;
                bin[index] ++;
                sum ++;
            }
        }
        pclose(image_file);
    }

    image_file = fopen(FILE_LOCATION, "r+");
    assert(image_file);

    i = 0;
    while (i<= 3) {
        cursor = fgetc(image_file);
        if (cursor == ':')
            i++;
    }
    int j;
    char per_value;
    for (j=0; j<30; j++) {
        if (sum == 0) {
            fputc('0', image_file);
            fputc('0', image_file);
        }
        else if (bin[j] < sum) {
            sprintf(&per_value, "%d", bin[i]*10/sum);
            fputc(per_value, image_file);
            sprintf(&per_value, "%d", bin[i]*100/sum);
            fputc(per_value, image_file);
        }
        else {
            fputc('9', image_file);
            fputc('9', image_file);
        }
        if (j == 19) {
            do {
                cursor = fgetc(image_file);
            } while (cursor != ':');
        }
        else {
            fputc(' ', image_file);
        }
    }

    fclose(image_file);

    return 0;
}

int main(int argc, char *argv[])
{
    if (strncmp(argv[2], "FFFFFFFF", 100) == 0)
        return 0;
    int pcr_index = atoi(argv[2]);

    memset(file_address, '\0', sizeof(char)*256);
    memset(cmd_line, '\0', sizeof(char)*256);
    int i;
    for (i=0; i<30; i++)
        bin[i] = 0;

    if (pcr_index == 1)
        monitor_integrity(argv[1]);
    else if (pcr_index == 2) 
        monitor_availability(argv[1]);

    else if (pcr_index == 3)
        monitor_confidentiality(argv[1]);

    return 0;
}
