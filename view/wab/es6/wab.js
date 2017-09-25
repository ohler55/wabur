
var pathPrefix = '/v1';

function pathAppendCondition(path, condition) {
    if (null != condition) {
        path += '/?';
        let first = true;
        for (let key in condition) {
            if (first) {
                path += '${key}=${condition[key]}';
                first = false;
            } else {
                path += '&${key}=${condition[key]}';
            }
        }
    }
    return path;
}

function createPromise(kind, obj, condition) {
    return new Promise(
        function(resolve, reject) {
            let path = pathAppendCondition(`${pathPrefix}/${kind}`, condition);
            let options = {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(obj)
            };

            fetch(path, options).then(function(response) {
                return response.json();
            }).then(function(j) {
                resolve(j);
            }).catch(reject)
        });
}

function updatePromise(kind, ref, obj, condition) {
    return new Promise(
        function(resolve, reject) {
            let options = {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(obj)
            };

            fetch(`${pathPrefix}/${kind}/${ref}`, options).then(function(response) {
                return response.json();
            }).then(function(j) {
                resolve(j);
            }).catch(reject)
        });
}

function getPromise(kind, ref) {
    return new Promise(
        function(resolve, reject) {
            fetch(`${pathPrefix}/${kind}/${ref}`).then(function(response) {
                return response.json();
            }).then(function(j) {
                resolve(j);
            }).catch(reject)
        });
}

function deletePromise(kind, ref) {
    return new Promise(
        function(resolve, reject) {
            fetch(`${pathPrefix}/${kind}/${ref}`, {method: 'GET'}).then(function(response) {
                return response.json();
            }).then(function(j) {
                resolve(j);
            }).catch(reject)
        });
}

function listPromise(kind, condition) {
    return new Promise(
        function(resolve, reject) {
            let path = pathAppendCondition(`${pathPrefix}/${kind}`, condition);

            fetch(path, {method: 'GET'}).then(function(response) {
                return response.json();
            }).then(function(j) {
                resolve(j);
            }).catch(reject)
        });
}

function queryPromise(kind, tql) {
    return new Promise(
        function(resolve, reject) {
            let path = (null == kind) ? pathPrefix : `${pathPrefix}/${kind}`
            let options = {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(tql)
            };

            fetch(path, options).then(function(response) {
                return response.json();
            }).then(function(j) {
                resolve(j);
            }).catch(reject)
        });
}

export { createPromise, getPromise, updatePromise, deletePromise, listPromise, queryPromise };
export { pathPrefix };
