class FindPriority extends Command {
	manager = null;

	constructor(manager) {
		this.manager = manager;
	}
}

function FindPriority::Execute() {
	Log.Debug("Finding new priority as command");
	if (this.manager.GetIndustryRoutes().len() == 0) {
		this.manager.InsertCommand(FindIndustryRouteForRail(this.manager), Constants.LOW_QUEUE_PRIORITY);
	} else {
        this.manager.InsertCommand(BuildRail(this.manager), Constants.LOW_QUEUE_PRIORITY);
	}
}