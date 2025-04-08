
🚀 Project Name : Vulturescan
===============

<p align="center">
<img src="./logo.jpg" width="120px">
</p>

#### Vulturescan : Vulscan but upgraded


![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-purple.svg)
<a href="https://github.com/gigachad80/vulturescan/issues"><img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat"></a>

### 📌 Overview
  
Vulturescan is a module which shows all vulnerabilities of a specified target, similar to the [vulscan](https://github.com/scipag/vulscan) module but with updated exploits. On running the script (bash / powershell), it downloads all current and previous exploits from ExploitDB. 

### 🤔 Why This Name?

Since I was developing an upgraded version of Vulscan, I wanted to give it a name similar to Vulscan, yet something sick and cool.
    

### ⌚ Total Time taken to build & test

 Approx 2 hr 20 min

### 🙃Why I Created This

The problem with Vulscan was that it hadn't been updated for many years. Neither the CSV files for CVE data nor the CSV files for ExploitDB were updated, and on top of that, its last commit was 7-8 years ago. So, I decided to develop a maintained and upgraded version.



### 📚  Requirements & Dependencies

* #### Lua Language  
* #### Nmap


### 📥 Installation Guide

Please install the files into the following folder of your Nmap installation:

    Nmap\scripts\vulturescan\*
    

Clone the GitHub repository like this:

    git clone https://github.com/gigachad80/vulturescan gigachad80_vulturescan
    ln -s `pwd`/gigachad80_vulturescan /usr/share/nmap/scripts/vulturescan

### 🐰 Usage

You have to run the following minimal command to initiate a simple vulnerability scan:

    nmap -sV --script=vulturescan/vulturescan.nse www.example.com

### 🔰 Vulnerability Database

There are the following pre-installed databases available at the moment:

* scipvuldb.csv - https://vuldb.com
* cve.csv - https://cve.mitre.org
* securityfocus.csv - https://www.securityfocus.com/bid/
* xforce.csv - https://exchange.xforce.ibmcloud.com/
* expliotdb.csv - https://www.exploit-db.com
* openvas.csv - http://www.openvas.org
* securitytracker.csv - https://www.securitytracker.com (end-of-life)
* osvdb.csv - http://www.osvdb.org (end-of-life)

### 🔰 Single Database Mode

You may execute vulturescan with the following argument to use a single database:

    --script-args vulturescandb=your_own_database

It is also possible to create and reference your own databases. This requires to create a database file, which has the following structure:

    <id>;<title>

Just execute vulturescan like you would by refering to one of the pre-delivered databases. Feel free to share your own database and vulnerability connection with me, to add it to the official repository.

### 🔰 Update Database

The vulnerability databases are updated and assembled on a regularly basis. To support the latest disclosed vulnerabilities, keep your local vulnerability databases up-to-date.

To automatically update the databases, simply set execution permissions to the `update.sh` file and run it:

    chmod +x update.sh
    ./update.sh

### 🔰 Version Detection

If the version detection was able to identify the software version and the vulnerability database is providing such details, also this data is matched.

Disabling this feature might introduce false-positive but might also eliminate false-negatives and increase performance slighty. If you want to disable additional version matching, use the following argument:

    --script-args vulturescan_vd=0

Version detection of vulturescan is only as good as Nmap version detection and the vulnerability database entries are. Some databases do not provide conclusive version information, which may lead to a lot of false-positives (as can be seen for Apache servers).

### 🔰 Match Priority

The script is trying to identify the best matches only. If no positive match could been found, the best possible match (with might be a false-positive) is put on display.

If you want to show all matches, which might introduce a lot of false-positives but might be useful for further investigation, use the following argument:

    --script-args vulturescan_all=1

### 🔰 Interactive Mode

The interactive mode helps you to override version detection results for every port. Use the following argument to enable the interactive mode:

    --script-args vulturescan_i=1

### 🔰 Reporting

All matching results are printed one by line. The default layout for this is:

    [{id}] {title}\n

It is possible to use another pre-defined report structure with the following argument:

    --script-args vulturescanoutput=details
    --script-args vulturescanoutput=listid
    --script-args vulturescanoutput=listlink
    --script-args vulturescanoutput=listtitle

You may enforce your own report structure by using the following argument (some examples):

    --script-args vulturescanoutput='{link}\n{title}\n\n'
    --script-args vulturescanoutput='ID: {id} - Title: {title} ({matches})\n'
    --script-args vulturescanoutput='{id} | {product} | {version}\n'

Supported are the following elements for a dynamic report template:

* {id} - ID of the vulnerability
* {title} - Title of the vulnerability
* {matches} - Count of matches
* {product} - Matched product string(s)
* {version} - Matched version string(s)
* {link} - Link to the vulnerability database entry
* \n - Newline
* \t - Tab

Every default database comes with an url and a link, which is used during the scanning and might be accessed as {link} within the customized report template. To use custom database links, use the following argument:

    --script-args "vulturescan_dblink=http://example.org/{id}"

### 🔰 Disclaimer

Keep in mind that this kind of derivative vulnerability scanning heavily relies on the confidence of the version detection of nmap, the amount of documented vulnerabilities and the accuracy of pattern matching. The existence of potential flaws is not verified with additional scanning nor exploiting techniques.



### 📝 Roadmap / To-do 

- [ ] Set auto-detection of JSON to CSV for latest CVEs. 
- [ ] Add CONTRIBUTING.md file
- [ ] Colored output 
- [ ] Update README 




### 💓 Credits:

* ####  Thanks to [@Rohan](http://github.com/Rohan-Katyal) for logo design
* #### Thanks to  [@scipag](https://github.com/scipag) & [@Marc](https://github.com/marcruef) for developing vulscan. Without them, this project wouldn't exist.
* #### Thanks to all firms for keeping us updated on exploits



### 📞 Contact


📧 Email: pookielinuxuser@tutamail.com


### 📄 License

Licensed under **GNU General Public License v3.0**

🕒 Last Updated: April 08, 2025 







