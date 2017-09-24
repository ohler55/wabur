const classifyNewElement = (elem, klass) => {
    let e = document.createElement(elem);
    e.className = klass;
    return e;
};

const view = (content) => {
    return document.getElementById('view').appendChild(content);
};

export { classifyNewElement, view };
