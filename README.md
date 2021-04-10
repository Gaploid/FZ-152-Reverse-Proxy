# FZ-152-Reverse-Proxy
That example will help you setup reverse proxy to catch private data and dump it in local database. This easy to go solution could make your web-service or web-site compliant with Federal Law FZ-152. 

:warning: Of course you will need to double check with legal if that solution will be suitable for your scenario. That solution is not certified in any official agencies and you should use it on your own risk.</u> 

## How it works
The Russiamn Federal Law 152-FZ said that data should be collected and other operations in Russia using databases during <b><u>ingestion</u></b>. <a href='http://www.consultant.ru/document/cons_doc_LAW_61801/cbf4e15b7c330f9372e876cdf2bc928bad7950ef/'>Here a link to that law. </a>

Therefore we just need to collect, update and keep it up-to-date in a database located in Russia. There are no requirements to format and structure that data. Based on these assumptions we could create a proxy service between a client (mobile app, app, web browser) and backend server (web-site, API and etc) that will catch incoming data and save it to a local database. Below you can find the architecture diagram of that scenario. 

<div style="text-align:center"><img src="./images/arch.png" width=500 /></div>

1. Route53 or any other DNS management system could route user requests based on their geo. In our case users from Russia should be routed at the first step to our Proxy server.
2. Save that data to the local file system and the local PostgreSQL database
3. Then forward traffic to the origin-destination URL, get a response and return it to the end-user.

For the end-user, that would be a transparent mechanism and you don't need to change anything on their end. To make it fully transparent you should own and have access to change A - records in your DNS name to add our proxy server for Russian users.


## Installation

1. Create a virtual machine and make it available to the internet, 
2. SSH to VM and execute `git clone https://github.com/Gaploid/FZ-152-Reverse-Proxy` 
3. Make the script executable `chmod +x install.sh`
4. Run script `sudo ./install.sh <incoming_domain> <url_to_forward_traffic>`
example: `sudo ./install.sh example.com http://example.com` where <incoming_domain> is facade DNS name for that virtual machine and <url_to_forward_traffic> is destination for the traffic. It should automatically install all dependencies and configure on behalf of you all components. You will need to answer "No" on that screen <img src="./images/screen1.png" width=500>
5. That's all. Now all traffic would be forwarded through that virtual machine and also all POST, DELETE, PUT requests will be saved in logs and in database: proxy_logs in table: accesslog. 

If you need SSL support for you Proxy then you should do these steps after:

0. Setup DNS to that machine to get an SSL certificate from let's encrypt. You will need to create <b>A - record</b> and point it to IP address to the newly created VM.

**NOTE**
Your server should be available on that stage by DNS name, cause Let's encrypt will check that.

1. run `./add_ssl.sh`
2. it will prompt questions regarding your new SSL certificate and ask on what endpoint you want add configuration. In our case that would be 'example.com' domain. 

## Thanks to these guides:
* nginx reverse proxy - https://www.scaleway.com/en/docs/how-to-configure-nginx-reverse-proxy/ 
* saving logs to PostgreSQL - https://www.shubhamdipt.com/blog/send-nginx-logs-to-sql-database/
