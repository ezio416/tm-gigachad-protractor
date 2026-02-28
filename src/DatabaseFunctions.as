class DatabaseFunctions {
    SQLite::Database@ database = SQLite::Database(IO::FromStorageFolder("gcp.db"));

    string prev_map;
    bool prev_res;
    bool prev_init;

    DatabaseFunctions() {
        database.Execute("CREATE TABLE IF NOT EXISTS skip_maps (uid VARCHAR PRIMARY KEY)");
    }

    void DisableMap(const string&in uid) {
        if (IsMapSkipped(uid)) {
            return;
        }
        SQLite::Statement@ statement = database.Prepare("INSERT INTO skip_maps VALUES (?)");
        statement.Bind(1, uid);
        statement.Execute();
        prev_init = false;
    }

    void EnableMap(const string&in uid) {
        if (!IsMapSkipped(uid)) {
            return;
        }
        SQLite::Statement@ statement = database.Prepare("DELETE FROM skip_maps WHERE uid = ?");
        statement.Bind(1, uid);
        statement.Execute();
        prev_init = false;
    }

    bool IsMapSkipped(const string&in uid) {
        if (prev_init && prev_map == uid) {
            return prev_res;
        }

        SQLite::Statement@ statement = database.Prepare("SELECT uid FROM skip_maps WHERE uid = ?");
        statement.Bind(1, uid);
        statement.Execute();
        statement.NextRow();
        const bool res = statement.NextRow();
        prev_map = uid;
        prev_res = res;
        prev_init = true;
        return res;
    }
}
