---
layout: default
---

# Setting up Telegraf on a Windows Host for Grafana

Telegraf is a data collecting agent for metrics and data. For this tutorial we will be using it to monitor system resources via Windows Performance Counters.

## Downloading Telegraf for Windows

- First we need to download telegraf. We can do this by either navigating to [here](https://dl.influxdata.com/telegraf/releases/telegraf-1.9.4_windows_amd64.zip) or opening up Powershell and running the following command:

`wget https://dl.influxdata.com/telegraf/releases/telegraf-1.9.4_windows_amd64.zip -Outfile "C:\Users\<USERNAME>\Desktop\telegraf.zip"`

and then run:

`Expand-Archive -Path "C:\Users\<USERNAME>\Desktop\telegraf-1.9.4_windows_amd64.zip" -DestinationPath "C:\Users\<USERNAME>\Desktop\"`

> At the time of writing this guide, the released version of Telegraf is 1.9.4 for Windows. See [](https://portal.influxdata.com/downloads/) for the most recent versions.

## Configuring Telegraf

Now that Telegraf has been downloaded and extracted. We can begin the process of configuring Telegraf. So open up the telegraf folder on your desktop and then open the telegraf.conf file in your favorite editor. I recommend [Visual Studio Code](https://code.visualstudio.com/).

- First you will want to scroll till you see:

```conf
###############################################################################
#                                  OUTPUTS                                    #
###############################################################################
```

- And then find the lines with:

```conf
  # urls = ["unix:///var/run/influxdb.sock"]
  # urls = ["udp://127.0.0.1:8089"]
  # urls = ["http://127.0.0.1:8086"]
```

- Under the last `# urls =` create a new line with the following:

`url = "http://iptoinfluxdb:8086"`

- Uncomment out `# database = "telegraf"` just below the urls section

- Uncomment out `# skip_database_creation = false` as well.

> If you setup influxdb with a username and password you will have to scroll a little bit further and uncomment and edit the `## HTTP Basic Auth` section.

- Save the conf file.

## Running Telegraf

Now that Telegraf.conf has been configured we can now run Telegraf.

- First open a command prompt and navigate to the directory that has the .conf and .exe for Telegraf.

`cd C:\Users\<USERNAME>\Desktop\telegraf`

- Once there run the following to start Telegraf:

`telegraf.exe -quiet -config "C:\Users\<USERNAME>\Desktop\telegraf\telegraf.conf"`

> Note: If you close the CMD window, Telegraf will close and stop running.

## Adding Telegraf to Grafana

- Open Grafana and add a new data source for influxdb.

| Setting       | Value         |
| ------------- |:-------------:|
| Name          | Telegraf        |
| URL           | http://ip:8086 |
| Database      | telegraf        |

- Click Save & Test

> If you get an error, double check your data base connection info as most often not, its because of a typo! Otherwise verify the DB exists in Influx!

- Navigate to your Dashboard and click "Add panel" and select the SingleStat panel.

- Click Edit from the dropdown on the new SingleStat panel and click the Metrics tab.

- Set your data source to `telegraf` and then in the query field below enter the following:

| Query       | Value         |
| ------------- |:-------------:|
| A          | default "cpu" WHERE host = \<HOSTNAME> AND cpu = cpu-total |
| SELECT     | field (usage_idle) mean() math (*-1+100) |
| GROUP BY      | time ($interval) fill(null) |
| FORMAT AS | Time series |

- Click options tab

| Setting       | Value         |
| ------------- |:-------------:|
| Stat | Current |
| Unit | percent (0-100) |
| Value | Checked |
| Thresholds | 50,80,90 |
| Show (Under Gauge) | Checked |
| Min (Under Gauge) | 0 |
| Max (Under Gauge) | 100 |

- Click Back in the top right.

You now have a gauge that shows your cpu usage. You can get even fancier if you want with a Graph and show other cpu stats as well!

## Running Telegraf via Windows Task Scheduler

- General Tab
  - First open Task Scheduler
  - Click Task Scheduler Library
  - Click Create Task... in the right hand panel
  - Name = Telegraf
  - Select "Run whether user is logged on or not"
- Triggers Tab
  - Click New
    - New Trigger
      - Begin the Task: On Startup
      - Click OK
- Actions Tab
  - Click New
    - New Action
      - Action: Start a program
      - Program/script: "C:\location\of\telegraf.exe"
      - Add arguments: -quiet -config "C:\location\of\telegraf.conf"
      - Click OK
- Conditions Tab
  - Leave everything default
- Settings
  - Allow task to be run on demand: Checked
  - Run task as soon as possible.....: Checked
  - Stop the task if it runs longer than: UnChecked
  - If the task is already running......: Set to "Do not start a new instance"
- Click OK

Telegraf "should" now run at startup. If you want to start it now, highlight the task in the tasks list, right click, and click Run

> You can use the service install of Telegraf but you need to make sure your config file is in the proper Program Files directory and Telegraf has read permissions for that directory.

-----

# Setting up Telegraf on Linux

This section will go over setting up Telegraf to monitor your Linux hosts and if run Docker on them.

(WIP)

## Monitoring Linux Host Resources

- First we need to get the Telegraf deb installer package.

`cd /home/username && wget https://dl.influxdata.com/telegraf/releases/telegraf_1.9.4-1_amd64.deb`

- And then run dpkg to install telegraf.

`sudo dpkg -i telegraf_1.9.4-1_amd64.deb`

> You can get the latest version of Telegraf [here](https://portal.influxdata.com/downloads/). 1.9.4 was the latest at the time this guide was created.

- Now we need to setup the telegraf.conf file.

`sudo nano /etc/telegraf/telegraf.conf`

- Find and change the `[[outputs.influxdb]]` to your influxdb connection info and db name. (For this guide I just used the default "telegraf" db.).

- Save your changes and then run `sudo systemctl start telegraf.service` to start telegraf.

> If you wait a few seconds you can run `sudo systemctl status telegraf.service` to check the status of telegraf.

You should now have machine stats in your Influxdb from Telegraf. Panel setup is basically the same as the Windows guide except you need to omit the "win_" portion to your queries.

## Monitoring Docker Containers

You can monitor your docker system by enabling `[[inputs.docker]]` in your telegraf.conf file. 

> Note if it is a remote server you wish to monitor you will need to [enable the remote API for dockerd](https://success.docker.com/article/how-do-i-enable-the-remote-api-for-dockerd).

Edit your settings to how you want them and save the config file. Then run: 

`sudo usermod -aG docker telegraf` to allow Telegraf to interact with your docker.sock

Then start or restart telegraf.service:

`sudo systemctl start telegraf.service` or `sudo systemctl restart telegraf.service`

## Monitoring IPMI Enabled Servers

For this you will need two things:

1. A server that can be accessed over [IPMI](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface).
2. IPMITOOL needs to be installed.

### Installing IPMI

`sudo apt-get install ipmitool -y`

To check your server connection you can run:

`ipmitool -H 10.0.0.193 -U USR -P PW sensor`

Then enable [[inputs.ipmi_sensor]] in your Telegraf.conf file:

```conf
[[inputs.ipmi_sensor]]
path = "/user/bin/ipmitool"
servers = ["USERNAME:PASSWORD@lan(IP-OF-SERVER)"]
interval = "30s"
timeout = "20s"
metric_version = "SUPPORTED METRIC VERSION OF SERVER"
```

Save and close your file. Then run either:

`sudo systemctl start telegraf.service` or `sudo systemctl restart telegraf.service`

## Monitoring SNMP Devices

(WIP)

## Monitoring Ubiquiti Devices via MIB

(WIP)

----

--< [Back to Grafana](https://alexandzors.github.io/things/grafana)

--< [Back to landing page](https://alexandzors.github.io/things/)

