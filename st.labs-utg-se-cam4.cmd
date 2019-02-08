require ADPointGrey,2.7.0-dev
#  require ADPointGrey,develop
require ADPluginCalib,0.0.1
require busy,1.7.0+
require sequencer,2.1.21+
require sscan,1339922+
require calc,3.7.0+
require autosave,5.9.0+

epicsEnvSet("CAMERA_ID", "18457601")
epicsEnvSet("AREA", "labs-utg-se")
epicsEnvSet("DEVICE", "cam4")

epicsEnvSet("PREFIX_PV", "$(AREA):$(DEVICE):")
epicsEnvSet("IOCNAME", "$(AREA)-$(DEVICE)")
epicsEnvSet("CAM", "")
epicsEnvSet("IMAGE", "image1:")

epicsEnvSet("IOC", "iocPointGrey")
epicsEnvSet("TOP", ".")
epicsEnvSet("AS_TOP", "/epics/autosave")

epicsEnvSet("ADPOINTGREY", "/home/iocuser/e3/e3-ADPointGrey/ADPointGrey")
epicsEnvSet("ADCORE", "/home/iocuser/e3/e3-ADCore/ADCore")
epicsEnvSet("AUTOSAVE", "")

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","64000000")

### The port name for the detector
epicsEnvSet("PORT",   "PG")
### Really large queue so we can stream to disk at full camera speed
epicsEnvSet("QSIZE",  "2000")   
### The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "2048")
### The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1556")
### The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
### The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
### The search path for database files
# epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")
### Define NELEMENTS to be enough for a 2048x1536x1x2 (size x 1bytes per pixel x 2 cameras) = 6291456, I set two times more, memory is not an issue...
epicsEnvSet("NELEMENTS", "12582912")

#########################   camera 1 #######################################################################################################################################
### pointGreyConfig(const char *portName, int cameraId, int traceMask, int memoryChannel,
###                 int maxBuffers, size_t maxMemory, int priority, int stackSize)
pointGreyConfig("$(PORT)", "$(CAMERA_ID)", 0x1, 0)

asynSetTraceIOMask($(PORT), 0, 2)
###asynSetTraceMask($(PORT), 0, 0xFF)
###asynSetTraceFile($(PORT), 0, "asynTrace.out")
###asynSetTraceInfoMask($(PORT), 0, 0xf)

dbLoadRecords("pointGrey.db", "P=$(PREFIX_PV),R=$(CAM),PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("pointGrey-ess.db", "P=$(PREFIX_PV),R=$(CAM),PORT=$(PORT)")

### Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, $(PORT), 0, 0)
### Use this line for 8-bit data only
###dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX_PV),R=$(IMAGE),PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=CHAR,NELEMENTS=$(NELEMENTS)")
### Use this line for 8-bit or 16-bit data
dbLoadRecords("NDStdArrays.template", "P=$(PREFIX_PV),R=$(IMAGE),PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")

### Load all other plugins using commonPlugins.cmd

epicsEnvSet(PREFIX, "$(PREFIX_PV)")
< $(ADCORE)/../cmds/commonPlugins.cmd

iocshLoad("$(autosave_DIR)/autosave.iocsh")

iocInit()

## Wait for enum callbacks to complete
epicsThreadSleep(5.0)

## Records with dynamic enums need to be processed again because the enum values are not available during iocInit.  
dbpf("$(PREFIX_PV)$(CAM)Format7Mode.PROC", "1")
dbpf("$(PREFIX_PV)$(CAM)PixelFormat.PROC", "1")

## Wait for callbacks on the property limits (DRVL, DRVH) to complete
epicsThreadSleep(5.0)

## Records that depend on the state of the dynamic enum records or property limits also need to be processed again
## Other property records may need to be added to this list
dbpf("$(PREFIX_PV)$(CAM)FrameRate.PROC", "1")
dbpf("$(PREFIX_PV)$(CAM)FrameRateValAbs.PROC", "1")
dbpf("$(PREFIX_PV)$(CAM)AcquireTime.PROC", "1")
dbpf("$(PREFIX_PV)$(CAM)FrameRateValAbs_RBV", "3");


