
import * as wab from './assets/wab/es6/wab.js';

function logResponse(obj, response) {
    console.log('Ok - ' + JSON.stringify(response));
}

function errorResponse(obj, response) {
    console.log('Error - ' + JSON.stringify(response));
}

// returns the UI specification
wab.listObjects('ui', null, null, logResponse, errorResponse);

