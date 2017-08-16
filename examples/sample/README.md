# WABuR Sample

This simple example demonstrates the use of a WAB Controller to orchestrate
a request made for data. It is the most straight forward use of the WAB gem.

## Run without a browser

WAB Controllers can be tested without a browser and Javascript. By using curl
HTTP requests can be sent to the shell and response can be verified.

First a shell is needed. OpO can be downloaded from
[http://www.opo.technology/download/index.html](http://www.opo.technology/download/index.html). OpO
provides the HTTP server and the Model storage. It is able to run the sample
app as a spawned app that uses ```$stdin``` and ```$stdout``` for IO.

### Start OpO

The confguration file for OpO is in the opo sub-directory and is named
opo.conf. The configuration specifies that the OpO disk storage is in the
opo/data directory.

Start the OpO daemon with this command after installing.

```
 > opod -c opo/opo.conf
```

### Adding a Record

The curl application is used to add a record. The record is in the
article-1.json file. Once inserted the response body will include the
reference number of the newly created record.

```
> curl -w "\n" -T article-1.json http://localhost:6363/Article
```

A response similar to the following should appear.

```
{"rid":"20170814212950.147723000","api":2,"body":{"ref":11,"code":0}}
```

Note the +ref+ in the body element. That is the reference number of the new
record. It will be used later to get and delete that record.

### Get a Record

The reference number from the create is used to get a record. If not available
a list of records can be retrieved.

```
> curl -w "\n" http://localhost:6363/Article
```

or with the record reference

```
> curl -w "\n" http://localhost:6363/Article/11
```

### Delete a Record

The record can be deleted with an HTTP DELETE request.

```
> curl -w "\n" -X DELETE http://localhost:6363/Article/11
```

### Benchmarks

Using the OpO Runner a Ruby HTTP client is not able to generate requests and
process responses quick enough to reach the limits of the Runner. Instead a C
based HTTP benchmarking tool is used. It is in the OpO download and is called
+hose+.

To run the benchmarks start the +opod+ with the opo/bench.conf file. This
turns off the verbosity on opod and on the sample Ruby app.

Next add a record as done previously.

There are two ways to get the JSON of the created record. Either using the
Controller with the path ```http://localhost:6363/Article/11``` or by going
directly to the database with the path
```http://localhost:6363/tree/000000000000000b``` which uses the ref in hex to
identify the record. This is interesting in that it shows the overhead of the
calls to the Ruby Controller.

Now that a record has been created the benchmarks can be run.

```
> hose -p "tree/000000000000000b" -d 1.0 -t 2 127.0.0.1:6363
```

```
> hose -p "Article/11" -d 1.0 -t 2 127.0.0.1:6363
```

Both calls to the hose benchmarking app will use 2 threads and open 1000
connections at a time to the Runner.

#### Results

Benchmarks were run on a Razer Blade Stealth laptop with Ubuntu 17.04. A nice
machine but still a laptop and not a server class machine by any stretch.

```
razer bin (master)> hose -p "tree/000000000000000b" -d 1.0 -t 2 127.0.0.1:6363
127.0.0.1:6363 processed 38325 requests in 1.000 seconds for a rate of 38325 GETS/sec.
with an average latency of 0.029 msecs
```

```
razer bin (master)> hose -p "Article/11" -d 1.0 -t 2 127.0.0.1:6363
127.0.0.1:6363 processed 7724 requests in 1.000 seconds for a rate of 7724 GETS/sec.
with an average latency of 0.109 msecs
```

The performance is reasonable but there were reliability issues that will have
to be addressed as results were not consistent with either. On macOS results
were more consistent but significantly lower.