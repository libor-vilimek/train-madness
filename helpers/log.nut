require("constants.nut");

class Log {}

function Log::Debug(message) {
    if (Constants.LOG_LEVEL >= LOG_LEVEL.DEBUG ) {
        AILog.Info(message);
    }
}

function Log::Info(message) {
    if (Constants.LOG_LEVEL >= LOG_LEVEL.INFO ) {
        AILog.Info(message);
    }
}