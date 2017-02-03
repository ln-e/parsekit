Parsekit - Dependency manager for parser3
=========================================

It aims to manage your [parser3](http://parser.ru) project dependencies in
declarative way.


Installation
------------

Right now only manual install are available.
Download and unzip archive file attached to release.

Due to the fact that the parser3 is very sensitive to the user on behalf it is
executed, the search for the parser3 binary file is as follows:

* `cgi/parser3.cgi` or `cgi/parser3` inside project directory (where parsekit
was called)
* globally installed `parser3` or `parser3.cgi`
* parser installed in `../cgi/` directory relative to parsekit installation dir.

Then just verify installation by run
```shell
$ parsekit
```
You should see table with available command.
After that your can start use parsekit.


Usage
-----

Create parsekit.json file in the root project folder. In the require section
specify which packages do you need, and their versions.

```json
{
    "name":"New Project",
    "require":{
        "parser": ">=3.4.3",
        "test/a": ">=1.1 <=1.3",
        "test/b": ">=1.1 <=1.2",
        "test/c": "1.2"
    }
}
```

Parsekit also supports range identifiers like `~` and `-`

`parsekit update` will search latest available packages satisfying the
specified constraints.

`parsekit install` install exactly the same packages which was installed while
last update command. This versions are stored in `parsekit.lock` file. So, it
is highly recommended to add this file to your git repository and ignore `vault/`
directory.


Autoload
--------

Parsekit allows to forget about direct calls of `^use` or `@USE`. Any package
as such as root package can determine autload section in parsekit.

```
{
    "autoload": {
        "files":[
            "main.p"
        ],
        "nested-classpath": [
            "../src"
        ],
        "classpath":[
            "../classes",
            "../tests"
        ],
        "namespace":[
            "Vendor/Package": "path/to/src"
        ]
    }
}
```

Update you project dependencies or just call `parsekit dumpclasspath` and
add to you `auto.p` `^use[]` of automatically generated file:

```
@auto[]
    ^use[vault/classpath.p]
```

For parsekit.json listed above it will:
* use all files listed in `files` section i.e. `^use[main.p]`
* add all directories listed in `classpath` section to `$MAIN:CLASS_PATH`
i.e. `../classes` and `../tests`
* recursively add all directories found in `../src` to `$MAIN:CLASS_PATH`
* create `@autoload` method which can resolve `Vendor/Package/Folder/ClassName`
to `path/to/src/Folder/ClassName.p` inside which should be defined class
```parser3
@CLASS
Vendor/Package/Folder/ClassName
```

###!important
Autogenerated paths depends on `docroot` parsekit.json setting:

* `docroot` (defaults to `www`) - indicate what specified folder will be
document root while execution. All paths generates relative to it. 
`"docRoot": "www"` leads to `/../src` or `/../data` classpath. While class 
loading `$request:document-root` will be temporary changed to 
`/project/direcotory/_docroot_` and restored after `^use[]` file


Stability
---------

`parsekit.json` can contain `minimumStability` option (only root package) which is defaults to `dev`.
If you prefer use more stable versions you may set one of: `alpha`, `beta`, `RC` or `stable`. If you update package
without upper bound constraint and with minimumStability set to dev you always get the latest commit
from master branch.

Requirements
------------

[Parser](http://www.parser.ru/en/download/) 3.4.3 and above


TODO
----

* Check resolving algorithm for bugs
* Implement better constraint collapsing (`>=1 <=2 <2` should collapsed to `>=1 <2`)
* Improve console output
* Write instructions for contributors
