enum LOG_LEVEL {
    DEBUG,
    INFO
}

enum DEBUG_TYPE {
    BUILDING_STATION
}

class Constants {
    INDUSTRY_COAL_MINE = 0;
    INDUSTRY_POWER_STATION = 1;
    CARGO_COAL = 1;
    LOG_LEVEL = LOG_LEVEL.DEBUG;

    LOW_QUEUE_PRIORITY = 10;
    DEFAULT_QUEUE_PRIORITY = 5;
    HIGH_QUEUE_PRIORITY = 3;

    DEBUG_BUILDING_STATION = true;
}

function Constants::IsDebugEnabled(debugType) {
    if (debugType == DEBUG_TYPE.BUILDING_STATION && Constants.DEBUG_BUILDING_STATION == true) {
        return true;
    }

    return false;
}
