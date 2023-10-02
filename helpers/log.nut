class Log {}

function Log::Debug(message, debugType = null) {
	if (Constants.LOG_LEVEL >= LOG_LEVEL.DEBUG) {
		if (Constants.IsDebugEnabled(debugType, false)) {
			AILog.Info(message);
		}
	}
}

function Log::Info(message) {
	if (Constants.LOG_LEVEL >= LOG_LEVEL.INFO) {
		AILog.Info(message);
	}
}

function Log::CreateSigns(locations, text, debugType = null) {
	foreach(location, value in locations) {
		Log.CreateSign(location, text, debugType);
	}
}

function Log::CreateSign(location, text, debugType = null) {
	if (Constants.IsDebugEnabled(debugType, true)) {
		AISign.BuildSign(location, text);
	}
}