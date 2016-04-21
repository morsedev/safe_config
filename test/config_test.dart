import 'package:test/test.dart';
import 'package:safe_config/safe_config.dart';

void main() {
  test("Success case", () {
    var yamlString =
        "port: 80\n"
        "name: foobar\n"
        "database:\n"
        "  host: stablekernel.com\n"
        "  username: bob\n"
        "  password: fred\n"
        "  databaseName: dbname\n"
        "  port: 5000";

    var t = new TopLevelConfiguration(yamlString);
    expect(t.port, 80);
    expect(t.name, "foobar");
    expect(t.database.host, "stablekernel.com");
    expect(t.database.username, "bob");
    expect(t.database.password, "fred");
    expect(t.database.databaseName, "dbname");
    expect(t.database.port, 5000);
  });

  test("Extra property", () {
    var yamlString =
        "port: 80\n"
        "name: foobar\n"
        "extraKey: 2\n"
        "database:\n"
        "  host: stablekernel.com\n"
        "  username: bob\n"
        "  password: fred\n"
        "  databaseName: dbname\n"
        "  extraKey: 2\n"
        "  port: 5000";

    var t = new TopLevelConfiguration(yamlString);
    expect(t.port, 80);
    expect(t.name, "foobar");
    expect(t.database.host, "stablekernel.com");
    expect(t.database.username, "bob");
    expect(t.database.password, "fred");
    expect(t.database.databaseName, "dbname");
    expect(t.database.port, 5000);
  });

  test("Missing required top-level explicit", () {
    try {
      var yamlString =
          "name: foobar\n"
          "database:\n"
          "  host: stablekernel.com\n"
          "  username: bob\n"
          "  password: fred\n"
          "  databaseName: dbname\n"
          "  port: 5000";

      var _ = new TopLevelConfiguration(yamlString);
    } on ConfigurationException catch (e) {
      expect(e.message, "port is required but was not found in configuration.");
    } catch (e) {
      expect(true, false, reason: "Should not reach here");
    }
  });

  test("Missing required top-level implicit", () {
    try {
      var yamlString =
          "port: 80\n"
          "name: foobar\n";
      var _ = new TopLevelConfiguration(yamlString);
    } on ConfigurationException catch (e) {
      expect(e.message, "database is required but was not found in configuration.");
    } catch (e) {
      expect(true, false, reason: "Should not reach here");
    }
  });

  test("Optional can be missing", () {
    var yamlString =
        "port: 80\n"
        "database:\n"
        "  host: stablekernel.com\n"
        "  username: bob\n"
        "  password: fred\n"
        "  databaseName: dbname\n"
        "  port: 5000";

    var t = new TopLevelConfiguration(yamlString);
    expect(t.port, 80);
    expect(t.name, isNull);
    expect(t.database.host, "stablekernel.com");
    expect(t.database.username, "bob");
    expect(t.database.password, "fred");
    expect(t.database.databaseName, "dbname");
    expect(t.database.port, 5000);
  });

  test("Nested optional can be missing", () {
    var yamlString =
        "port: 80\n"
        "name: foobar\n"
        "database:\n"
        "  host: stablekernel.com\n"
        "  password: fred\n"
        "  databaseName: dbname\n"
        "  port: 5000";

    var t = new TopLevelConfiguration(yamlString);
    expect(t.port, 80);
    expect(t.name, "foobar");
    expect(t.database.host, "stablekernel.com");
    expect(t.database.username, isNull);
    expect(t.database.password, "fred");
    expect(t.database.databaseName, "dbname");
    expect(t.database.port, 5000);
  });

  test("Nested required cannot be missing", () {
    try {
      var yamlString =
          "port: 80\n"
          "name: foobar\n"
          "database:\n"
          "  host: stablekernel.com\n"
          "  password: fred\n"
          "  port: 5000";

      var _ = new TopLevelConfiguration(yamlString);
    } on ConfigurationException catch (e) {
      expect(e.message, "databaseName is required but was not found in configuration.");
    } catch (e) {
      expect(true, false, reason: "Should not reach here");
    }
  });

  test("Map and list cases", () {
    var yamlString =
        "strings:\n"
        "-  abcd\n"
        "-  efgh\n"
        "databaseRecords:\n"
        "- databaseName: db1\n"
        "  port: 1000\n"
        "  host: stablekernel.com\n"
        "- username: bob\n"
        "  databaseName: db2\n"
        "  port: 2000\n"
        "  host: stablekernel.com\n"
        "integers:\n"
        "  first: 1\n"
        "  second: 2\n"
        "databaseMap:\n"
        "  db1:\n"
        "    host: stablekernel.com\n"
        "    databaseName: db1\n"
        "    port: 1000\n"
        "  db2:\n"
        "    username: bob\n"
        "    databaseName: db2\n"
        "    port: 2000\n"
        "    host: stablekernel.com\n";

    var special = new SpecialInfo(yamlString);
    expect(special.strings, ["abcd", "efgh"]);
    expect(special.databaseRecords.first.host, "stablekernel.com");
    expect(special.databaseRecords.first.databaseName, "db1");
    expect(special.databaseRecords.first.port, 1000);

    expect(special.databaseRecords.last.username, "bob");
    expect(special.databaseRecords.last.databaseName, "db2");
    expect(special.databaseRecords.last.port, 2000);
    expect(special.databaseRecords.last.host, "stablekernel.com");

    expect(special.integers["first"], 1);
    expect(special.integers["second"], 2);
    expect(special.databaseMap["db1"].databaseName, "db1");
    expect(special.databaseMap["db1"].host, "stablekernel.com");
    expect(special.databaseMap["db1"].port, 1000);
    expect(special.databaseMap["db2"].username, "bob");
    expect(special.databaseMap["db2"].databaseName, "db2");
    expect(special.databaseMap["db2"].port, 2000);
    expect(special.databaseMap["db2"].host, "stablekernel.com");
  });
}

class TopLevelConfiguration extends ConfigurationItem {
  TopLevelConfiguration(String contents) : super.fromString(contents);

  @requiredConfiguration
  int port;

  @optionalConfiguration
  String name;

  DatabaseConnectionConfiguration database;
}

class SpecialInfo extends ConfigurationItem {
  SpecialInfo(String contents) : super.fromString(contents);

  List<String> strings;
  List<DatabaseConnectionConfiguration> databaseRecords;
  Map<String, int> integers;
  Map<String, DatabaseConnectionConfiguration> databaseMap;
}
