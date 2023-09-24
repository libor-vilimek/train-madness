class BuildRail extends Command {
    _manager = null;
    _railManager = null;

    constructor(manager, railManager = null) {
        this._manager = manager;
        this._railManager = railManager;
    }
}

function BuildRail::Execute() {
    Log.Debug("BuildRail executing");
    if (this._railManager == null) {
        local industries = this._manager.GetIndustryRoutes();
        local industry = industries.top()
        this._railManager = RailManager(industry.providerId, industry.consumerId);
    }
    this._railManager.Next();
}
