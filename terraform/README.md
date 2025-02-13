# Azure SQL connection with managed identity

## Run terraform

```shell
$ terraform init
$ terraform plan -out main.tfplan
$ terraform apply "main.tfplan"
```

## Import keys for created infra

After the terraform run, some useful bits of information will be stored in `locafiles/` directory. The 
`read_data.sh` script will collect them in `localdev/env.sh` file.

```shell
$ read_data.sh
$ source localfiles/env.sh
```

This will set:

- ADMIN_LOGIN
- ADMIN_PASSWORD
- RESOURCE_GROUP_NAME
- PUBLIC_IP_ADDRESS
- DBSERVER
- DBNAME
- SQLADMIN_NAME
- SQLADMIN_PASSWORD
- MINAME

## Login to VM

Source the file `localfiles/env.sh`. Copy a couple of files to the VM (they will make life easier), login to the VM
and source the remove copy of the file:

```shell
$ source localfiles/env.sh
$ scp -i localfiles/private_key.pem localfiles/create_user.sql azureadmin@${PUBLIC_IP_ADDRESS}:/home/azureadmin/create_user.sql
$ scp -i localfiles/private_key.pem localfiles/env.sh azureadmin@${PUBLIC_IP_ADDRESS}:/home/azureadmin/env.sh
$ ssh -i localfiles/private_key.pem azureadmin@${PUBLIC_IP_ADDRESS}
azure-linux-vm $ source env.sh
```

## VM Setup

Download and extract GoLang version of `sqlcmd` and rename it to `gsqlcmd` to avoid confusion.

```shell
sudo apt-get update
wget https://github.com/microsoft/go-sqlcmd/releases/download/v1.8.2/sqlcmd-linux-amd64.tar.bz2
sudo apt-get install bzip2
tar jxfv sqlcmd-linux-amd64.tar.bz2
mv sqlcmd gsqlcmd
```

### Install ODBC SQLCMD (optional)

ODBC `sqlcmd` is not used in futher actions, but it's here for completeness.

```shell
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install mssql-tools18
export PATH=/opt/mssql-tools18/bin:$PATH
```

### Install dev tools if needed (optional)

For Python/postgres development:
```shell
sudo apt-get -y build-essential postgresql-common libpq-dev python3-dev python3.12-venv
```

For Java/Scala development:
```shell
sudo apt-get -y install openjdk-11-jdk
```

### Check token (optional)

To see a token for the managed identity assigned to the VM, you can run

```shell
curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://database.windows.net' -H Metadata:true 
```

### Put token into a file (optional)

There are unconfirmed rumors that ODBC sqlcmd can use the token if it's coverted into a file in UTF-16LE encoding.

```shell
curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://database.windows.net' -H Metadata:true | jq -r '.access_token' | iconv -f ascii -t UTF-16LE > tokenfile
```

## Connect to SQL instance as Admin and create user for managed identity

```shell
$ ./gsqlcmd -G -U $SQLADMIN_NAME -P "$SQLADMIN_PASSWORD" -S $DBSERVER -d $DBNAME -i create_user.sql
```

This will produce no output if successful.

To check that the user was created:

```shell
$ ./gsqlcmd -G -U $SQLADMIN_NAME -P "$SQLADMIN_PASSWORD" -S $DBSERVER -d $DBNAME
1> select name, type_desc from sys.database_principals where name='<managed-identity-name>';
2> go
name                                                                                                                             type_desc                                                   
-------------------------------------------------------------------------------------------------------------------------------- ------------------------------------------------------------
mi-racer-uai1                                                                                                                    EXTERNAL_USER                                               

(1 row affected)
```

## Connect to Azure SQL with the managed identity

```shell
$ ./gsqlcmd -S $DBSERVER -d $DBNAME --authentication-method ActiveDirectoryManagedIdentity
1> select 1;
2> go
           
-----------
          1

(1 row affected)
```
