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

function RailManager::BuildStations(industryStart, industryEnd) {
    local firstLocation = AIIndustry.GetLocation(industryStart);
    local possibleLocations = AITileList_IndustryProducing(industryStart, 4);
    Log.CreateSigns(possibleLocations, "Start Station Here", DEBUG_TYPE.BUILDING_STATION);
}
