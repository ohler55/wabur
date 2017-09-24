import { classifyNewElement } from 'utils.js';

const input = classifyNewElement('input', 'field');
input.type = 'text';
input.setAttribute('style', 'width: 272px; padding: 15px');
input.placeholder = "Ignore me.. just a static input field";

export default input;
