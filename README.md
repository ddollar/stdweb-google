# stdweb-google

Use Google auth with [stdweb](https://github.com/ddollar/stdweb)

## Installation

    $ npm install stdweb-google --save

## Usage

```coffeescript
google = require("stdweb-google").init("mydomain.com")

app = stdweb("myapp")

google.inject(app)
```

## License

MIT
