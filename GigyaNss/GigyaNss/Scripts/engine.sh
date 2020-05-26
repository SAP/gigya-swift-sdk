APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and

find "$APP_PATH" -name 'GigyaNss.framework' -type d | sed 's|/[^/]*$||' | while read -r FRAMEWORK
do

find "${PROJECT_DIR}" -name 'GigyaNss.framework' | while read -r FRAMEWORKORIFINAL
do

if [[ $FRAMEWORKORIFINAL == *"$CONFIGURATION"* ]]; then
cp -R $FRAMEWORKORIFINAL $FRAMEWORK
echo "cpp: $FRAMEWORKORIFINAL"
echo "to: $FRAMEWORK"
fi

done

done

find "$APP_PATH" -name 'GigyaNssEngine.framework' -type d | sed 's|/[^/]*$||' | while read -r FRAMEWORK
do

find "${PROJECT_DIR}" -name 'GigyaNssEngine.framework' | while read -r FRAMEWORKORIFINAL
do

if [[ $FRAMEWORKORIFINAL == *"$CONFIGURATION"* ]]; then
cp -R $FRAMEWORKORIFINAL $FRAMEWORK
echo "cpp: $FRAMEWORKORIFINAL"
echo "to: $FRAMEWORK"
fi

done

done