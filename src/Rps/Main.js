const React = require("react");
const ReactDOM = require("react-dom");
const {App} = require("../../src/frontend/App");

const render = (props) => () => {
    console.log("RENDER: ", props);
    ReactDOM.render(
        React.createElement(App, props),
        document.getElementById('root')
    );
}

exports.render = render;