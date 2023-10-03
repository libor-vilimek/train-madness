enum RAIL_MANAGER_STATE {
	stations,
	buildingRail,
	destroying,
	finished
}

class RailManager {
	_currentState = null;
	_industryStart = null;
	_industryEnd = null;

	startLocation = null;
	endLocation = null;

	constructor(industryStart, industryEnd) {
		this._currentState = RAIL_MANAGER_STATE.stations;
		this._industryStart = industryStart;
		this._industryEnd = industryEnd;
	}
}

function RailManager::Next() {
	Log.Debug("RailManager Next Called - state: " + this._currentState);
	if (this._currentState == RAIL_MANAGER_STATE.stations) {
		local newStations = this.BuildStations(this._industryStart, this._industryEnd);
		this.startLocation = newStations.startLocation;
		this.endLocation = newStations.endLocation;
		this._currentState = RAIL_MANAGER_STATE.buildingRail;

		RailManager.BuildRail(this.startLocation, this.endLocation);
		//RailManager.BuildRail(newStations.startLocation2, newStations.endLocation2);
		this._currentState = RAIL_MANAGER_STATE.finished;
	} else if (_currentState == RAIL_MANAGER_STATE.buildingRail) {
		// RailManager.BuildRail(this.startLocation, this.endLocation);
		// this._currentState = RAIL_MANAGER_STATE.finished;
	}
}

function RailManager::BuildRail(fromLocation, toLocation) {
    local rails = Rails(fromLocation, toLocation);
    while (rails.BuildNext()){
        // builing rail
    }
}

function RailManager::BuildStations(industryProduce, industryAccept) {
	local startLocation = null;
    local startLocationPrev = null;
	local startLocation2 = null;
	local endLocation = null;
    local endLocationPrev = null;
	local endLocation2 = null;

	local industryProduceLocation = AIIndustry.GetLocation(industryProduce);
	local possibleLocationsProduce = AITileList_IndustryProducing(industryProduce, 4);
	// Log.CreateSigns(possibleLocationsProduce, "Start Station Here", DEBUG_TYPE.BUILDING_STATION);
	local startTest = AITestMode();
	foreach(location, value in possibleLocationsProduce) {
		local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
		Log.CreateSign(location, "Trying station here: " + result, DEBUG_TYPE.BUILDING_STATION);
		local depot = AIRail.BuildRailDepot(location + AIMap.GetTileIndex(-2, 0), location + AIMap.GetTileIndex(-1, 0));
		Log.CreateSign(location + AIMap.GetTileIndex(-2, 0), "Trying depot here: " + depot, DEBUG_TYPE.BUILDING_STATION);
		local rail1 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(7, 0), AIRail.RAILTRACK_NE_SW);
		local rail2 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-1, 0), AIRail.RAILTRACK_NE_SW);
		local rail3 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(8, 0), AIRail.RAILTRACK_NE_SW);
		local rail4 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-1, 0), AIRail.RAILTRACK_SW_SE);
		local rail5 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-1, 1), AIRail.RAILTRACK_NW_SW);

		if (result && depot && rail1 && rail2 && rail3 && rail4 && rail5) {
			startTest = null;
			local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
			Log.CreateSign(location, "Building station here", DEBUG_TYPE.BUILDING_STATION);
			local depot = AIRail.BuildRailDepot(location + AIMap.GetTileIndex(-2, 0), location + AIMap.GetTileIndex(-1, 0));
			Log.CreateSign(location + AIMap.GetTileIndex(-2, 0), "Building depot here", DEBUG_TYPE.BUILDING_STATION);
			local rail2 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-1, 0), AIRail.RAILTRACK_NE_SW);
			local rail4 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-1, 0), AIRail.RAILTRACK_NE_SE);
			local rail5 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-1, 1), AIRail.RAILTRACK_NW_SW);

			startLocationPrev = Node.CreateFromTile(location + AIMap.GetTileIndex(6, 0));
			startLocation = Node.CreateFromTile(location + AIMap.GetTileIndex(7, 0));
			startLocation2 = Node.CreateFromTile(location + AIMap.GetTileIndex(0, 1));
			Log.CreateSign(startLocation.tile, "Rail starting from here: " + startLocation.ToString(), DEBUG_TYPE.BUILDING_STATION);
			break;
		}
	}
	startTest = null;


	local possibleLocationsAccept = AITileList_IndustryAccepting(industryAccept, 4);
	// Log.CreateSigns(possibleLocationsAccept, "End Station Here", DEBUG_TYPE.BUILDING_STATION);

	local startTest = AITestMode();
	foreach(location, value in possibleLocationsAccept) {
		local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
		Log.CreateSign(location, "Trying station here: " + result, DEBUG_TYPE.BUILDING_STATION);
		local rail1 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(7, 0), AIRail.RAILTRACK_NE_SW);
		local rail2 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-1, 0), AIRail.RAILTRACK_NE_SW);
		local rail3 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(8, 0), AIRail.RAILTRACK_NE_SW);
		local rail4 = AIRail.BuildRailTrack(location + AIMap.GetTileIndex(-2, 0), AIRail.RAILTRACK_NE_SW);

		if (result && rail1 && rail2 && rail3 && rail4) {
			startTest = null;
			local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
			Log.CreateSign(location, "Building station here", DEBUG_TYPE.BUILDING_STATION);
			endLocationPrev = Node.CreateFromTile(location + AIMap.GetTileIndex(-1, 0));
			endLocation = Node.CreateFromTile(location);
			endLocation2 = Node.CreateFromTile(location + AIMap.GetTileIndex(7, 0));
			Log.CreateSign(endLocation.tile, "Rail ending in here: " + endLocation.ToString(), DEBUG_TYPE.BUILDING_STATION);
			break;
		}
	}
	startTest = null;

	return {
		startLocation = DirectionNode(startLocationPrev, startLocation),
		startLocation2 = startLocation2,
		endLocation = DirectionNode(endLocationPrev, endLocation),
		endLocation2 = endLocation2
	};
}



function RailManager::BuildStation(location) {
	local x = AITestMode();
	local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
	AILog.Info(result);
	local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
	AILog.Info(result);
	x = null;
	local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
	AILog.Info(result);
	local result = AIRail.BuildRailStation(location, AIRail.RAILTRACK_NE_SW, 1, 7, AIStation.STATION_NEW);
	AILog.Info(result);
}