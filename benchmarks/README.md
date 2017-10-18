# WABuR Benchmarks

**TBD This needs updating to describe the latest approach to creating a project.**


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

Closing the connection after each fetch as if it were separate browsers.

```
> hose -t 2 -c 20 -p json/000000000000000b 127.0.0.1:6363
127.0.0.1:6363 processed 159321 requests in 1.000 seconds for a rate of 159321 GETS/sec.
with an average latency of 0.134 msecs

```

Keep the connection alive as if it were the same browsers performing multiple fetchs.
```
> hose -t 2 -c 20 -p json/000000000000000b 127.0.0.1:6363 -k
127.0.0.1:6363 processed 347951 requests in 1.000 seconds for a rate of 347951 GETS/sec.
with an average latency of 0.111 msecs
```

#### IO Controller with 4 Ruby Thread

Closing the connection after each fetch as if it were separate browsers.

```
> hose -t 2 -c 20 -p v1/Article/11 127.0.0.1:6363
127.0.0.1:6363 did not respond to 3 requests.
127.0.0.1:6363 processed 14433 requests in 1.000 seconds for a rate of 14433 GETS/sec.
with an average latency of 2.997 msecs
```

Keep the connection alive as if it were the same browsers performing multiple fetchs.
```
> hose -t 2 -c 20 -p v1/Article/11 127.0.0.1:6363 -k
127.0.0.1:6363 did not respond to 2 requests.
127.0.0.1:6363 processed 13837 requests in 1.000 seconds for a rate of 13837 GETS/sec.
with an average latency of 3.346 msecs
```

#### Embedded Controller

Closing the connection after each fetch as if it were separate browsers.

```
> hose -t 2 -c 20 -p e1/Article/11 127.0.0.1:6363   
127.0.0.1:6363 processed 137603 requests in 1.000 seconds for a rate of 137603 GETS/sec.
with an average latency of 0.247 msecs


```

Keep the connection alive as if it were the same browsers performing multiple fetchs.

```
> hose -t 2 -c 20 -p e1/Article/11 127.0.0.1:6363 -k
127.0.0.1:6363 processed 227789 requests in 1.000 seconds for a rate of 227789 GETS/sec.
with an average latency of 0.171 msecs
```

#### Summary

| Runner      | Throughput    | Latency   |
| ----------- | ------------- | --------- |
| Pure Ruby   | 2.6K GETS/sec | 1.5 msecs |
| OpO IO      | 14K GETS/sec  | 3.0 msecs |
| OpO-Rub     | 228K GETS/sec | 0.7 msecs |
| OpO Direct  | 348K GETS/sec | 0.1 msecs |

At more than 300K fetches per second the direct access with keep-alive
connections is clearly the fastest of the bunch but it bypasses the Ruby
controller. Of the two remaining, the use of embedded Ruby gives excellent
results that surpass the 100K fetch per second goal by a sizeable amount at
more than double the goal with keep-alive and nearly 40% over target with
connection closes.

Some issues still remain with the stdio approach dropping 2 messages out of
14K.