
import * as wab from './assets/wab/es6/wab.js';

function logOk(response) {
    console.log('Ok - ' + JSON.stringify(response, null, 2));
}

function logError(response) {
    console.log('Error - ' + JSON.stringify(response, null, 2));
}

wab.listPromise('ui', null).then(logOk).catch(logError);
