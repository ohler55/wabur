# WABuR Sample

This simple example demonstrates the use of a WAB Controller to orchestrate
a request made for data. It is the most straight forward use of the WAB gem.

## Run without a browser

WAB Controllers can be tested without a browser and Javascript. By using curl,
HTTP requests can be sent to the shell and subsequently verify the response.

First a Runner is needed. The two choices are OpO or the Pure Ruby Runner.

Two terminal windows are to be used in this example. While one is for
displaying the `runner` trace output, the other is for calling `curl` to make
HTTP requests and to receive responses. *Mentally designate* the two terminal
windows as *runner* and *curl* terminals


### OpO

Say Hello to OpO, a fast triple store. It provides the HTTP server and the
Model storage, and is able to run the sample app as a spawned app that uses
`$stdin` and `$stdout` for IO.

OpO can be downloaded from
[OpO Downloads](http://www.opo.technology/download/index.html).

#### Start OpO

The confguration file for OpO is in the `opo` sub-directory, and is named
[`opo.conf`](opo/opo.conf). The configuration specifies that the OpO disk
storage be in the `opo/data` directory. It also turns on logging for HTTP
requests and responses along with handler information from the Runner's
perspective.

Near the bottom of the conf file, the Controller `spawn.rb` is mentioned
along with command line options. The `-v` option turns on Controller
verbosity.

Start the OpO daemon with the following command in the *runner terminal* after
installing:

```
 > opod -c opo/opo.conf
```

### Pure Ruby Runner (PRR)

For development on Windows the PRR is the only choice. As far as the
Controller is concerned it operates exactly the same as other runner except
that it does not support asynchronous handling of requests without the use of
threads in the WEBrick which is used as the HTTP server.

Start the PRR with the following command in the *runner terminal*.

```
 > wabur -c wabur/wabur.conf
```

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

### Benchmarks

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
    `http://localhost:6363/tree/000000000000000b` which uses the ref in hex to
    identify the record. This is interesting in that it shows the overhead of
    the calls to the Ruby Controller.

Now that a record has been created, the benchmarks can be run.

```
> hose -p "tree/000000000000000b" -d 1.0 -t 2 127.0.0.1:6363
```

```
> hose -p "v1/Article/11" -d 1.0 -t 2 127.0.0.1:6363
```

Both calls to the hose benchmarking app will use 2 threads and open 1000
connections at a time to the Runner.

#### Results

Benchmarks were run on a Razer Blade Stealth laptop with Ubuntu 17.04. A nice
machine but still a laptop and not a server class machine by any stretch. A
second set is on a desktop with an i7-6700@4.00GHz with 4 cores (8
hyperthreads.

##### Direct DB access

```
razer bin> ./hose -p tree/000000000000000b -t 2 -c 20 127.0.0.1:6363
127.0.0.1:6363 processed 100292 requests in 1.000 seconds for a rate of 100292 GETS/sec.
with an average latency of 0.254 msecs

big bin> hose -t 2 -c 20 -p tree/000000000000000b localhost:6363
localhost:6363 processed 157075 requests in 1.000 seconds for a rate of 157075 GETS/sec.
with an average latency of 0.162 msecs

```

##### Controller in Sychronous Mode with 4 Ruby Thread

```
razer bin> ./hose -p v1/Article/11 -t 2 -c 20 127.0.0.1:6363
127.0.0.1:6363 did not respond to 3 requests.
127.0.0.1:6363 processed 10200 requests in 1.000 seconds for a rate of 10200 GETS/sec.
with an average latency of 4.249 msecs

big bin> hose -t 2 -c 20 -p v1/Article/11 localhost:6363
localhost:6363 did not respond to 1 requests.
localhost:6363 processed 17569 requests in 1.000 seconds for a rate of 17569 GETS/sec.
with an average latency of 2.963 msecs

```

##### Controller in Asychronous Mode with 4 Ruby Thread

```
razer bin> ./hose -p v1/Article/11 -t 2 -c 20 127.0.0.1:6363
127.0.0.1:6363 did not respond to 3 requests.
127.0.0.1:6363 processed 11743 requests in 1.000 seconds for a rate of 11743 GETS/sec.
with an average latency of 3.844 msecs

big bin> hose -t 2 -c 20 -p v1/Article/11 localhost:6363
localhost:6363 did not respond to 4 requests.
localhost:6363 processed 18061 requests in 1.000 seconds for a rate of 18061 GETS/sec.
with an average latency of 2.514 msecs

```

The performance is reasonable but there were reliability issues that will have
to be addressed to determine why some messages are lost. On macOS results were
significantly slower which is expected as the macOS networking does not
perform as well as Linux.
