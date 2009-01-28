import FWCore.ParameterSet.Config as cms

process = cms.Process("o2o")

process.MessageLogger = cms.Service("MessageLogger",
    debugModules = cms.untracked.vstring('*'),
    cout = cms.untracked.PSet(
        threshold = cms.untracked.string('DEBUG')
    ),
    destinations = cms.untracked.vstring('cout')
)

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(1)
)
process.source = cms.Source("EmptySource",
    numberEventsInRun = cms.untracked.uint32(1),
    firstRun = cms.untracked.uint32(1)
)


process.load("OnlineDB.SiStripConfigDb.SiStripConfigDb_cfi")
process.SiStripConfigDb.UsingDb = True
process.SiStripConfigDb.ConfDb = ''
process.SiStripConfigDb.Partitions = cms.untracked.PSet(
    PartTIBD = cms.untracked.PSet(
    ForceVersions = cms.untracked.bool(True),
    ForceCurrentState = cms.untracked.bool(False),
    CablingVersion = cms.untracked.vuint32(67, 8),
    FecVersion = cms.untracked.vuint32(375, 0),
    DcuDetIdsVersion = cms.untracked.vuint32(8, 0),
    FedVersion = cms.untracked.vuint32(469, 0),
    PartitionName = cms.untracked.string('TI_08-AUG-2008_1'),
    DcuPsuMapVersion = cms.untracked.vuint32(0, 0)
    ),
    PartTOB = cms.untracked.PSet(
    ForceVersions = cms.untracked.bool(True),
    ForceCurrentState = cms.untracked.bool(False),
    CablingVersion = cms.untracked.vuint32(66, 5),
    FecVersion = cms.untracked.vuint32(376, 0),
    DcuDetIdsVersion = cms.untracked.vuint32(8, 0),
    FedVersion = cms.untracked.vuint32(470, 0),
    PartitionName = cms.untracked.string('TO_08-AUG-2008_1'),
    DcuPsuMapVersion = cms.untracked.vuint32(0, 0)
    )
    )
process.SiStripConfigDb.TNS_ADMIN = ''

process.SiStripDetInfoFileReader = cms.Service("SiStripDetInfoFileReader")

process.SiStripCondObjBuilderFromDb = cms.Service("SiStripCondObjBuilderFromDb")



process.load("CondCore.DBCommon.CondDBCommon_cfi")
process.CondDBCommon.connect = 'sqlite_file:dbfile.db'
process.CondDBCommon.DBParameters.messageLevel = 4
process.CondDBCommon.DBParameters.authenticationPath = '/afs/cern.ch/cms/DB/conddb'
process.PoolDBOutputService = cms.Service("PoolDBOutputService",
    process.CondDBCommon,
    BlobStreamerName = cms.untracked.string('TBufferBlobStreamingService'),
    logconnect = cms.untracked.string('sqlite_file:log.db'),
    timetype = cms.untracked.string('runnumber'),
    toPut = cms.VPSet(cms.PSet(
        record = cms.string('SiStripPedestalsRcd'),
        tag = cms.string('SiStripPedestals_GR_21X_v3_hlt')
    ), 
        cms.PSet(
            record = cms.string('SiStripNoisesRcd'),
            tag = cms.string('SiStripNoise_GR_21X_v3_hlt')
        ), 
        cms.PSet(
            record = cms.string('SiStripThresholdRcd'),
            tag = cms.string('SiStripThreshold_GR_21X_v3_hlt')
        ), 
        cms.PSet(
            record = cms.string('SiStripBadStrip'),
            tag = cms.string('SiStripBadChannel_GR_21X_v3_hlt')
        ), 
        cms.PSet(
            record = cms.string('SiStripFedCablingRcd'),
            tag = cms.string('SiStripFedCabling_GR_21X_v3_hlt')
        ))
)

process.CommonSiStripPopConParams = cms.PSet(
    SinceAppendMode = cms.bool(True),
    Source = cms.PSet(
        since = cms.untracked.uint32(1),
        name = cms.untracked.string('default'),
        debug = cms.untracked.bool(True)
    ),
    loggingOn = cms.untracked.bool(True)
)

process.siStripPopConNoise = cms.EDAnalyzer("SiStripPopConNoise",
    process.CommonSiStripPopConParams,
    record = cms.string('SiStripNoisesRcd')
)
process.siStripPopConNoise.Source.name = 'siStripPopConNoise'

process.siStripPopConPedestals = cms.EDAnalyzer("SiStripPopConPedestals",
    process.CommonSiStripPopConParams,
    record = cms.string('SiStripPedestalsRcd')
)
process.siStripPopConPedestals.Source.name = 'siStripPopConPedestals'

process.siStripPopConThreshold = cms.EDAnalyzer("SiStripPopConThreshold",
    process.CommonSiStripPopConParams,
    record = cms.string('SiStripThresholdRcd')
)
process.siStripPopConThreshold.Source.name = 'siStripPopConThreshold'

process.siStripPopConFedCabling = cms.EDAnalyzer("SiStripPopConFedCabling",
    process.CommonSiStripPopConParams,
    record = cms.string('SiStripFedCablingRcd')
)
process.siStripPopConFedCabling.Source.name = 'siStripPopConFedCabling'

process.siStripPopConBadStrip = cms.EDAnalyzer("SiStripPopConBadStrip",
    process.CommonSiStripPopConParams,
    record = cms.string('SiStripBadStrip')
)
process.siStripPopConBadStrip.Source.name = 'siStripPopConBadStrip'


process.pped = cms.Path(process.siStripPopConFedCabling+process.siStripPopConNoise+process.siStripPopConPedestals+process.siStripPopConThreshold+process.siStripPopConBadStrip)


