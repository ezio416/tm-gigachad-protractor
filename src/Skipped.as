namespace Skipped {
    Json::Value@ uids = Json::Object();
    const string file = IO::FromStorageFolder("skipped.json");

    void Load() {
        if (IO::FileExists(file)) {
            @uids = Json::FromFile(file);
            if (uids.GetType() != Json::Type::Object) {
                @uids = Json::Object();
            }
        }
    }

    void Save() {
        Json::ToFile(file, uids, true);
    }

    void Skip(const string&in uid) {
        uids[uid] = 1;
        Save();
    }

    bool Skipped(const string&in uid) {
        return uids.HasKey(uid);
    }

    void Unskip(const string&in uid) {
        if (Skipped(uid)) {
            uids.Remove(uid);
            Save();
        }
    }
}
