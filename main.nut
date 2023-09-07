/**
 * This is very simple AI that was written while I was ill due to having covid-19.
 * I spent only two partial days working on it, therefore it really is intended to be simple.
 * It will try to spread to all cities with buses alone.
 */
class TrainMadness extends AIController {
    // Some nasty surprise - you have find cargoId in list, you cannot just use i.e. AICargo.CC_PASSENGERS
    // This stores the CargoId for passengers. More in constructor
    passengerCargoId = -1;

    constructor() {
        // Without this you cannot build road, station or depot
        AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

        // Persist passengers
        local list = AICargoList();
        for (local i = list.Begin(); list.IsEnd() == false; i = list.Next()) {
            if (AICargo.HasCargoClass(i, AICargo.CC_PASSENGERS)) {
                this.passengerCargoId = i;
                break;
            }
        }
    }
    function Start() ;
}

/**
 * Äll the logic starts here
 */
function TrainMadness::Start() {
    AICompany.SetName("TrainMadness")
    AICompany.SetLoanAmount(AICompany.GetMaxLoanAmount());
    AILog.Info("Starting, wheee");
    while (true) {
        this.Sleep(10);
        // If we dont have enough money, just dont build any other stations and buses there
        if (AICompany.GetBankBalance(AICompany.COMPANY_SELF) > (AICompany.GetMaxLoanAmount() / 10)) {

        }
    }
}
