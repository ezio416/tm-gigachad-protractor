class DatabaseFunctions {
    SQLite::Database@ database = SQLite::Database(IO::FromStorageFolder("gcp.db"));

    string prev_map;
    bool prev_res;
    bool prev_init;

    DatabaseFunctions() {
        database.Execute("CREATE TABLE IF NOT EXISTS skip_maps (map_uuid VARCHAR PRIMARY KEY)");
    }

    bool isMapSkipped(string _map_uuid) {
        if (prev_init && prev_map == _map_uuid) {
            return prev_res;
        }

        SQLite::Statement@ statement = database.Prepare("SELECT map_uuid FROM skip_maps WHERE map_uuid = ?");
        statement.Bind(1, _map_uuid);
        statement.Execute();
        statement.NextRow();
        bool res = statement.NextRow();
        prev_map = _map_uuid;
        prev_res = res;
        prev_init = true;
        return res;
    }

    void disableMap(string _map_uuid) {
        if (isMapSkipped(_map_uuid)) {
            return;
        }
        SQLite::Statement@ statement = database.Prepare("INSERT INTO skip_maps VALUES (?)");
        statement.Bind(1, _map_uuid);
        statement.Execute();
        prev_init = false;
    }

    void enableMap(string _map_uuid) {
        if (!isMapSkipped(_map_uuid)) {
            return;
        }
        SQLite::Statement@ statement = database.Prepare("DELETE FROM skip_maps WHERE map_uuid = ?");
        statement.Bind(1, _map_uuid);
        statement.Execute();
        prev_init = false;
    }
}
