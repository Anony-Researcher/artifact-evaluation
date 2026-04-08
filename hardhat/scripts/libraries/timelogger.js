const logtime = () =>{
    var date = new Date();
    var moment = require("moment");
    moment.locale("en-in")
    var momentDate = moment().format("HH:mm:ss:SSSSS");

    console.log("[INFO] ", momentDate);

}

exports.logtime = logtime;