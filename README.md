Hydra Upscaler
==============

[![pipeline status](https://gitlab.com/telyn/hydra-upscaler/badges/master/pipeline.svg)](https://gitlab.com/telyn/hydra-upscaler/commits/master) [![coverage report](https://gitlab.com/telyn/hydra-upscaler/badges/master/coverage.svg)](https://gitlab.com/telyn/hydra-upscaler/commits/master)

Hydra upscaler is a distributed system to run an entire video through
waifu2x whenever you leave your waifu2x-capable machine(s) on.

It's intended for home upscaling rather than enterprise, where upscaling a
single video could take a week or more using the idle time of a desktop PC
with a single, moderately capable GPU.

Installation
============

Simplified install & usage instructions will become available once the project
is further along.

Manual Install
==============

**Important note!** Hydra upscaler is **NOT READY FOR USE** - most of these
instructions are assuming I've implemented bits I haven't (loading config files,
the `hydra` executable at all, authentication at all)

Prerequisites
-------------

* Set up a minio (or other s3-compatible) server or an AWS S3 account
* Set up a Zeebe server
* Your splitter and merger machines will need ffmpeg in the PATH
* Your upscaler machine must be a linux machine with docker installed. Ideally
  it should have a CUDA-capable graphics card.

Workers
-------

```sh
gem install hydra-upscaler-workers
```

Then to run each worker in the foreground, run the following in different
shells. Replace localhost:26501 with the gateway URL of your Zeebe server.
```sh
hydra worker:splitter
hydra worker:merger
hydra worker:upscaler
```

For a proper deploy, write init scripts / systemd units. Systemd units will
eventually be packaged with the gem and I'll add a command for installing them.

Client
------

Create a `$HOME/.hydrarc` file like this (should only be readable by your user since it contains your S3 login):

```yaml
zeebe:
  url: localhost:26501
s3:
  url: localhost:9000
  access_key: my_access_key_here
  secret_key: my_secret_key_here
```

Then run these commands to upscale a 

```sh
gem install hydra-upscaler-client
hydracli deploy # you only need to do this once ever, to deploy the hydra
                # workflow to Zeebe
hydracli upscale /path/to/video_file.mp4
```

Development
===========

I run Zeebe in docker and haven't got round to s3 integration quite yet.

```console
$ bundle install
$ docker run -it --rm -p 26500:26500 camunda/zeebe:0.15.1
$ bundle exec rspec
```

Personally, I use guard to automatically rerun relevant tests when I save files.

```console
$ bundle exec guard
```

and edit files as normal in a different terminal.
