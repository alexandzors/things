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

`urls = ["http://iptoinfluxdb:8086"]`

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

-----

--< [Back to Grafana](https://alexandzors.github.io/things/grafana)

--< [Back to landing page](https://alexandzors.github.io/things/)
