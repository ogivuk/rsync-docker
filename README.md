# rsync

rsync is an open source utility that provides fast incremental file transfer.

If you are into Dockerizing everything or you just want to have a better view
over the rsync process (e.g., to see it in your cluster visualizer),
this repository provides you with a Docker image to run the rsync process.

The provided image is open-source and built from scratch with the goal to
enable you to run a stateless and an immutable container, according to the best
practices.

With this image you can:

* run a simple one-time rsync job for local drives
* run a rsync job for remote drives using ssh (included in the image)
* run scheduled rsync jobs using cron (included in the image)

Supported architectures:

* the image supports multiple architectures: `x86-64` and `arm32`
* the docker manifest is used for multi-platform awareness
* by simply pulling or running `ogivuk/rsync:latest`, the correct image for your architecture will be retreived

| Tag | Transmission Version and Architecture |
| :--- | :----    |
| `:latest` | supports both `x64` and `arm32v7` architectures |
| `:x64` | targeted to the `x64` architecture |
| `:arm32v7` | targeted to the `arm32v7` architecture |

The image is based on `alpine` image and it includes:

* `rsync`
* `openssh-client` for remote sync over ssh
* `tzdata` for easier setting up of local timezone (for file timestamps)
* `cron` (included in the alpine) for scheduling regular back-ups
* `rsync.sh` script that prepares the cron job and starts the cron daemon

## Usage

### Quick Start: one time run and sync of local folder

```bash
docker run --rm \
    --name=rsync \
    --volume /path/to/source/data:/data/src \
    --volume /path/to/destination/data:/data/dst \
    ogivuk/rsync [OPTIONS] /data/src/ /data/dst/
```

Replace:

* `/path/to/source/data` with the source folder to be copied or backed-up
* `/path/to/destination/data` with the destination folder
* `[OPTIONS]` with desired rsync optional arguments

### Use with cron or ssh

#### Step 1. Prepare the setup (_First time only_)

* create a folder, for example `~/rsync`, that will be later mounted in the container
  * this folder is intended to hold supporting files such as log files, crontab file, and any supporting rsync files (e.g., list of files to rsync)
  * the subfolder `logs`, for example `~/rsync/logs` is suggested for the log files
  * important note: for Docker Swarm, this directory **needs to be available on all nodes in Docker swarm**, e.g., via network shared storage

  ```bash
  mkdir -p ~/rsync/logs
  ```

  * you can replace `~/rsync` with any other desired location

#### Step 2. Run

* run as a container:

  ```bash
  docker run --rm \
      --name=rsync \
      --env TZ="Europe/Zurich" \
      --env RSYNC_CRONTAB="crontab" \
      --volume ~/rsync:/rsync
      --volume /path/to/source/data:/data/src \
      --volume /path/to/destination/data:/data/dst \
      ogivuk/rsync
  ```

* run as a swarm service:

  ```bash
  docker service create \
      --name=rsync \
      --env TZ="Europe/Zurich" \
      --env RSYNC_CRONTAB="crontab" \
      --mount type=bind,src=~/rsync,dst=/rsync \
      --mount type=bind,src=/path/to/source/data,dst=/data/src \
      --mount type=bind,src=/path/to/destination/data,dst=/data/dst \
      ogivuk/rsync
  ```

| Parameter | Explanation | When to Use |
| :-------- | :---------- | :---------- |
| `--env TZ="Europe/Zurich"` | Sets the timezone in the container, which is important for the correct timestamping of logs. Replace `Europe/Zurich` with your own timezone from the list of available [timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). | Always |
| `--env RSYNC_CRONTAB="crontab"` | Specifies that the rsync is to be run as one or multiple cron jobs, and that the jobs are defined in the `crontab` file located in the mount-binded `~/rsync` folder. The rsync parameters used in the crontab must be mindful of the data locations in the container. | When using cron for regular rsync jobs |
| `~/rsync` | Specifies the local folder `~/rsync` that is mounted to the container at `/rsync`. Change `~/rsync` if another location is chosen in Step 1. | When using cron or ssh |
| `/path/to/source/data` | Specifies the source folder for sync and is mounted to the container at `/data/src`. Change to the appropriate folder. Multiple folders can be mounted in this way. | If any source is local |
| `/path/to/destination/data` | Specifies the destination folder for sync and is mounted to the container at `/data/src`. Change to the appropriate folder. Multiple folders can be mounted in this way. | If any destination is local |
| `--env RSYNC_UID=$(id -u)` | Provides the UID of the user starting the container so that the ownership of the files that rsync copies belong to that user. | If the rsync option for preserving ownership is not selected |
| `--env RSYNC_GID=$(id -g)` | Provides the GID of the user starting the container so that the ownership of the files that rsync copies belong to that user group. | If the rsync option for preserving ownership is not selected |

Remarks:

* **rsync will not be run by default**, you need to be specify the rsync command with all its arguments in the crontab, or in a script called in the crontab
* **any later changes to the crontab file require the service to be restarted**, and that's why consider to define the rsync job in a script that is called in the crontab
* when defining the rsync arguments, including source and destination, do that from the perspective of the container (/data/src, /data/dst)
* more volumes can be mount binded if needed
* the ssh client is included in the image in case your source or destination is a remote host
  * ssh required files (private key, known_hosts, ssh_config) needs to be stored in a folder mounted to the container, for example in `~/rsync/ssh/`
  * you can define the ssh connection in a `ssh_config` file
  * rsync option `-e "ssh -F /rsync/ssh/ssh_config"` instructs rsync to use the ssh with the `ssh_config` for the remote sync
