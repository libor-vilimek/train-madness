enum RAIL_MANAGER_STATE {
    start,
    stations,
    buildingRail,
    destroying,
    finished
}

class RailManager {
    _currentState = null;
    _industryStart = null;
    _industryEnd = null;

    constructor(industryStart, industryEnd){
        _currentState = RAIL_MANAGER_STATE.start;
        this._industryStart = industryStart;
        this._industryEnd = industryEnd;
    }
}

function RailManager::Next() {
    Log.Debug("RailManager Next Called - state: " + _currentState);
    if (_currentState == RAIL_MANAGER_STATE.start) {
        this.BuildStations(this._industryStart, this._industryEnd);
    }
}

function RailManager::BuildStations(industryProduce, industryAccept) {
    local industryProduceLocation = AIIndustry.GetLocation(industryProduce);
    local possibleLocationsProduce = AITileList_IndustryProducing(industryProduce, 4);
    // Log.CreateSigns(possibleLocationsProduce, "Start Station Here", DEBUG_TYPE.BUILDING_STATION);
    local result = AIRail.BuildRailStation(possibleLocationsProduce.Begin(), AIRail.RAILTRACK_NW_SE, 1, 1, AIStation.STATION_NEW);
    AILog.Info(result);


    local possibleLocationsAccept = AITileList_IndustryAccepting(industryAccept, 4);
    Log.CreateSigns(possibleLocationsAccept, "End Station Here", DEBUG_TYPE.BUILDING_STATION);
}
