You need to create an SQL table using the following:

```
CREATE TABLE IF NOT EXISTS aimeri_dumpster (
    id INT NOT NULL AUTO_INCREMENT,
    dumpster_name VARCHAR(255) NOT NULL,
    owner_cid VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY unique_dumpster (dumpster_name)
);
```

You also need to create two usable items:
```
- Padlock
- Bobbypin
```

Config options:
```
Config.DebugLock = true
```
DebugLock will enable the /cleardumpsterlocks admin command so they can remove padlocks on all dumpsters at once.
