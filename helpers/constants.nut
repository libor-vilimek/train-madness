enum LOG_LEVEL {
    DEBUG,
    INFO
}

enum DEBUG_TYPE {
    BUILDING_STATION,
    BUILDING_RAIL
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
    DEBUG_BUILDING_RAIL = true;

    DEBUG_SIGNS_BUILDING_STATION = true;
    DEBUG_SIGNS_BUILDING_RAIL = true;
}

function Constants::IsDebugEnabled(debugType, isSign = false) {
    // Without debugType its considered "log always"
    if (debugType == null) {
        return true;
    }

    if (isSign) {
        if (debugType == DEBUG_TYPE.BUILDING_STATION && Constants.DEBUG_SIGNS_BUILDING_STATION == true) {
            return true;
        }

        if (debugType == DEBUG_TYPE.BUILDING_RAIL && Constants.DEBUG_SIGNS_BUILDING_RAIL == true) {
            return true;
        }
    } else {
        if (debugType == DEBUG_TYPE.BUILDING_STATION && Constants.DEBUG_BUILDING_STATION == true) {
            return true;
        }

        if (debugType == DEBUG_TYPE.BUILDING_RAIL && Constants.DEBUG_BUILDING_RAIL == true) {
            return true;
        }
    }

    return false;
}
