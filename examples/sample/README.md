# WABuR Sample

This simple example demonstrates the use of a WAB Controller to orchestrate
a request made for data. It is the most straight forward use of the WAB gem.

## Setting up

The `script` directory at the root of the repository contains several script
files to easily get started with serving the Sample App.

**Note:** *All scripts are recommended to be run from the root of the
repository unless otherwise stated.*

If you have the Bundler gem installed, run the following in your terminal to
install all the necessary dependencies:

```sh
$ script/setup
```

## Usage

The Sample App can be tested on a local browser with Javascript enabled, and
can be served with choice between the following runners:

  * a pure [Ruby Runner](#ruby-runner), built using `WEBrick`
  * a high-performance spawning/forking runner written in C, [OpO](#opo) (*Not supported on Windows*).
  * a high-performance embedded Ruby runner written in C, [OpO-Rub](#opo-rub) (*Not supported on Windows*).

Additionally, the files necessary to render the App view needs to be compiled
from their source. The source files are located in the [`view`](../../view)
directory, and they get compiled into the [`assets`](../../view/pages/assets)
directory.

They need to be re-compiled manually if the source-files get edited.

### Ruby Runner

For development on Windows the Ruby Runner is the only choice. As far as the
Controller is concerned it operates exactly the same as other runners.

The configuration file for this runner is placed in `wabur` sub-directory
and is named [`wabur.conf`](wabur/wabur.conf)

### OpO

OpO provides the HTTP server and the Model storage, and is able to run the
sample app as a spawned app that uses `$stdin` and `$stdout` for IO.

OpO can be downloaded from
[OpO Downloads](http://www.opo.technology/download/index.html).

The confguration file for OpO is in the `opo` sub-directory, and is named
[`opo.conf`](opo/opo.conf). The configuration specifies that the OpO disk
storage be in the `opo/data` directory. It also turns on logging for HTTP
requests and responses along with handler information from the Runner's
perspective.

Near the bottom of the conf file, the Controller `spawn.rb` is mentioned
along with command line options. The `-v` option turns on Controller
verbosity.

### OpO-Rub

OpO-Rub provides the HTTP server and the Model storage, and is able to run the
an embedded Ruby application.

OpO-Rub can be downloaded from
[OpO Downloads](http://www.opo.technology/download/index.html).

The configuration file for OpO-Rub is in the `opo` sub-directory, and is named
[`embed.conf`](opo/embed.conf). The configuration specifies that the OpO-Rub
disk storage be in the `opo/data` directory. It also turns on logging for HTTP
requests and responses along with handler information from the Runner's
perspective.

### Running the App

Compiling and running the App with a runner of your choice can be easily
by using the [`start-sample`](../../script/start-sample) BASH script.

It accepts two options:

  * `-b` &mdash; Compile view files and then execute the default Ruby Runner.
    (Compiling is necessary to generate and update the files required to
    properly render the App view.)
  * `-o` &mdash; Serve the app using the OpO runner without any compiling.

  **Note:** Alternatively, the two options can be passed together as `-bo` to
            *compile* and *execute the OpO runner* back-to-back.

The Sample App has been configured on both runners to serve at
`http://localhost:6363` by default and can changed in the concerned config
files.

## Running without a browser

WAB Controllers can be tested without a browser and Javascript. By using curl,
HTTP requests can be sent to the runner and subsequently verify the response.

Two terminal windows are to be used in this method. While one is for displaying
the `runner` trace output, the other is for calling `curl` to make HTTP
requests and to receive responses. *Mentally designate* the two terminal
windows as *runner* and *curl* terminals.

Run the shell script `start-view` with necessary [options](#running-the-app) to
serve the runner of your choice.

### Adding a Record

The `curl` application is used to add a record. The record is in the
[`article-1.json`](article-1.json) file. Once inserted, the response body
will include the reference number of the newly created record.

```
> curl -w "\n" -T article-1.json http://localhost:6363/v1/v1/Article
```

A response similar to the following should appear in the *curl terminal* where
the curl command was invoked.

```json
{"rid":"20170814212950.147723000","api":2,"body":{"ref":11,"code":0}}
```

**Note:** The *`ref`* in the `body` element is the reference number of the new
record. It will be used later to *get* and *delete* that record.

Around the same time, the *runner terminal* will show the arrival of the `PUT`
request with details followed by a handler trace and then traces from the
`WAB::IO::Shell` indicating what is sent to each part of the WAB setup.

### Get a Record

The reference number from the *create* is used to get a record. If not available
a list of records can be retrieved.

```
> curl -w "\n" http://localhost:6363/v1/Article
```

or with the record reference

```
> curl -w "\n" http://localhost:6363/v1/Article/11
```

### Delete a Record

The record can be deleted with an HTTP `DELETE` request.

```
> curl -w "\n" -X DELETE http://localhost:6363/v1/Article/11
```

## Benchmarks

Using the OpO Runner, a Ruby HTTP client is not able to generate requests and
process responses quick enough to reach the limits of the Runner. Instead a C
based HTTP benchmarking tool is used. It is in the OpO download and is called
**`hose`**.

To run the benchmarks start **`opod`** with the `opo/bench.conf` file. This
turns off the verbosity on `opod` and on the sample Ruby app.

Next add a record as done previously.

There are two ways to get the JSON of the created record:
  * Using the Controller with the path `http://localhost:6363/v1/Article/11` *(or)*
  * By going directly to the database with the path
    `http://localhost:6363/json/000000000000000b` which uses the ref in hex to
    identify the record. This is interesting in that it shows the overhead of
    the calls to the Ruby Controller.

Now that a record has been created, the benchmarks can be run.

```
> hose -p "json/000000000000000b" -d 1.0 -t 2 127.0.0.1:6363
```

```
> hose -p "v1/Article/11" -d 1.0 -t 2 127.0.0.1:6363
```

Both calls to the hose benchmarking app will use 2 threads and open 1000
connections at a time to the Runner.

### Results

Benchmarks were run on a desktop with an i7-6700@4.00GHz with 4 cores (8
hyperthreads.

#### Direct DB access

```
> hose -t 2 -c 20 -p json/000000000000000b localhost:6363
localhost:6363 processed 157075 requests in 1.000 seconds for a rate of 157075 GETS/sec.
with an average latency of 0.162 msecs

```

#### IO Controller with 4 Ruby Thread

```
> hose -t 2 -c 20 -p v1/Article/11 localhost:6363
localhost:6363 did not respond to 1 requests.
localhost:6363 processed 17569 requests in 1.000 seconds for a rate of 17569 GETS/sec.
with an average latency of 2.963 msecs

```

#### Embedded Controller

```
TBD

```
