# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 23.04.16
# Time: 19:20
# To change this template use File | Settings | File Templates.

@CLASS
Semver

@OPTIONS
locals

@auto[]
###


#------------------------------------------------------------------------------
#:param versionParser type VersionParser
#:param comparator type Comparator
#------------------------------------------------------------------------------
@create[versionParser;comparator]
    $self.versionParser[$versionParser]

    $self.ASC(1)
    $self.DESC(-1)
###


#------------------------------------------------------------------------------
#:param version type string
#:param constraints type string
#
#:result boolean
#------------------------------------------------------------------------------
@satisfies[version;constraints][result]

    $versionConstraint[^Constraint::create['==';^self.versionParser.normalize[$version]]]
    $constraints[^self.versionParser.parseConstraints[$constraints]]

    $result[^constraints.matches[$versionConstraint]]
###


#------------------------------------------------------------------------------
#:param versions type hash
#:param constraints type string
#
#:result hash
#------------------------------------------------------------------------------
@satisfiedBy[versions;constraints][result]
    $result[^hash::create[]]
    ^versions.foreach[key;version]{
        ^if(^self.satisfies[$version;$constraints]){
            $result.$key[$version]
        }
    }
###


#------------------------------------------------------------------------------
#:param versions type version
#:param direction type string
#
#:result hash
#------------------------------------------------------------------------------
@sort[versions;direction][result]
    $normalized[^hash::create[]]
    ^verions.foreach[key;version]{
        $index[^normalized._count[]]
        $normalized.$index[^self.versionParser.normalize[$verions]]
    }
# Primitive bubbling sort
# TODO replace by smth more efficient
    $needLoop(true)
    ^while($needLoop){
        $needLoop(false)
        ^for[i](0;^normalized._count[]-2){
            $ind($i)
            $nextInd($i+1)
            $aVersion[^normalized._at(i)]
            $bVersion[^normalized._at(i+1)]
            ^if($aVersion ne $bVersion){
                ^if(^self.comparator.lessThan[$aVersion;$bVersion]){
                    $needLoop(true)
                    $normalized.$ind[$bVersion]
                    $normalized.$nextInd[$aVersion]
                }
            }
        }
    }

    $result[$normalized]
###