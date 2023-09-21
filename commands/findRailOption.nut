class FindRailOption extends Command {
    manager = null;

    constructor(manager) {
        this.manager = manager;
    }
}

function FindRailOption::Execute() {
    Log.Debug("FindRailOption executing");
}

function FindRailOption::FindIndustryRoute() {
	local industryList = AIIndustryList_CargoProducing(Constants.CARGO_COAL);
	industryList.Valuate(AIIndustry.GetLastMonthProduction, Constants.CARGO_COAL);
	industryList.Sort(AIList.SORT_BY_VALUE, false);
	AILog.Info(AIIndustry.GetName(industryList.Begin()));

	local location = AIIndustry.GetLocation(industryList.Begin()) + AIMap.GetTileIndex(4, 4);
	industryList = AIIndustryList_CargoAccepting(Constants.INDUSTRY_POWER_STATION);
	industryList.Valuate(AIIndustry.GetDistanceManhattanToTile, location);
	industryList.KeepAboveValue(100);
	industryList.Sort(AIList.SORT_BY_VALUE, true);
    AILog.Info(AIIndustry.GetName(industryList.Begin()));
}