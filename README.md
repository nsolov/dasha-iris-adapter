# Dasha.ai and IRIS integration example

[Dasha.ai](https://dasha.ai) is a platform for designing human-like voice interactions to automate business processes.

This repository includes the first version of Dasha.ai IRIS Interoperability Adapter and demo Interoperability Production 
to show how to connect IRIS and Dasha.ai platform.

This demo implements two scenarios:

* Appointment to a doctor using Dasha.ai robot.
In this case a patient calls by phone (+1 205-506-3155), talks to the Dasha.ai robot and then dasha.ai using a webhook sends all the patient data into IRIS. 

* CSI and NPS survey
IRIS sends a list of patient’s phone numbers to Dasha.ai, using DashaAPI, creates conversations and starts them (insert into the queue).
Dasha.ai calls these patients, obtains the survey results and sends the results to IRIS using webhook. 


Before installation please contact Dasha.ai.



Steps to make it working:

### 1. Obtain domain name and have 'A' DNS-record that points to your's instance IP

We assume that you already have registered a domain and one of your DNS-record points 
to instance IP. If not, you can use any of public domain registrars (like, [Godaddy](https://godaddy.com)).

### 2. Obtain SSL-certificate to use it for encrypt client-server traffic

If you already have certificate, remember paths to certificate as well as private key and skip this section.
Otherwise, this is an example for Ubuntu 18.04 of how you can do it via [Let's Encrypt](https://letsencrypt.org/) and [Certbot](https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx).

**Note** : domain name used in example is `example.com`. You should use your real domain name instead.

```
ssh <ubuntu_ip_address>

sudo apt-get update

sudo apt-get install -y nginx certbot python-certbot-nginx

sudo systemctl start nginx

# Be sure that port 80 is opened for 0.0.0.0/0 on firewall

sudo certbot --nginx -d example.com

# Answer questions and wait a little for domain verification from Let's Encrypt side
```

Note the latest lines:

```
IMPORTANT NOTES:
- Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/example.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/example.com/privkey.pem
   Your cert will expire on 2019-12-08. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"

```
Remember 2 paths:

- /etc/letsencrypt/live/example.com/fullchain.pem - **certificate**

- /etc/letsencrypt/live/example.com/privkey.pem - **private key**

These paths will be used later when configuring IRIS bootstrap procedure.

Disable nginx service. We've used it to obtain SSL-certificate and don't need it anymore.

```
sudo systemctl stop nginx
sudo systemctl disable nginx
```

### 3. Install Docker and Docker-compose.

In case of Ubuntu use the following steps: [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) and [Docker-compose](https://docs.docker.com/compose/install/)

### 4. Run IRIS and Nginx

```
./app start
```

### 5. Example. Steps 3 and 4 for Ubuntu 18.04

```
ssh <ubuntu_ip_address>

mkdir ~/demo

cd ~/demo

<load_targz_archive and unpack it> # (curl, wget, git clone etc.)

# Install Docker and Docker-compose (if needed)

chmod +x tools/install-docker-ubuntu

tools/install-docker-ubuntu

# Set domain name, certificate path and private key path in `vars` file

./app start
```

**Note:**

Credentials to IRIS is `_system/newpass`

### 6. Check connectivity to REST endpoint

**Note:** Be sure that port 443 is opened on firewall

```
curl https://example.com/dasha/
```

It should return `It works from IRIS!`

### 7. Check logs of application

Last 10 log lines from IRIS container:

`./app iris-logs`

Last 10 log lines from Nginx container:

`./app nginx-logs`

### 8. Configure Interoperability Production

#### 8.1. Login into IRIS 

https://example.com/csp/sys/%25CSP.Portal.Home.zen
Credentials to IRIS is `_system/newpass`

#### 8.2. Add credentials

In Interoperability section choose DASHA namespace and add credentials
Please contact Dasha.ai to get credentials

#### 8.3. Restart DashaDemo.Ens.Production

Using Production Congiguration page open Production DashaDemo.Ens.Production.
In DashaOperation settings specify 
* Credentials 
* Callback URL - don't forget to change your domain https://example.com/dasha/nps 

Restart the Production

### 9. UI

Open https://example.com/index.html - the list of the appointments.
To make an appointment call to the phone (ask phone number for your instance from Dasha.ai)

### 8. Stop application

./app stop
