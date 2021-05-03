@echo off
cls
title Quick Deployment
echo ----------------------------
echo Welcome to deployment setup
echo ---------------------------- && echo. && echo.

echo SFDX CLI version:
call sfdx --version
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Make sure you have SFDX CLI installed. 
    echo To download visit, https://developer.salesforce.com/tools/sfdxcli
    pause
    exit
)
echo.

set URL=https://test.salesforce.com
set /p PROD=Deploying to Production?[y/n] 
if %PROD% == y set URL=https://login.salesforce.com

echo.
echo Please login to org. A browser window will open soon...
call sfdx force:auth:web:login -s -a tempQuickDeploymentOrg -r %URL%
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Login Failed. Make sure you entered the current credentials.
    pause
    exit
)

echo.
set /p TESTLEVEL=Enter test level(NoTestRun,RunSpecifiedTests,RunLocalTests,RunAllTestsInOrg): 
if %TESTLEVEL% == RunSpecifiedTests (
    if exist SpecifiedTestClasses.txt (
        set /p TESTCLASSES=<SpecifiedTestClasses.txt
    ) else (
        echo 'RunSpecifiedTests' option selected but the file 'SpecifiedTestClasses.txt' doesn't exit. 
        pause
        exit
    )
)

echo.
echo Validating the package using %TESTLEVEL% test level...
if %TESTLEVEL% == RunSpecifiedTests (
    call sfdx force:source:deploy -x manifest/package.xml -u tempQuickDeploymentOrg -l %TESTLEVEL% -r %TESTCLASSES% -c
) else (
    call sfdx force:source:deploy -x manifest/package.xml -u tempQuickDeploymentOrg -l %TESTLEVEL%  -c
)

if %ERRORLEVEL% NEQ 0 (
    pause > nul
    exit
) else (
    cls
    echo.
    set /p deploy=Validation success. Do you want to deploy?[y/n] 
)

echo.
if %deploy% == y (
    echo Deploying the package using %TESTLEVEL% test level...
    if %TESTLEVEL% == RunSpecifiedTests (
        call sfdx force:source:deploy -x manifest/package.xml -u tempQuickDeploymentOrg -l %TESTLEVEL% -r %TESTCLASSES%
    ) else (
        call sfdx force:source:deploy -x manifest/package.xml -u tempQuickDeploymentOrg -l %TESTLEVEL%
    )
)

echo.
echo Logging out...
call sfdx force:auth:logout -u tempQuickDeploymentOrg --noprompt
pause
exit
