// main entry file for current App.
import input from 'components/input.js';
import { classifyNewElement, view } from 'utils.js';

const elem = classifyNewElement('h1', 'heading');
let text = 'User';
elem.innerHTML = `Hello ${text}!`;

view(input);
view(elem);
