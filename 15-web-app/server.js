const connect = require("connect");
const serverStatic = require("server-static");

connect()
  .use(serverStatic(__dirname + "/"))
  .listen(8080, function () {
    console.log("localhost:8080");
  });
