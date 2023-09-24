class FindIndustryRouteForRail extends Command {
    manager = null;

    constructor(manager) {
        this.manager = manager;
    }
}

function FindIndustryRouteForRail::Execute() {
    Log.Debug("FindRailOption executing");
    this.manager.AddNewIndustryRoute(this.FindIndustryRoute());
}

function FindIndustryRouteForRail::FindIndustryRoute() {
	local industryList = AIIndustryList_CargoProducing(Constants.CARGO_COAL);
	industryList.Valuate(AIIndustry.GetLastMonthProduction, Constants.CARGO_COAL);
	industryList.Sort(AIList.SORT_BY_VALUE, false);
    local providerId = industryList.Begin();
	local providerLocation = AIIndustry.GetLocation(providerId);
    Log.Debug("Found Coal Mine: " + AIIndustry.GetName(providerId));

	industryList = AIIndustryList_CargoAccepting(Constants.INDUSTRY_POWER_STATION);
	industryList.Valuate(AIIndustry.GetDistanceManhattanToTile, providerLocation);
	industryList.KeepAboveValue(200);
	industryList.Sort(AIList.SORT_BY_VALUE, true);

    local consumerId = industryList.Begin();
    Log.Debug("Found Power Station for the Coal Mine: " + AIIndustry.GetName(consumerId));

    return {providerId = providerId, consumerId = consumerId};
}
