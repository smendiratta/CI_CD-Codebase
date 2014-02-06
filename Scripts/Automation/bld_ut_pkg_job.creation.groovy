def BuildJson=new URL("http://pppdc9prd07t.corp.intuit.net/get_build_ut_pkg.php")
def GetData= new groovy.json.JsonSlurper().parse(BuildJson.newReader())
println GetData.Soln_Path
def TEMPLATE='Build-Template'
def Project=GetData.Project_Name
def viewspec=GetData.View_Spec
def soln_file=GetData.Soln_Path
def ut_test_path=GetData.Ut_Test_Path
def nuspec_path=GetData.Nuspec_Path
def viewmask=GetData.View_Mask.replaceAll(",","\n")
def workspace_client="package_ps_$Project"
def cronstr=GetData.Poll_Freq
def proj_path_temp=viewspec.split('//',2)[1].split('/',2)
def proj_path=proj_path_temp[1].replaceAll("[.]","").replaceAll('/','\\\\')
def workspace_path1='D:\\Jenkins\\workspace\\'+"${Project}"
def soln_path="${workspace_path1}"+'\\'+"${proj_path}"+"${soln_file}"
def ut_script_path='D:\\Jenkins\\Scripts\\runNunitTest.ps1'
def pkg_script_path="D:\\Jenkins\\Scripts\\createNugetPkg_stg.ps1"
def build_config=GetData.Build_Config

static Closure MSBuild(String sMsBuildName, String sMsBuildFile)  {
        return {
                it / 'builders' << 'hudson.plugins.msbuild.MsBuildBuilder' {
                        msBuildName sMsBuildName
                        msBuildFile sMsBuildFile
                        buildVariablesAsProperties true
                        continueOnBuildFailure false
                }
        }
}
static Closure Batch(String sCommand)  {
        return {
                it / 'builders' << 'hudson.tasks.BatchFile' {
                        command sCommand
                }
        }
     } 
static Closure PublisherNunit(String stestResultsPattern) {
        return {
                 it / 'publishers' << 'hudson.plugins.nunit.NUnitPublisher' {
                         testResultsPattern stestResultsPattern 
                 }
        }
}
static Closure Version(String sversionNumberString, String sprojectStartDate ) {
      return {
        it / 'buildWrappers' << 'org.jvnet.hudson.tools.versionnumber.VersionNumberBuilder'{
                                   versionNumberString sversionNumberString
                                 projectStartDate sprojectStartDate
                                 environmentVariableName VERSION
                                 buildsToday -1
                                 buildsThisMonth -1
                                 buildsThisYear  -1
                                 buildsAllTime   -1
                                 skipFailedBuilds true
        }
      }
}
job {
    using "${TEMPLATE}"
    name "${TEMPLATE}".replaceAll('Template', "${Project}")
    customWorkspace(workspace_path1)
    
scm {
  p4(viewspec){ node->
node /useViewMask('true')
node /exposeP4Passwd('false')
node /viewMask(viewmask)
node /useViewMaskForPolling('true')
node /wipeBeforeBuild('false')
node /p4Client(workspace_client)
node /p4Port('perforce.corp.intuit.net:2000')
              }
  
   }
   
triggers{
  scm(cronstr)
}
configure MSBuild("MSBuildV4", "${soln_path}")
configure Version('1.${BUILD_YEAR}.${BUILD_MONTH}.${BUILDS_THIS_MONTH}', "2013-1-28 08:00:00.0 UTC")
configure Batch("powershell ${ut_script_path} ${build_config} ${proj_path}${ut_test_path} ${workspace_path1}" )
configure Batch("powershell ${pkg_script_path} %VERSION% ${proj_path}${nuspec_path} %WORKSPACE%")
configure PublisherNunit('*.NunitResult.xml')


}