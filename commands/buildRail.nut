class BuildRail extends Command {
    manager = null;

    constructor(manager) {
        this.manager = manager;
    }
}

function BuildRail::Execute() {
    Log.Debug("BuildRail executing");
}
