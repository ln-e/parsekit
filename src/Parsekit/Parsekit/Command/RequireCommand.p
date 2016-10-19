# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 13.02.16
# Time: 14:12
# To change this template use File | Settings | File Templates.

@CLASS
RequireCommand

@OPTIONS
locals

@BASE
Ln-e/Console/CommandInterface


#------------------------------------------------------------------------------
#:constructor
#------------------------------------------------------------------------------
@create[]
    ^BASE:create[]
###


#------------------------------------------------------------------------------
#Configure command
#------------------------------------------------------------------------------
@configure[]
    $self.name[require]
    $self.description[add dependency to project.]
    ^self.addArgument[package;${Ln-e/Console/Input/CommandArgument:REQUIRED}]
    ^self.addOption[debug;d;;Enabling debug output]
###


#------------------------------------------------------------------------------
#Command execution
#
#:param input type Ln-e/Console/Input/InputInterface
#:param output type Ln-e/Console/Output/OutputInterface
#------------------------------------------------------------------------------
@execute[input;output][result]
    $result[]
    $packageManager[$DI:packageManager]
    $rootPackage[^packageManager.createRootPackage[/parsekit.json]]
    $packageArgument[^input.getArgument[package]]

    $pieces[^packageArgument.split[:;h]]
    $newPackageName[^if(def $pieces.0){$pieces.0}{$packageArgument}]
    $newPackageVersion[^if(def $pieces.1){$pieces.1}{*}]

    ^try{
        $tempPackage[^packageManager.getPackage[$newPackageName;$rootPackage.minimumStability]]
    }{
#       TODO make mo complicated and interactive select right version
        ^if($exception.type eq PackageNotFoundException){
            $exception.handled(true)
            $assumptions[^packageManager.guessPackage[$newPackageName]]
            ^output.writeln[]
            ^output.writeln[  Package '$newPackageName' not found]
            ^if(^assumptions._count[] > 0){
                ^output.writeln[]
                ^output.writeln[  Do you mean one of:]
                ^assumptions.foreach[key;value]{
                    ^output.writeln[    -  $value]
                }
            }

            $newPackageName[] ^rem[ clear new package name to prevent all futher actions]
        }
    }

    ^if(def $newPackageName){
        $lockFile[^LockFile::create[/parsekit.lock]]
        $requires[^rootPackage.getRequireByEnv[]]

        ^if(^requires.contains[$newPackageName]){
            ^output.writeln[Package $newPackageName already in parsekit.json]
        }{
            $requirements[^lockFile.getInstalledRequirements[]]
            $requirements.[$newPackageName][$newPackageVersion]
            $resolvingResult[^DI:resolver.resolve[$requirements;$rootPackage.minimumStability](true;^input.getArgument[debug])]

            ^if(!($resolvingResult is ResolvingResult)){
                ^output.writeln[]
                ^output.writeln[Could not update requirements, as it has conflicts. Soon you will see which package cause problem, but now try your luck.]
            }{
#               Updates original file
                $file[^JsonFile::create[/parsekit.json]]
                $data[^file.read[]]
                $data.require.[$newPackageName][$newPackageVersion] ^rem[ OR get the installed version and "downgrade" it version to "~1.2" view ]
                ^file.write[$data;/parsekit.json]

                ^if($lockFile.empty){
                    ^lockFile.updateFromPackage[$rootPackage]
                }

                $installResult[^DI:installer.update[$lockFile;$resolvingResult.packages;$rootPackage;$input.options]]
                ^output.writeln[$installResult.info]

#               Temporary decision. write second lock to vault dir, to compare with them while install.
#               In future this should be replaced. Current installed version should detected by exact dir.
#               Git or some kind of lock file in case of zip distribution.
                ^if(^lockFile.save[] && ^lockFile.save[/$DI:vaultDirName/parsekit.lock]){
                    ^output.writeln[]
                    ^output.writeln[  Lockfile saved.]
                }
            }
        }
    }
###