#!/bin/sh

function setup_dir {
if [ -d "${BUILD_PATH}" ]; then
rm -rf "${BUILD_PATH}"
fi
mkdir -p "${BUILD_PATH}"
touch ${LOG_FILE}
}

function build_upload {
echo "----  Start building process"

# clean and archive
#xcodebuild -project ${PROJECT} -scheme ${SCHEME} -configuration ${CONFIGURATION} -sdk iphoneos -xcconfig ${CONFIG_FILE} -archivePath ${ARCHIVE_FILE} clean archive >> ${LOG_FILE} 2>&1
xcodebuild -workspace ${PROJECT} -scheme ${SCHEME} -configuration ${CONFIGURATION} -sdk iphoneos -xcconfig ${CONFIG_FILE} -archivePath ${ARCHIVE_FILE} clean archive >> ${LOG_FILE} 2>&1

echo "=== Archived project ${PROJECT} at ${ARCHIVE_FILE}"

# export
xcrun xcodebuild -exportArchive -exportOptionsPlist ${EXPORT_OPTIONS_FILE} -archivePath ${ARCHIVE_FILE} -exportPath ${EXPORT_PATH} >> ${LOG_FILE}


echo "IPA file size is 'du -h ${IPA_FILE} | cut -f1'" | tee -a ${LOG_FILE}

echo "=== Uploading to pgyer & fir now"

# upload to pgyer
curl -F "file=@${IPA_FILE}" -F "uKey=2bbc669d857ca51ba1dd0374594fa2b6" -F "_api_key=3c26989ed2b9c12ede9f449e58df4711" https://qiniu-storage.pgyer.com/apiv1/app/upload >> ${LOG_FILE}
echo "upload success download https://www.pgyer.com/QaCW"
}

set -e


CONFIG_FILE="Scripts/ci/DeployConfig.xcconfig"
EXPORT_OPTIONS_FILE="Scripts/ci/ExportOptions.plist"


PROJECT="Bookworm.xcworkspace"
SCHEME="Bookworm"
CONFIGURATION="Release"
APP_NAME="Bookworm"
BUILD_PATH="build/${SCHEME}"
LOG_FILE="${BUILD_PATH}/build.log"
ARCHIVE_FILE="${BUILD_PATH}/${APP_NAME}.xcarchive"
EXPORT_PATH="${BUILD_PATH}"
IPA_FILE="${EXPORT_PATH}/${APP_NAME}.ipa"



echo '--- start ---'
setup_dir
build_upload
echo '--- end ---'
