$PROJECT_FOLDER=".\dotnet462-api"
$VERSION=(Get-Date).toString("yyMM.dd.hh.mm")
#DOCKER_PUBLISH_FOLDER=".\obj\Docker\publish"
$DOCKER_IMAGE_NAME="vkhazin/dotnet462-api"
$DOCKER_IMAGE_ID=$DOCKER_IMAGE_NAME + ":" + $VERSION
$S3_BUCKET_NAME="smith-poc-deploy"
$S3_BUCKET_KEY="dotnet462-api"
$FILE_NAME=$DOCKER_IMAGE_ID.Replace(":", "-").Replace("/", "-") + ".tar"

# Cleanup for jenkins
rd -Recurse -Force (".\" + $PROJECT_FOLDER + "\\bin\\*")
rd -Recurse -Force (".\" + $PROJECT_FOLDER + "\\obj\\*")
rd (".\" + $PROJECT_FOLDER + "\*.tar")
docker rmi $(docker images -q $DOCKER_IMAGE_ID)

# Build
# nuget restore
& 'C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe' /p:DeployOnBuild=true /p:PublishProfile=Docker $PROJECT_FOLDER
write-host "Finished building the project"

# Package
docker build $PROJECT_FOLDER --tag $DOCKER_IMAGE_ID
docker save -o $FILE_NAME $DOCKER_IMAGE_ID
write-host "Finished creating and extracting docker image: "$DOCKER_IMAGE_ID

# Upload to S3
aws s3api put-object --bucket $S3_BUCKET_NAME --key $S3_BUCKET_KEY/$FILE_NAME --body $FILE_NAME
write-host "Finished uploading docker image tar file to S3 bucket: "$S3_BUCKET_KEY"/"$FILE_NAME