# project2

att-tool-app new version  
fixing incompatibility version bugs  
ext {
compileSdkVersion = 34
targetSdkVersion = 34
appCompatVersion = "1.7.0"
}

subprojects { afterEvaluate { android { compileSdkVersion 34 } } }
