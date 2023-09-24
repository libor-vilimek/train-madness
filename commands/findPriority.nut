class FindPriority extends Command {
	_manager = null;

	constructor(manager) {
		this._manager = manager;
	}
}

function FindPriority::Execute() {
	Log.Debug("Finding new priority as command");
	if (this._manager.GetIndustryRoutes().len() == 0) {
		this._manager.InsertCommand(FindIndustryRouteForRail(this._manager), Constants.DEFAULT_QUEUE_PRIORITY);
	} else {
        this._manager.InsertCommand(BuildRail(this._manager), Constants.LOW_QUEUE_PRIORITY);
	}
}
