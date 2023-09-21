class FindPriority extends Command {
    manager = null;

    constructor(manager) {
        this.manager = manager;
    }
}

function FindPriority::Execute() {
    Log.Debug("Finding new priority as command");
    manager.InsertCommand(BuildRail(this.manager), Constants.LOW_QUEUE_PRIORITY);
}
