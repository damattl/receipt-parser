LOCAL_PATH:=$(call my-dir)

include $(CLEAR_VARS)

OPENCV_INSTALL_MODULES:=on
OPENCV_LIB_TYPE:=STATIC
include ~/Library/OpenCV/android/sdk/native/jni/OpenCV.mk
# LOCAL_C_INCLUDES := $(LOCAL_PATH)/src/
LOCAL_SRC_FILES := src/image_tools.cpp
LOCAL_MODULE := image_tools

include $(BUILD_SHARED_LIBRARY)