# Changelog

All notable introduced and planned changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2020-05-09

### Added

- Support for mount binding a crontab file so that the multiple regular rsync jobs (or just a single one) can be easier configured
- Support for remote sync with ssh

### Removed

- Running a single scheduled rsync job using cron and passing the cron job string specification as an environment variable - use a mount binded crontab file
- Passing the log file name as an environment variable - specify it now in the crontab file

## [0.1.0] - 2020-04-12

### Added

- Run an ontime rsync job with local folders
- Run an single scheduled rsync job using cron, provide the cron string as an environment variable
- Save the output of rsync in a log file, provide the log file name as na environment variable
