import("pathfinder.rail", "RailPathFinder", 1);
require("constants.nut");
require("helper.nut");
require("rails.nut");

/**
 * This is very simple AI that was written while I was ill due to having covid-19.
 * I spent only two partial days working on it, therefore it really is intended to be simple.
 * It will try to spread to all cities with buses alone.
 */
class TrainMadness extends AIController {
	constructor() {
		local railTypes = AIRailTypeList();
		foreach(railType, value in railTypes) {
			AILog.Info(railType + ": " + AIRail.GetName(railType));
			AIRail.SetCurrentRailType(railType);
		}

		// Helper.WriteAllCargoTypes();
	}

	function Start();
}

/**
 * Äll the logic starts here
 */
function TrainMadness::Start() {
	AICompany.SetName("TrainMadness")
	AICompany.SetLoanAmount(AICompany.GetMaxLoanAmount());
	AILog.Info("Starting");

	this.FindIndustryRoute();

	/*

	local townlist = AITownList();
	townlist.Valuate(AITown.GetPopulation);
	townlist.Sort(AIList.SORT_BY_VALUE, false);
	foreach (town, value in townlist) {
	    // AILog.Info(town);
	    local location = AITown.GetLocation(town);
	    local list = AITileList();
	    list.AddRectangle(location - AIMap.GetTileIndex(16, 16), location + AIMap.GetTileIndex(16, 16));
	    foreach (tile, value in list) {
	        //AILog.Info("building tile, yeaaa");
	        //AILog.Info(AIRail.BuildRailTrack(tile, AIRail.RAILTRACK_NE_SW ));
	    }
	}

	*/

	while (true) {
		this.Sleep(10);
	}
}

function TrainMadness::FindIndustryRoute() {
	// local industryList = AIIndustryList_CargoProducing(Constants.CARGO_COAL);
	// industryList.Valuate(AIIndustry.GetLastMonthProduction, Constants.CARGO_COAL);
	// industryList.Sort(AIList.SORT_BY_VALUE, false);
	// AILog.Info(AIIndustry.GetName(industryList.Begin()));

	// local location = AIIndustry.GetLocation(industryList.Begin()) + AIMap.GetTileIndex(4, 4);
	// industryList = AIIndustryList_CargoAccepting(Constants.INDUSTRY_POWER_STATION);
	// industryList.Valuate(AIIndustry.GetDistanceManhattanToTile, location);
	// industryList.KeepAboveValue(100);
	// industryList.Sort(AIList.SORT_BY_VALUE, true);
    // AILog.Info(AIIndustry.GetName(industryList.Begin()));
	// //local secondLocation = AIIndustry.GetLocation(industryList.Begin()) - AIMap.GetTileIndex(4, 4);
	// local secondLocation = location + AIMap.GetTileIndex(20, 0);

	// AISign.BuildSign(location, "Start Coal");
	// AISign.BuildSign(secondLocation, "End Coal");

	local location = AIMap.GetTileIndex(10,10);
	local location2 = AIMap.GetTileIndex(500,50);


	AISign.BuildSign(location, "Location 1");
	AISign.BuildSign(location2, "Location 2");

	Rails.PlanRail(location, location2);

	// while (true) {
	//   Rails.BuildRail([location, location + AIMap.GetTileIndex(-1, 0)], [secondLocation + AIMap.GetTileIndex(-1, 0), secondLocation]);
	//   location = location + AIMap.GetTileIndex(20, 0);
	//   secondLocation = secondLocation + AIMap.GetTileIndex(20, 0);
	// }
}
