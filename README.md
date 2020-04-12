# rsync

rsync is an open source utility that provides fast incremental file transfer.

If you are into Dockerizing everything or you just want to have a better view
over the rsync process (e.g., to see it in your cluster visualizer),
this repository provides you with a Docker image to run the rsync process.

The provided image is open-source and built from scratch with the goal to
enable you to run a stateless and an immutable container, according to the best
practices.

Supported architectures:

* the image supports multiple architectures: `x86-64` and `arm32`
* the docker manifest is used for multi-platform awareness
* by simply pulling or running `ogivuk/rsync:latest`, the correct image for your architecture will be retreived

| Tag | Transmission Version and Architecture |
| :--- | :----    |
| `:latest` | supports both `x64` and `arm32v7` architectures |
| `:x64` | targeted to the `x64` architecture |
| `:arm32v7` | targeted to the `arm32v7` architecture |

## Usage

### Quick Start: one time run, local, no logs

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

### Start with All Options Explained

1. _First time only_: Prepare the setup
    * create a folder, for example `~/rsync`, that will be later mounted in the container
      * this folder is intended to hold supporting files such as log files, a list of files to rsync, a file with exclude patterns, etc.
      * the subfolder `logs`, for example `~/rsync/logs` is intended for the log files
      * important note: for Docker Swarm, this directory **needs to be available on all nodes in Docker swarm**, e.g., via network shared storage

      ```bash
      mkdir -p ~/rsync/logs
      ```

      * replace `~/rsync` with any other desired location

2. Start
    * as a container:

        ```bash
        docker run --rm \
            --name=rsync \
            -e TZ="Europe/Zurich" \
            -e RSYNC_LOG="rsync" \
            -e RSYNC_CRON="* 5 * * *" \
            --volume ~/rsync:/rsync
            --volume /path/to/source/data:/data/src \
            --volume /path/to/destination/data:/data/dst \
            ogivuk/rsync [OPTIONS] /data/src/ /data/dst/
        ```

        * Replace:
          * `~/rsync/` with a folder created in the step 1. (if another is chosen)
          * `/path/to/source/data` with the source folder to be copied or backed-up
          * `/path/to/destination/data` with the destination folder
          * `[OPTIONS]` with desired rsync optional arguments
    * as a swarm service:

        ```bash
        docker service create \
            --name=rsync \
            -e TZ="Europe/Zurich" \
            -e RSYNC_LOG="rsync" \
            -e RSYNC_CRON="0 5 * * *" \
            --mount type=bind,src=~/rsync,dst=/rsync \
            --mount type=bind,src=/path/to/source/data,dst=/data/src \
            --mount type=bind,src=/path/to/destination/data,dst=/data/dst \
            ogivuk/rsync [OPTIONS] /data/src/ /data/dst/
        ```

        * Replace:
          * `~/rsync/` with a folder created in the step 1. (if another is chosen)
          * `/path/to/source/data` with the source folder to be copied or backed-up
          * `/path/to/destination/data` with the destination folder
          * `[OPTIONS]` with desired rsync optional arguments

Parameters

| Parameter | Function |
| ---       | -------  |
| `-e TZ="Europe/Zurich"` | Sets the timezone in the container, which is important for the correct timestamping of logs. Replace `Europe/Zurich` with your own timezone from the list of available [timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). |
| `-e RSYNC_LOG="rsync"` | Enables the logging or the rsync output. The provided value will be the prefix for the log file name which is appended with the date and time of the rsync execution, e.g., `rsync.20200101-12:34.log`. |
| `-e RSYNC_CRON=1` | Specifies that the rsync is to be run as a cron job. The provided value needs to be a cron expression describing when to run the rsync job, and this expression will be appended to the crontab. |
