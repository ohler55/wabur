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
