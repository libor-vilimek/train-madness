class Helper {

}

function Helper::WriteAllIndustryTypes() {
	local industryTypeList = AIIndustryTypeList();
	foreach(industryType, value in industryTypeList) {
		AILog.Info(industryType + ": " + AIIndustryType.GetName(industryType));
	}
}

function Helper::WriteAllCargoTypes() {
	local cargoList = AICargoList();
	foreach(cargo, value in cargoList) {
		AILog.Info(cargo + ": " + AICargo.GetName(cargo));
	}
}
