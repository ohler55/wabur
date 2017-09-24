
var pathPrefix = '/v1';

function request(method, path, content, requester, callback, errorCallback) {
    let h = new XMLHttpRequest();

    h.open(method, path, true);
    h.responseType = 'json';
    h.onreadystatechange = function() {
        if (4 == h.readyState) {
            if (200 == h.status) {
                callback(requester, h.response);
            } else {
                errorCallback(requester, h.response);
            }
        }
    };
    if (null != content) {
        h.setRequestHeader('Content-Type', 'application/json');
        h.send(JSON.stringify(content));
    } else {
        h.send();
    }
}

function pathAppendCondition(path, condition) {
    if (null != condition) {
        path += '/?';
        let first = true;
        for (let key of Object.keys(condition)) {
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

function createObject(kind, obj, condition, requester, callback, errorCallback) {
    request('PUT', pathAppendCondition('${pathPrefix}/${kind}', condition), obj, requester, callback, errorCallback);
}

function getObject(kind, ref, requester, callback, errorCallback) {
    request('GET', '${pathPrefix}/${kind}/${ref}', null, requester, callback, errorCallback);
}

function updateObject(kind, ref, obj, requester, callback, errorCallback) {
    request('POST', '${pathPrefix}/${kind}/${ref}', obj, requester, callback, errorCallback);
}

function deleteObject(kind, ref, requester, callback, errorCallback) {
    request('DELETE', '${pathPrefix}/${kind}/${ref}', null, requester, callback, errorCallback);
}

function listObjects(kind, condition, requester, callback, errorCallback) {
    // string templates did not work in firefox
    //request('GET', pathAppendCondition('${pathPrefix}/${kind}', condition), null, requester, callback, errorCallback);
    request('GET', pathAppendCondition(pathPrefix + '/' + kind, condition), null, requester, callback, errorCallback);
}

function query(kind, tql, requester, callback, errorCallback) {
    request('GET', '${pathPrefix}/${kind}', null, tql, requester, callback, errorCallback);
}

export function foo() {
    console.log('foo called');
}

export { request, createObject, getObject, updateObject, deleteObject, listObjects, query };
export { pathPrefix };
