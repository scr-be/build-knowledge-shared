# World Knowledge

This repository contains a collection of YAML config and data-fixture files, PHPUnit bootstrap logic, CI environment and application helper scripts, and an assortment of other random shared assets required for our projects.

## ORM Fixtures

Within the `shared/fixures` sub folder is a collection of YAML files that allow Symfony to build its database from scratch.

These files have a specific YAML structure that provides the information necessary to determine the correct table and repository service, manage dependencies between mapped resources, and specify how the mapping are applied.

### Example

The basic format for these files is as follows:

```yaml
DoctrineEntityName:

    version:
        structure: null|x.x.x
        data:      null|x.x.x

    orm:
        action:     truncate|append|merge
        table:      null|tableName
        repository: entity.repository.service.reference.string

    dependencies:
        - DependencyEntityName
        - SecondDependencyEntityName

    data:

        1:
            name:         'Row Value 1'
            abbr:         'r1'
            relationship: '@DependencyEntityName?column=search'

        2:
            name:         i'Row Value 2'
            abbr:         'r2'
            relationship: '+DependencyEntityName:rowId'
```

### Version Information

The version information provide a sanity check by giving us with a means to compare both the structure and data content prior to the fixture-loading script running against the live structure and data versions.

### ORM Information

This section configures the import operation behavior and provides the required values for Symfony to handle the import using its service container directory, versus attempting to manage Doctrine ourselves.

The `action` index can have one of three values: `truncate`, `append`, or `merge`. Each table has its own `action` configuration, allowing us to truncate and replace individual tables when it is beneficial, while handling other aspects of the import different options.

The `table` key exists in the event that a table name is different from its entity name. At this time, this is not the case with entities and their respective tables.

The `repository` directive defines the Symfony service container request string that will be used to retrieve a repository instance for the table. Handling imports this way allows for the full use and benefits of Doctrine without us having to write our own implementation.

Next, the `dependencies` list (which can be null if no dependencies apply) defines any entities which must be imported prior, generally due to relationship mapping that the fixure is requests between itself and another table. Circular references are not currently supported, though we could manage this by disabling database foreign key constraits for the affected entities if need be.

Lastly, the `data` value must contain a list of numerically indexed items that contain contain key->value defintions that map to tables and their respective value.

### ORM Relationships

Relationships can be defined in two ways. The simplest replies on the numeric index of every table data row within the fixtures. For instance, to reference "Row Item 2" from the previous example in another fixutre, we would use the following syntax

```
+DoctrineEntityName:2
```

While this method can work well when a complete database import is taking place, it causes difficulties for imports of data subsets as well as `merging` functionality. As such, it is preferrable to use the second syntax, which will explicity query the database for your request and return the real entity associated. To reference the same row using this syntax, you would use

```
@DoctrineEntityName?name="Row Value 2"
```

Notice how this syntax is literally layed out like a query. Furthermore, it supports multiple search paramiters. You could amend the previous query example to retrieve the same row again:

```
@DoctrineEntityName?name="Row Value 2"&abbr="r2"
```

## Contact

Please contact Dan Corrigan or myself (Rob Frawley) if you have any questions or concerns regarding any settings, copy, or other relivant items within this repository.
